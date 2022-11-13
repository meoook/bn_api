import 'bn_api.dart';
import 'objects.dart';

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

  Future<List> getKLines(String symbol, String interval, {int? limit, int? startTime, int? endTime}) async {
    final List _data = await _api
        .getKLines(symbol, interval, limit: limit, startTime: startTime, endTime: endTime)
        .then((r) => r.json);
    return List.from(_data.map((e) => CandleStick(e)));
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

  Future<MarginCreatedOrder> createMarginOrder(
    String symbol,
    String side, // BUY,SELL
    String orderType, {
    bool? isIsolated,
    String? timeInForce, // GTC,IOC,FOK
    double? quantity,
    double? quoteOrderQty,
    double? price,
    double? stopPrice, // Used with STOP_LOSS, STOP_LOSS_LIMIT, TAKE_PROFIT, and TAKE_PROFIT_LIMIT orders.
    String? newClientOrderId, // A unique id among open orders. Automatically generated if not sent.
    double? icebergQty, // Used with LIMIT, STOP_LOSS_LIMIT, and TAKE_PROFIT_LIMIT to create an iceberg order.
    String? newOrderRespType, // Set the response JSON. ACK, RESULT, or FULL;
    String? sideEffectType, // NO_SIDE_EFFECT, MARGIN_BUY, AUTO_REPAY; default NO_SIDE_EFFECT
  }) async {
    final Map _data = await _api
        .createMarginOrder(
          symbol,
          side,
          orderType,
          isIsolated: isIsolated,
          timeInForce: timeInForce,
          quantity: quantity,
          quoteOrderQty: quoteOrderQty,
          price: price,
          stopPrice: stopPrice,
          newClientOrderId: newClientOrderId,
          icebergQty: icebergQty,
          newOrderRespType: newOrderRespType,
          sideEffectType: sideEffectType,
        )
        .then((r) => r.json);
    return MarginCreatedOrder(_data);
  }

  Future<MarginCancelOrder> cancelMarginOrder(
      {String? symbol, bool? isIsolated, int? orderId, String? origClientOrderId, String? newClientOrderId}) async {
    final Map _data = await _api
        .cancelMarginOrder(
            symbol: symbol,
            isIsolated: isIsolated,
            orderId: orderId,
            origClientOrderId: origClientOrderId,
            newClientOrderId: newClientOrderId)
        .then((r) => r.json);
    return MarginCancelOrder(_data);
  }

  Future getAvgPrice(String symbol) async => _api.getAvgPrice(symbol).then((r) => AvgPrice(r.json));
}
