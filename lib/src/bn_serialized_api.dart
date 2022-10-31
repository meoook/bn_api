import 'bn_api.dart';
import 'objects.dart';
import 'objects/acc_objects.dart';
import 'objects/orders_objects.dart';

class BnSerializedApi {
  final BnApi _api;

  BnSerializedApi({String? apiKey, String? apiSecret}) : _api = BnApi(apiKey: apiKey, apiSecret: apiSecret);

  Future<List<SymbolProduct>> productList() async {
    final List _data = await _api.getProducts().then((r) => r.json['data']);
    return List<SymbolProduct>.from(_data.map((e) => SymbolProduct(e)));
  }

  Future<ExchangeInfo> getExchangeInfo() async {
    final Map _data = await _api.getExchangeInfo().then((r) => r.json);
    return ExchangeInfo(_data);
  }

  Future<AccPermissions> getAccountApiPermissions() async {
    final Map _data = await _api.getAccountApiPermissions().then((r) => r.json);
    return AccPermissions(_data);
  }

  Future<AccInfo> getAccount() async {
    final Map _data = await _api.getAccount().then((r) => r.json);
    return AccInfo(_data);
  }

  Future<List<MarginOrder>> getOpenMarginOrders({String? symbol, bool? isIsolated}) async {
    final List _data = await _api.getOpenMarginOrders(symbol: symbol, isIsolated: isIsolated).then((r) => r.json);
    return List<MarginOrder>.from(_data.map((e) => MarginOrder(e)));
  }

  Future<MarginOrder> getMarginOrder(
      {String? symbol, bool? isIsolated, int? orderId, String? origClientOrderId}) async {
    final Map _data = await _api
        .getMarginOrder(symbol: symbol, isIsolated: isIsolated, orderId: orderId, origClientOrderId: origClientOrderId)
        .then((r) => r.json);
    return MarginOrder(_data);
  }

  Future<MarginOrder> cancelMarginOrder(
      {String? symbol, bool? isIsolated, int? orderId, String? origClientOrderId, String? newClientOrderId}) async {
    final Map _data = await _api
        .cancelMarginOrder(
            symbol: symbol,
            isIsolated: isIsolated,
            orderId: orderId,
            origClientOrderId: origClientOrderId,
            newClientOrderId: newClientOrderId)
        .then((r) => r.json);
    print('CANCEL RESULT $_data');
    return MarginOrder(_data);
  }
}
