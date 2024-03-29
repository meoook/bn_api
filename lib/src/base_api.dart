import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

import 'objects.dart';

class ApiResponse {
  /// Response without immediately decode - for flutter compute
  final String data;
  dynamic _json = null;

  ApiResponse(this.data);

  dynamic get json {
    if (_json == null) _json = jsonDecode(data);
    return _json;
  }
}

class BaseClient {
  static const Duration _requestTimeout = Duration(seconds: 10);

  final String? _apiKey;
  final String? _apiSecret;
  final bool _testnet;
  final bool _debug;
  final Map<String, String>? _params;
  Duration timeOffset = Duration(); // in milliseconds

  /// Dictionary of [requestParams] to use for all calls.
  /// Use [testnet] environment - only available for vanilla options at the moment.
  BaseClient({String? apiKey, String? apiSecret, bool? testnet, bool? debug, Map<String, String>? requestParams})
      : _apiKey = apiKey,
        _apiSecret = apiSecret,
        _testnet = testnet ?? false,
        _debug = debug ?? false,
        _params = requestParams;

  Map<String, String> get _headers {
    Map<String, String> headers = {
      HttpHeaders.acceptHeader: 'application/json',
      'User-Agent':
          'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.87 Safari/537.36',
    };
    if (_apiKey != null && _apiKey!.isNotEmpty) {
      headers['X-MBX-APIKEY'] = _apiKey as String;
    }
    return headers;
  }

  String _generateSignature(String queryString) {
    if (_apiSecret == null || _apiSecret!.isEmpty) throw RuntimeException('API Secret required for private endpoints');
    List<int> messageBytes = utf8.encode(queryString);
    List<int> key = utf8.encode(_apiSecret as String);
    Hmac hMac = Hmac(sha256, key);
    Digest digest = hMac.convert(messageBytes);
    return '$digest'; // hex string
  }

  Map<String, dynamic> _getRequestArguments(bool signed, [Map<String, dynamic>? params]) {
    Map<String, dynamic> _result = {};
    // add global requests params
    if (_params != null && _params!.isNotEmpty) _result.addAll(_params!); // TODO: check need
    // add requests params
    if (params != null && params.isNotEmpty) _result.addAll(params);
    // remove null or empty values
    // _result.removeWhere((_, value) => value == null || value.isEmpty);
    // if signed generate signature
    if (signed) {
      _result['timestamp'] = DateTime.now().add(timeOffset).millisecondsSinceEpoch;
      final _tmpUri = Uri(queryParameters: _result.map((key, value) => MapEntry(key, '$value')));
      _result['signature'] = _generateSignature(_tmpUri.query);
    }
    return _result.map((key, value) => MapEntry(key, '$value'));
  }

  Future _doRequest(HttpMethod method, Uri uri, [Map<String, dynamic>? params]) async {
    switch (method) {
      case HttpMethod.get:
        return await http.get(uri, headers: _headers).timeout(_requestTimeout);
      case HttpMethod.post:
        return await http.post(uri, headers: _headers, body: params).timeout(_requestTimeout);
      case HttpMethod.put:
        return await http.put(uri, headers: _headers, body: params).timeout(_requestTimeout);
      case HttpMethod.delete:
        return await http.delete(uri, headers: _headers, body: params).timeout(_requestTimeout);
    }
  }

  Future<ApiResponse> _request(HttpMethod method, String uriHost, String uriPath, bool signed,
      [Map<String, dynamic>? params]) async {
    final Map<String, dynamic> _reqParams = _getRequestArguments(signed, params);
    if (_debug) print('Request ${method.name.toUpperCase()} $uriHost/$uriPath $_reqParams');
    final Uri _uri = (method == HttpMethod.get) ? Uri.https(uriHost, uriPath, _reqParams) : Uri.https(uriHost, uriPath);

    http.Response response;
    try {
      response = await _doRequest(method, _uri, _reqParams);
    } on SocketException catch (_err) {
      throw BnApiException("{'code': 500, 'message': 'Socket error - $_err'}");
    }
    if (response.statusCode >= 300) throw BnApiException(response.body);
    return ApiResponse(response.body);
  }

  Future<ApiResponse> requestApi(HttpMethod method, String uriPath,
      {bool signed = false, String? version, Map<String, dynamic>? params}) async {
    final String _uriHost = _testnet ? BnApiUrls.apiUrlTestnet : BnApiUrls.apiUrl;
    final String _version = signed ? BnApiUrls.privateApiVersion : version ?? BnApiUrls.publicApiVersion;
    return await _request(method, _uriHost, 'api/$_version/$uriPath', signed, params);
  }

  Future<ApiResponse> requestFuturesApi(HttpMethod method, String uriPath,
      {bool signed = false, Map<String, dynamic>? params}) async {
    final String _uriHost = _testnet ? BnApiUrls.futuresUrlTestnet : BnApiUrls.futuresUrl;
    return await _request(method, _uriHost, 'fapi/${BnApiUrls.futuresApiVersion}/$uriPath', signed, params);
  }

  Future<ApiResponse> requestFuturesDataApi(HttpMethod method, String uriPath,
      {bool signed = false, Map<String, dynamic>? params}) async {
    final String _uriHost = _testnet ? BnApiUrls.futuresUrlTestnet : BnApiUrls.futuresUrl;
    return await _request(method, _uriHost, 'futures/data/$uriPath', signed, params);
  }

  Future<ApiResponse> requestFuturesCoinApi(HttpMethod method, String uriPath,
      {bool signed = false, int version = 1, Map<String, dynamic>? params}) async {
    final String _uriHost = _testnet ? BnApiUrls.futuresCoinUrlTestnet : BnApiUrls.futuresCoinUrl;
    final String _version = version == 1 ? BnApiUrls.futuresApiVersion : BnApiUrls.futuresApiVersion2;
    return await _request(method, _uriHost, 'dapi/$_version/$uriPath', signed, params);
  }

  Future<ApiResponse> requestFuturesCoinDataApi(HttpMethod method, String uriPath,
      {bool signed = false, Map<String, dynamic>? params}) async {
    final String _uriHost = _testnet ? BnApiUrls.futuresCoinUrlTestnet : BnApiUrls.futuresCoinUrl;
    return await _request(method, _uriHost, 'futures/data/$uriPath', signed, params);
  }

  Future<ApiResponse> requestOptionsApi(HttpMethod method, String uriPath,
      {bool signed = false, Map<String, dynamic>? params}) async {
    final String _uriHost = _testnet ? BnApiUrls.optionsUrlTestnet : BnApiUrls.optionsUrl;
    return await _request(method, _uriHost, 'vapi/${BnApiUrls.optionsApiVersion}/$uriPath', signed, params);
  }

  Future<ApiResponse> requestMarginApi(HttpMethod method, String uriPath,
      {bool signed = false, Map<String, dynamic>? params}) async {
    return await _request(method, BnApiUrls.apiUrl, 'sapi/${BnApiUrls.optionsApiVersion}/$uriPath', signed, params);
  }

  Future<ApiResponse> requestWebsite(HttpMethod method, String uriPath,
      {bool signed = false, Map<String, dynamic>? params}) async {
    return await _request(method, BnApiUrls.webUrl, uriPath, signed, params);
  }

  Future<ApiResponse> get(String uriPath, {bool signed = false, String? version, Map<String, dynamic>? params}) async {
    final String _version = version ?? BnApiUrls.publicApiVersion;
    return await requestApi(HttpMethod.get, uriPath, signed: signed, version: _version, params: params);
  }

  Future<ApiResponse> post(String uriPath, {bool signed = false, String? version, Map<String, dynamic>? params}) async {
    final String _version = version ?? BnApiUrls.publicApiVersion;
    return await requestApi(HttpMethod.post, uriPath, signed: signed, version: _version, params: params);
  }

  Future<ApiResponse> put(String uriPath, {bool signed = false, String? version, Map<String, dynamic>? params}) async {
    final String _version = version ?? BnApiUrls.publicApiVersion;
    return await requestApi(HttpMethod.put, uriPath, signed: signed, version: _version, params: params);
  }

  Future<ApiResponse> delete(String uriPath,
      {bool signed = false, String? version, Map<String, dynamic>? params}) async {
    final String _version = version ?? BnApiUrls.publicApiVersion;
    return await requestApi(HttpMethod.delete, uriPath, signed: signed, version: _version, params: params);
  }
}
