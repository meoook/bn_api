import 'bn_api.dart';
import 'objects.dart';

class BnSerializedApi {
  final BnApi _api;

  BnSerializedApi({String? apiKey, String? apiSecret, bool debug = false})
      : _api = BnApi(apiKey: apiKey, apiSecret: apiSecret, debug: debug);

  // ========= General Endpoints ===============
  Future<BnApiSystemStatus> serverGetStatus() async {
    final Map _data = await _api.serverGetStatus().then((r) => r.json);
    return BnApiSystemStatus(_data);
  }

  Future<List<BnApiCoinInfo>> coinsGetInfo() async {
    final List _data = await _api.coinsGetInfo().then((r) => r.json);
    return List<BnApiCoinInfo>.from(_data.map((e) => BnApiCoinInfo(e)));
  }

  // ========= Account Endpoints ===============
  Future<List<dynamic>> accountGetSnapshot({required String type, int? limit, int? startTime, int? endTime}) async {
    final Map _data = await _api
        .accountGetSnapshot(type: type, limit: limit, startTime: startTime, endTime: endTime)
        .then((r) => r.json);
    return List.from(_data['snapshotVos'].map((e) {
      if (e['type'].toUpperCase() == BnApiTradeType.spot) return BnApiAccountSnapshotSpot(e);
      if (e['type'].toUpperCase() == BnApiTradeType.margin) return BnApiAccountSnapshotMargin(e);
      if (e['type'].toUpperCase() == BnApiTradeType.futures) return BnApiAccountSnapshotFutures(e);
    }));
  }

  Future<List<BnApiAccountDepositHistoryItem>> accountGetDepositHistory(
      {String? coin, int? status, int? startTime, int? endTime, int? offset, int? limit}) async {
    final List _data = await _api
        .accountGetDepositHistory(
            coin: coin, status: status, startTime: startTime, endTime: endTime, offset: offset, limit: limit)
        .then((r) => r.json);
    return List<BnApiAccountDepositHistoryItem>.from(_data.map((e) => BnApiAccountDepositHistoryItem(e)));
  }

  Future<List<BnApiAccountWithdrawHistoryItem>> accountGetWithdrawHistory(
      {String? coin,
      String? withdrawOrderId,
      int? status,
      int? offset,
      int? limit,
      int? startTime,
      int? endTime}) async {
    final List _data = await _api
        .accountGetWithdrawHistory(
            coin: coin,
            withdrawOrderId: withdrawOrderId,
            status: status,
            offset: offset,
            limit: limit,
            startTime: startTime,
            endTime: endTime)
        .then((r) => r.json);
    return List<BnApiAccountWithdrawHistoryItem>.from(_data.map((e) => BnApiAccountWithdrawHistoryItem(e)));
  }

  Future<BnApiAccountDepositAddress> accountGetDepositAddress({required String coin, String? network}) async {
    final Map _data = await _api.accountGetDepositAddress(coin: coin, network: network).then((r) => r.json);
    return BnApiAccountDepositAddress(_data);
  }

  // =================================================================================================================

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

  Future<AvgPrice> getAvgPrice(String symbol) async => _api.getAvgPrice(symbol).then((r) => AvgPrice(r.json));

  Future<MarginAsset> getMarginAsset(String asset) async => _api.getMarginAsset(asset).then((r) => MarginAsset(r.json));

  Future<List<MarginTrade>> getMarginTrades(String symbol,
      {bool? isIsolated, int? orderId, int? startTime, int? endTime, int? fromId, int? limit}) async {
    final List _data = await _api
        .getMarginTrades(symbol,
            isIsolated: isIsolated,
            orderId: orderId,
            startTime: startTime,
            endTime: endTime,
            fromId: fromId,
            limit: limit)
        .then((r) => r.json);
    return List<MarginTrade>.from(_data.map((e) => MarginTrade(e)));
  }

  Future<MarginLevelInfo> getMarginLevelInfo(String asset) async {
    return await _api.getMarginLevelInfo(asset).then((r) => MarginLevelInfo(r.json));
  }

  Future<List<IsolatedMarginTransfer>> getIsolatedTransferHistory(
    String symbol, {
    String? asset,
    String? transFrom, // SPOT, ISOLATED_MARGIN
    String? transTo, // SPOT, ISOLATED_MARGIN
    int? startTime,
    int? endTime,
    int? current, // Current page, default 1
    int? size, // Default 10, max 100
    bool? archived, // Default: false. Set to true for archived data from 6 months ago
  }) async {
    final Map _data = await _api
        .getIsolatedTransferHistory(symbol,
            asset: asset,
            transFrom: transFrom,
            transTo: transTo,
            startTime: startTime,
            endTime: endTime,
            current: current,
            size: size,
            archived: archived)
        .then((r) => r.json);
    return List<IsolatedMarginTransfer>.from(_data['rows'].map((e) => IsolatedMarginTransfer(e)));
  }

  Future<IsolatedMarginAccountInfo> getIsolatedMarginAccount([String? symbols]) async {
    return await _api.getIsolatedMarginAccount(symbols).then((r) => IsolatedMarginAccountInfo(r.json));
  }

  Future<List<IsolatedMarginSymbol>> getAllIsolatedMarginSymbols() async {
    return await _api.getAllIsolatedMarginSymbols().then((r) => List.from(r.json.map((e) => IsolatedMarginSymbol(e))));
  }

  Future<List<IsolatedMarginFee>> getIsolatedMarginFee({String? symbol, int? vipLevel}) async {
    return await _api
        .getIsolatedMarginFee(symbol: symbol, vipLevel: vipLevel)
        .then((r) => List.from(r.json.map((e) => IsolatedMarginFee(e))));
  }
}
