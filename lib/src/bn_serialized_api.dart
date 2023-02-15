import 'bn_api.dart';
import 'objects.dart';

class BnSerializedApi {
  final BnApi _api;

  BnSerializedApi({String? apiKey, String? apiSecret, bool debug = false, bool? testnet = false})
      : _api = BnApi(apiKey: apiKey, apiSecret: apiSecret, debug: debug, testnet: testnet);

  // ========= General Endpoints ===============
  Future<BnApiSystemStatus> serverGetStatus() async {
    final Map data = await _api.serverGetStatus().then((r) => r.json);
    return BnApiSystemStatus(data);
  }

  Future<List<BnApiCoinInfo>> coinsGetInfo() async {
    final List data = await _api.coinsGetInfo().then((r) => r.json);
    return List<BnApiCoinInfo>.from(data.map((e) => BnApiCoinInfo(e)));
  }

  Future<List<BnApiAssetWithdrawDetail>> assetsGetWithdrawDetail({String? asset}) async {
    final Map data = await _api.assetsGetWithdrawDetail(asset: asset).then((r) => r.json);
    return List<BnApiAssetWithdrawDetail>.from(data.entries.map((e) => BnApiAssetWithdrawDetail(e.key, e.value)));
  }

  Future<List<BnApiSymbolTradeFee>> symbolsTradeFee({String? symbol}) async {
    final List data = await _api.symbolsTradeFee(symbol: symbol).then((r) => r.json);
    return List<BnApiSymbolTradeFee>.from(data.map((e) => BnApiSymbolTradeFee(e)));
  }

  // ========= Account Endpoints ===============
  Future<List<dynamic>> accountGetSnapshot({required String type, int? limit, int? startTime, int? endTime}) async {
    final Map data = await _api
        .accountGetSnapshot(type: type, limit: limit, startTime: startTime, endTime: endTime)
        .then((r) => r.json);
    return List.from(data['snapshotVos'].map((e) {
      if (e['type'].toUpperCase() == BnApiTradeType.spot) return BnApiAccountSnapshotSpot(e);
      if (e['type'].toUpperCase() == BnApiTradeType.margin) return BnApiAccountSnapshotMargin(e);
      if (e['type'].toUpperCase() == BnApiTradeType.futures) return BnApiAccountSnapshotFutures(e);
    }));
  }

  Future<List<BnApiAccountDepositHistoryItem>> accountGetDepositHistory(
      {String? coin, int? status, int? startTime, int? endTime, int? offset, int? limit}) async {
    final List data = await _api
        .accountGetDepositHistory(
            coin: coin, status: status, startTime: startTime, endTime: endTime, offset: offset, limit: limit)
        .then((r) => r.json);
    return List<BnApiAccountDepositHistoryItem>.from(data.map((e) => BnApiAccountDepositHistoryItem(e)));
  }

  Future<List<BnApiAccountWithdrawHistoryItem>> accountGetWithdrawHistory({
    String? coin,
    String? withdrawOrderId,
    int? status,
    int? offset,
    int? limit,
    int? startTime,
    int? endTime,
  }) async {
    final List data = await _api
        .accountGetWithdrawHistory(
            coin: coin,
            withdrawOrderId: withdrawOrderId,
            status: status,
            offset: offset,
            limit: limit,
            startTime: startTime,
            endTime: endTime)
        .then((r) => r.json);
    return List<BnApiAccountWithdrawHistoryItem>.from(data.map((e) => BnApiAccountWithdrawHistoryItem(e)));
  }

  Future<BnApiAccountDepositAddress> accountGetDepositAddress({required String coin, String? network}) async {
    final Map data = await _api.accountGetDepositAddress(coin: coin, network: network).then((r) => r.json);
    return BnApiAccountDepositAddress(data);
  }

  Future<BnApiAccountTradingStatus> accountGetTradingStatus() async {
    final Map data = await _api.accountGetTradingStatus().then((r) => r.json);
    return BnApiAccountTradingStatus(data['data']);
  }

  Future<List<BnApiAccountBnbExchange>> accountGetDustLog({int? startTime, int? endTime}) async {
    final Map data = await _api.accountGetDustLog(startTime: startTime, endTime: endTime).then((r) => r.json);
    return List<BnApiAccountBnbExchange>.from(data['userAssetDribblets'].map((e) => BnApiAccountBnbExchange(e)));
  }

  Future<BnApiAccountAssetsAvailableToConvert> accountGetAvailableToConvert() async {
    final Map data = await _api.accountGetAvailableToConvert().then((r) => r.json);
    return BnApiAccountAssetsAvailableToConvert(data);
  }

  Future<BnApiAccountAssetsConverted> accountGetConvertToBnb({required List<String> assets}) async {
    final Map data = await _api.accountConvertToBnb(assets: assets).then((r) => r.json);
    return BnApiAccountAssetsConverted(data);
  }

  Future<List<BnApiAccountAssetDividend>> accountAssetsDividends(
      {String? asset, int? startTime, int? endTime, int? limit}) async {
    final Map data = await _api
        .accountAssetsDividends(asset: asset, startTime: startTime, endTime: endTime, limit: limit)
        .then((r) => r.json);
    return List<BnApiAccountAssetDividend>.from(data['rows'].map((e) => BnApiAccountAssetDividend(e)));
  }

  Future<List<BnApiAccountTransferItem>> accountUniversalTransferHistory({
    required String type, // BnApiUniversalTransfer
    int? startTime,
    int? endTime,
    int? current, // Default 1
    int? size, // Default 10, Max 100
    String? fromSymbol,
    String? toSymbol,
  }) async {
    final Map data = await _api
        .accountUniversalTransferHistory(
            type: type,
            startTime: startTime,
            endTime: endTime,
            current: current,
            size: size,
            fromSymbol: fromSymbol,
            toSymbol: toSymbol)
        .then((r) => r.json);
    if (data['total'] == 0) return [];
    return List<BnApiAccountTransferItem>.from(data['rows'].map((e) => BnApiAccountTransferItem(e)));
  }

  Future<List<BnApiAccountFundingWallet>> accountFundingWallet({String? asset, bool? needBtcValuation}) async {
    final List data =
        await _api.accountFundingWallet(asset: asset, needBtcValuation: needBtcValuation).then((r) => r.json);
    return List<BnApiAccountFundingWallet>.from(data.map((e) => BnApiAccountFundingWallet(e)));
  }

  Future<List<BnApiAccountFundingWallet>> accountUserAsset({String? asset, bool? needBtcValuation}) async {
    final List data = await _api.accountUserAsset(asset: asset, needBtcValuation: needBtcValuation).then((r) => r.json);
    return List<BnApiAccountFundingWallet>.from(data.map((e) => BnApiAccountFundingWallet(e)));
  }

  Future<BnApiAccountBusdConvert> accountConvertBusd({
    required String clientTranId,
    required String asset,
    required double amount,
    required String targetAsset,
    String? accountType,
  }) async {
    final Map data = await _api
        .accountConvertBusd(
            clientTranId: clientTranId,
            asset: asset,
            amount: amount,
            targetAsset: targetAsset,
            accountType: accountType)
        .then((r) => r.json);
    return BnApiAccountBusdConvert(data);
  }

  Future<List<BnApiAccountBusdConvertItem>> accountConvertBusdHistory({
    int? tranId,
    String? clientTranId,
    String? asset,
    required int startTime,
    required int endTime,
    String? accountType,
    int? current,
    int? size,
  }) async {
    final Map data = await _api
        .accountConvertBusdHistory(
            tranId: tranId,
            clientTranId: clientTranId,
            startTime: startTime,
            endTime: endTime,
            accountType: accountType,
            current: current,
            size: size)
        .then((r) => r.json);
    return List<BnApiAccountBusdConvertItem>.from(data['rows'].map((e) => BnApiAccountBusdConvertItem(e)));
  }

  Future<List<BnApiAccountCloudMining>> accountCloudMiningHistory({
    int? tranId,
    String? clientTranId,
    String? asset,
    required int startTime,
    required int endTime,
    String? accountType,
    int? current,
    int? size,
  }) async {
    final Map data = await _api
        .accountCloudMiningHistory(
            tranId: tranId,
            clientTranId: clientTranId,
            startTime: startTime,
            endTime: endTime,
            accountType: accountType,
            current: current,
            size: size)
        .then((r) => r.json);
    return List<BnApiAccountCloudMining>.from(data['rows'].map((e) => BnApiAccountCloudMining(e)));
  }

  Future<BnApiAccountPermissions> accountApiPermissions() async {
    final Map data = await _api.accountApiPermissions().then((r) => r.json);
    return BnApiAccountPermissions(data);
  }

  Future<BnApiConvertingStableCoins> accountConvertingStableCoins() async {
    final Map data = await _api.accountConvertingStableCoins().then((r) => r.json);
    return BnApiConvertingStableCoins(data);
  }

  Future<bool> accountConvertStableCoins({required String coin, required bool enable}) async {
    return await _api.accountConvertStableCoins(coin: coin, enable: enable);
  }

  // ========= Margin Account/Trade Endpoints ===============
  Future<List<BnApiMarginBorrowItem>> marginAccountBorrowDetails({
    required String asset,
    String? isolatedSymbol, // isolated symbol
    int? txId, // the tranId in [marginAccountBorrow]
    int? startTime,
    int? endTime,
    int? current, // Currently querying page. Start from 1. Default:1
    int? size, // Default:10 Max:100
    bool? archived,
  }) async {
    final Map data = await _api
        .marginAccountBorrowDetails(
            asset: asset,
            isolatedSymbol: isolatedSymbol,
            txId: txId,
            startTime: startTime,
            endTime: endTime,
            current: current,
            size: size,
            archived: archived)
        .then((r) => r.json);
    return List<BnApiMarginBorrowItem>.from(data['rows'].map((e) => BnApiMarginBorrowItem(e)));
  }

  Future<List<BnApiMarginRepayItem>> marginAccountRepayDetails({
    required String asset,
    String? isolatedSymbol, // isolated symbol
    int? txId, // the tranId in [marginAccountBorrow]
    int? startTime,
    int? endTime,
    int? current, // Currently querying page. Start from 1. Default:1
    int? size, // Default:10 Max:100
    bool? archived,
  }) async {
    final Map data = await _api
        .marginAccountRepayDetails(
            asset: asset,
            isolatedSymbol: isolatedSymbol,
            txId: txId,
            startTime: startTime,
            endTime: endTime,
            current: current,
            size: size,
            archived: archived)
        .then((r) => r.json);
    return List<BnApiMarginRepayItem>.from(data['rows'].map((e) => BnApiMarginRepayItem(e)));
  }

  Future<BnApiMarginAsset> marginAsset({required String asset}) async =>
      await _api.marginAsset(asset: asset).then((r) => BnApiMarginAsset(r.json));

  Future<List<BnApiMarginAsset>> marginAllAsset() async {
    final List data = await _api.marginAllAsset().then((r) => r.json);
    return List<BnApiMarginAsset>.from(data.map((e) => BnApiMarginAsset(e)));
  }

  Future<BnApiMarginSymbol> marginSymbol({required String symbol}) async =>
      await _api.marginSymbol(symbol: symbol).then((r) => BnApiMarginSymbol(r.json));

  Future<List<BnApiMarginSymbol>> marginAllSymbol() async {
    final List data = await _api.marginAllSymbol().then((r) => r.json);
    return List<BnApiMarginSymbol>.from(data.map((e) => BnApiMarginSymbol(e)));
  }

  Future<BnApiMarginPriceIndex> marginPriceIndex({required String symbol}) async =>
      await _api.marginPriceIndex(symbol: symbol).then((r) => BnApiMarginPriceIndex(r.json));

  Future<BnApiMarginOrder> marginCreateOrder({
    required String symbol,
    required String side, // BnApiOrderSide: BUY,SELL
    required String type,
    bool? isIsolated, // isolated margin or not, default false
    String? timeInForce, // BnApiTimeInForce: GTC,IOC,FOK
    double? quantity,
    double? quoteOrderQty,
    double? price,
    double? stopPrice, // Used with STOP_LOSS, STOP_LOSS_LIMIT, TAKE_PROFIT, and TAKE_PROFIT_LIMIT orders
    String? newClientOrderId, // A unique id among open orders. Automatically generated if not sent
    double? icebergQty, // Used with LIMIT, STOP_LOSS_LIMIT, and TAKE_PROFIT_LIMIT to create an iceberg order
    String? newOrderRespType, // BnApiOrderRespType: ACK, RESULT, FULL
    String? sideEffectType, // BnApiOrderSideEffect: NO_SIDE_EFFECT(default), MARGIN_BUY, AUTO_REPAY
  }) async {
    final Map data = await _api
        .marginCreateOrder(
          symbol: symbol,
          side: side,
          type: type,
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
    return BnApiMarginOrder(data);
  }

  Future<BnApiMarginOrder> marginCancelOrder({
    required String symbol,
    bool? isIsolated, // isolated margin or not, default false
    int? orderId,
    String? origClientOrderId,
    String? newClientOrderId, // Used to uniquely identify this cancel. Automatically generated by default
  }) async {
    final Map data = await _api
        .marginCancelOrder(
            symbol: symbol,
            isIsolated: isIsolated,
            orderId: orderId,
            origClientOrderId: origClientOrderId,
            newClientOrderId: newClientOrderId)
        .then((r) => r.json);
    return BnApiMarginOrder(data);
  }

  Future<List<BnApiMarginOrder>> marginCancelOrders({required String symbol, bool? isIsolated}) async {
    final List data = await _api.marginCancelOrders(symbol: symbol, isIsolated: isIsolated).then((r) => r.json);
    return List<BnApiMarginOrder>.from(data.map((e) => BnApiMarginOrder(e)));
  }

  Future<List<BnApiMarginTransferItem>> marginTransferWithSpotHistory({
    String? asset,
    String? type, // Transfer Type: ROLL_IN, ROLL_OUT
    int? startTime,
    int? endTime,
    int? current, // Currently querying page. Start from 1. Default:1
    int? size, // Default:10 Max:100
    bool? archived, // Default: false. Set to true for archived data from 6 months ago
  }) async {
    final Map data = await _api
        .marginTransferWithSpotHistory(
            asset: asset,
            type: type,
            startTime: startTime,
            endTime: endTime,
            current: current,
            size: size,
            archived: archived)
        .then((r) => r.json);
    return List<BnApiMarginTransferItem>.from(data['rows'].map((e) => BnApiMarginTransferItem(e)));
  }

  Future<List<BnApiMarginInterestHistoryItem>> marginInterestHistory({
    String? asset,
    String? isolatedSymbol, // isolated symbol
    int? startTime,
    int? endTime,
    int? current, // Currently querying page. Start from 1. Default:1
    int? size, // Default:10 Max:100
    bool? archived, // Default: false. Set to true for archived data from 6 months ago
  }) async {
    final Map data = await _api
        .marginInterestHistory(
            asset: asset,
            isolatedSymbol: isolatedSymbol,
            startTime: startTime,
            endTime: endTime,
            current: current,
            size: size,
            archived: archived)
        .then((r) => r.json);
    return List<BnApiMarginInterestHistoryItem>.from(data['rows'].map((e) => BnApiMarginInterestHistoryItem(e)));
  }

  Future<List<BnApiMarginForceLiquidationItem>> marginForceLiquidationRec({
    String? isolatedSymbol, // isolated symbol
    int? startTime,
    int? endTime,
    int? current, // Currently querying page. Start from 1. Default:1
    int? size, // Default:10 Max:100
  }) async {
    final Map data = await _api
        .marginForceLiquidationRec(
            isolatedSymbol: isolatedSymbol, startTime: startTime, endTime: endTime, current: current, size: size)
        .then((r) => r.json);
    return List<BnApiMarginForceLiquidationItem>.from(data['rows'].map((e) => BnApiMarginForceLiquidationItem(e)));
  }

  Future<BnApiCrossMarginAccountInfo> marginAccount() async {
    final Map data = await _api.marginAccount().then((r) => r.json);
    return BnApiCrossMarginAccountInfo(data);
  }

  Future<BnApiMarginOrderGet> marginGetOrder(
      {required String symbol, bool? isIsolated, int? orderId, String? origClientOrderId}) async {
    final Map data = await _api
        .marginGetOrder(symbol: symbol, isIsolated: isIsolated, orderId: orderId, origClientOrderId: origClientOrderId)
        .then((r) => r.json);
    return BnApiMarginOrderGet(data);
  }

  Future<List<BnApiMarginOrderGet>> marginGetOpenOrders({String? symbol, bool? isIsolated}) async {
    final List data = await _api.marginGetOpenOrders(symbol: symbol, isIsolated: isIsolated).then((r) => r.json);
    return List<BnApiMarginOrderGet>.from(data.map((e) => BnApiMarginOrderGet(e)));
  }

  Future<List<BnApiMarginOrderGet>> marginGetAllOrders({
    required String symbol,
    bool? isIsolated, // isolated margin or not, default false
    int? orderId,
    int? startTime,
    int? endTime,
    int? limit, // Default 500; max 500
  }) async {
    final List data = await _api
        .marginGetAllOrders(
            symbol: symbol,
            isIsolated: isIsolated,
            orderId: orderId,
            startTime: startTime,
            endTime: endTime,
            limit: limit)
        .then((r) => r.json);
    return List<BnApiMarginOrderGet>.from(data.map((e) => BnApiMarginOrderGet(e)));
  }

  Future<List<BnApiMarginTrade>> marginGetTrades({
    required String symbol,
    bool? isIsolated, // isolated margin or not, default false
    int? orderId,
    int? startTime,
    int? endTime,
    int? fromId, // TradeId to fetch from. Default gets most recent trades
    int? limit, // Default 500; max 1000.
  }) async {
    final List _data = await _api
        .marginGetTrades(
            symbol: symbol,
            isIsolated: isIsolated,
            orderId: orderId,
            startTime: startTime,
            endTime: endTime,
            fromId: fromId,
            limit: limit)
        .then((r) => r.json);
    return List<BnApiMarginTrade>.from(_data.map((e) => BnApiMarginTrade(e)));
  }

  // print('Data: $data');
// =================================================================================================================

  Future<List<SymbolProduct>> productList() async {
    final List _data = await _api.getProducts().then((r) => r.json['data']);
    return List<SymbolProduct>.from(_data.map((e) => SymbolProduct(e)));
  }

  Future<ExchangeInfo> getExchangeInfo() async {
    final Map _data = await _api.getExchangeInfo().then((r) => r.json);
    return ExchangeInfo(_data);
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

  Future<AvgPrice> getAvgPrice(String symbol) async => _api.getAvgPrice(symbol).then((r) => AvgPrice(r.json));

  Future<BnApiMarginLevelInfo> marginGetLevelInfo() async {
    return await _api.marginGetLevelInfo().then((r) => BnApiMarginLevelInfo(r.json));
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
