import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

import 'constants.dart';
import 'objects.dart';

class BaseClient {
  static const Duration requestTimeout = Duration(seconds: 10);

  static const String symbolTypeSpot = 'SPOT';

  static const String sideBuy = 'BUY';
  static const String sideSell = 'SELL';

  final String? _apiKey;
  final String? _apiSecret;
  final bool _testnet;
  final Map<String, String>? _params;
  Duration _timeOffset = Duration(); // in milliseconds

  /// [requestParams]: optional - Dictionary of requests params to use for all calls
  /// [testnet]: Use testnet environment - only available for vanilla options at the moment
  BaseClient({String? apiKey, String? apiSecret, bool testnet = false, Map<String, String>? requestParams})
      : _apiKey = apiKey,
        _apiSecret = apiSecret,
        _testnet = testnet,
        _params = requestParams;

  Map<String, String> get _headers {
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: ContentType.json.toString(),
      HttpHeaders.acceptHeader: 'application/json',
      // 'Accept': 'application/json',
      // "HTTP_ACCEPT_LANGUAGE": "en-US",
      // HttpHeaders.acceptLanguageHeader: 'en-US',  // "Accept-Language": "en-US",
      'User-Agent':
          'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36',
    };
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      headers['X-MBX-APIKEY'] = _apiKey as String;
    }
    return headers;
  }

  String _generateSignature(String queryString) {
    assert(_apiSecret!.isNotEmpty, 'API Secret required for private endpoints');
    List<int> messageBytes = utf8.encode(queryString);
    List<int> key = utf8.encode(_apiSecret as String);
    Hmac hMac = Hmac(sha256, key);
    Digest digest = hMac.convert(messageBytes);
    return '$digest'; // hex string
  }

  Map<String, dynamic> _getRequestArguments(bool signed, [Map<String, dynamic>? params]) {
    // set default requests timeout
    Map<String, dynamic> result = {};
    // add our global requests params
    if (_params != null && _params!.isNotEmpty) result.addAll(_params!); // TODO: check need
    if (params != null && params.isNotEmpty) result.addAll(params);
    result.removeWhere((_, value) => value == null || value.isEmpty);
    // if signed generate signature
    if (signed) {
      result['timestamp'] = DateTime.now().add(_timeOffset).millisecondsSinceEpoch;
      final _tmpUri = Uri(queryParameters: result.map((key, value) => MapEntry(key, '$value')));
      result['signature'] = _generateSignature(_tmpUri.query);
    }
    return result;
  }

  Future _doRequest(HttpMethod method, Uri uri, [Map<String, dynamic>? params]) async {
    switch (method) {
      case HttpMethod.get:
        return await http.get(uri, headers: _headers).timeout(requestTimeout);
      case HttpMethod.post:
        return await http.post(uri, headers: _headers, body: params).timeout(requestTimeout);
      case HttpMethod.put:
        return await http.put(uri, headers: _headers, body: params).timeout(requestTimeout);
      case HttpMethod.delete:
        return await http.delete(uri, headers: _headers, body: params).timeout(requestTimeout);
    }
  }

  Future _request(HttpMethod method, String uriHost, String uriPath, bool signed,
      [Map<String, dynamic>? params]) async {
    final Map<String, dynamic> reqParams = _getRequestArguments(signed, params);
    final Uri _uri = (method == HttpMethod.get) ? Uri.https(uriHost, uriPath, reqParams) : Uri.https(uriHost, uriPath);

    http.Response response;
    try {
      response = await _doRequest(method, _uri, params);
    } on SocketException catch (_err) {
      throw BinanceApiException(500, '$_err');
    }

    if (response.statusCode > 299) throw BinanceApiException(response.statusCode, response.body);
    final jsonData = jsonDecode(response.body);
    if (jsonData is Map && jsonData.containsKey("code")) throw BinanceApiException(jsonData["code"], jsonData["msg"]);
    return jsonData;
  }

  Future _requestApi(HttpMethod method, String uriPath,
      {bool signed = false, String? version, Map<String, dynamic>? params}) async {
    final String _uriHost = _testnet ? BnApiUrls.apiUrlTestnet : BnApiUrls.apiUrl;
    final String _version = signed ? BnApiUrls.privateApiVersion : version ?? BnApiUrls.publicApiVersion;
    return await _request(method, _uriHost, 'api/$_version/$uriPath', signed, params);
  }

  Future _requestFuturesApi(HttpMethod method, String uriPath,
      {bool signed = false, Map<String, dynamic>? params}) async {
    final String _uriHost = _testnet ? BnApiUrls.futuresUrlTestnet : BnApiUrls.futuresUrl;
    return await _request(method, _uriHost, 'fapi/${BnApiUrls.futuresApiVersion}/$uriPath', signed, params);
  }

  Future _requestFuturesDataApi(HttpMethod method, String uriPath,
      {bool signed = false, Map<String, dynamic>? params}) async {
    final String _uriHost = _testnet ? BnApiUrls.futuresUrlTestnet : BnApiUrls.futuresUrl;
    return await _request(method, _uriHost, 'futures/data/$uriPath', signed, params);
  }

  Future _requestFuturesCoinApi(HttpMethod method, String uriPath,
      {bool signed = false, int version = 1, Map<String, dynamic>? params}) async {
    final String _uriHost = _testnet ? BnApiUrls.futuresCoinUrlTestnet : BnApiUrls.futuresCoinUrl;
    final String _version = version == 1 ? BnApiUrls.futuresApiVersion : BnApiUrls.futuresApiVersion2;
    return await _request(method, _uriHost, 'dapi/$_version/$uriPath', signed, params);
  }

  Future _requestFuturesCoinDataApi(HttpMethod method, String uriPath,
      {bool signed = false, Map<String, dynamic>? params}) async {
    final String _uriHost = _testnet ? BnApiUrls.futuresCoinUrlTestnet : BnApiUrls.futuresCoinUrl;
    return await _request(method, _uriHost, 'futures/data/$uriPath', signed, params);
  }

  Future _requestOptionsApi(HttpMethod method, String uriPath,
      {bool signed = false, Map<String, dynamic>? params}) async {
    final String _uriHost = _testnet ? BnApiUrls.optionsUrlTestnet : BnApiUrls.optionsUrl;
    return await _request(method, _uriHost, 'vapi/${BnApiUrls.optionsApiVersion}/$uriPath', signed, params);
  }

  Future _requestMarginApi(HttpMethod method, String uriPath,
      {bool signed = false, Map<String, dynamic>? params}) async {
    return await _request(method, BnApiUrls.apiUrl, 'sapi/${BnApiUrls.optionsApiVersion}/$uriPath', signed, params);
  }

  Future _requestWebsite(HttpMethod method, String uriPath, {bool signed = false, Map<String, dynamic>? params}) async {
    return await _request(method, BnApiUrls.apiUrl, uriPath, signed, params);
  }

  Future _get(String uriPath, {bool signed = false, String? version, Map<String, dynamic>? params}) async {
    final String _version = version ?? BnApiUrls.publicApiVersion;
    return await _requestApi(HttpMethod.get, uriPath, signed: signed, version: _version, params: params);
  }

  Future _post(String uriPath, {bool signed = false, String? version, Map<String, dynamic>? params}) async {
    final String _version = version ?? BnApiUrls.publicApiVersion;
    return await _requestApi(HttpMethod.post, uriPath, signed: signed, version: _version, params: params);
  }

  Future _put(String uriPath, {bool signed = false, String? version, Map<String, dynamic>? params}) async {
    final String _version = version ?? BnApiUrls.publicApiVersion;
    return await _requestApi(HttpMethod.put, uriPath, signed: signed, version: _version, params: params);
  }

  Future _delete(String uriPath, {bool signed = false, String? version, Map<String, dynamic>? params}) async {
    final String _version = version ?? BnApiUrls.publicApiVersion;
    return await _requestApi(HttpMethod.delete, uriPath, signed: signed, version: _version, params: params);
  }
}
