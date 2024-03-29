import 'base_api.dart';
import 'objects.dart';

class BnApi extends BaseClient {
  BnApi({String? apiKey, String? apiSecret, bool? testnet, bool? debug, Map<String, String>? requestParams})
      : super(apiKey: apiKey, apiSecret: apiSecret, testnet: testnet, debug: debug, requestParams: requestParams) {
    _init();
  }

  void _init() async {
    try {
      await ping();
      // calculate timestamp offset between local and binance server
      final srvTime = await serverGetTime();
      final DateTime now = DateTime.now();
      timeOffset = Duration(milliseconds: srvTime - now.millisecondsSinceEpoch);
    } catch (err) {
      throw RuntimeException('failed to init API $err');
    }
  }

  // =================================================================================================================
  // General Endpoints
  // =================================================================================================================

  Future<bool> ping() => get('ping', version: BnApiUrls.privateApiVersion).then((r) => true);

  Future<int> serverGetTime() => get('time', version: BnApiUrls.privateApiVersion).then((r) => r.json['serverTime']);

  /// https://binance-docs.github.io/apidocs/spot/en/#system-status-system
  Future<ApiResponse> serverGetStatus() async {
    return await requestMarginApi(HttpMethod.get, 'system/status');
  }

  /// All Coins Information
  /// https://binance-docs.github.io/apidocs/spot/en/#all-coins-39-information-user_data
  Future<ApiResponse> coinsGetInfo() async {
    return await requestMarginApi(HttpMethod.get, 'capital/config/getall', signed: true);
  }

  /// Assets details supported on Binance
  /// Get network and other deposit or withdraw details from [coinsGetInfo]
  /// https://binance-docs.github.io/apidocs/spot/en/#asset-detail-user_data
  Future<ApiResponse> assetsGetWithdrawDetail({String? asset}) async {
    final params = {if (asset != null) 'asset': asset};
    return await requestMarginApi(HttpMethod.get, 'asset/assetDetail', signed: true, params: params);
  }

  /// Trade fee for symbols
  /// https://binance-docs.github.io/apidocs/spot/en/#trade-fee-user_data
  Future<ApiResponse> symbolsTradeFee({String? symbol}) async {
    final params = {if (symbol != null) 'symbol': symbol};
    return await requestMarginApi(HttpMethod.get, 'asset/tradeFee', signed: true, params: params);
  }

  // =================================================================================================================
  // Account Endpoints
  // =================================================================================================================

  /// Daily Account Snapshot
  /// The [limit] time period must be less then 30 days
  /// If [startTime] and [endTime] not sent, return records of the last 7 days by default
  /// https://binance-docs.github.io/apidocs/spot/en/#daily-account-snapshot-user_data
  Future<ApiResponse> accountGetSnapshot({required String type, int? limit, int? startTime, int? endTime}) async {
    final Map<String, dynamic> params = {
      'type': type, // BnApiTradeType: SPOT, MARGIN, FUTURES
      if (limit != null) 'limit': limit, // Default 7, min 7, max 30
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    };
    return await requestMarginApi(HttpMethod.get, 'accountSnapshot', signed: true, params: params);
  }

  /// Enable Fast Withdraw Switch
  /// You need to enable "trade" option for the api key which requests this endpoint.
  /// https://binance-docs.github.io/apidocs/spot/en/#enable-fast-withdraw-switch-user_data
  Future<bool> accountEnableFastWithdraw() async {
    return await requestMarginApi(HttpMethod.get, 'account/enableFastWithdrawSwitch', signed: true).then((r) => true);
  }

  /// Disable Fast Withdraw Switch
  /// You need to enable "trade" option for the api key which requests this endpoint.
  /// https://binance-docs.github.io/apidocs/spot/en/#disable-fast-withdraw-switch-user_data
  Future<bool> accountDisableFastWithdraw() async {
    return await requestMarginApi(HttpMethod.get, 'account/disableFastWithdrawSwitch', signed: true).then((r) => true);
  }

  /// Submit a withdraw request
  /// If [network] not send, return with default network of the coin
  /// You can get [network] and isDefault in networkList of a coin in the response of [coinsGetInfo]
  /// https://binance-docs.github.io/apidocs/spot/en/#withdraw-user_data
  Future<String> accountWithdraw({
    required String coin,
    required String address,
    required double amount,
    String? withdrawOrderId, // client id for withdraw
    String? network,
    String? addressTag, // Secondary address identifier for coins like XRP,XMR etc
    bool? transactionFeeFlag, // Internal transfer, true/false for returning fee to destination/departure account
    String? name, // Description of the address. Space in name should be encoded into %20
    int? walletType, // Wallet type for withdraw，0-spot wallet ，1-funding wallet
  }) async {
    final params = {
      'coin': coin,
      'address': address,
      'amount': amount,
      if (withdrawOrderId != null) 'withdrawOrderId': withdrawOrderId,
      if (network != null) 'network': network,
      if (addressTag != null) 'addressTag': addressTag,
      if (transactionFeeFlag != null) 'transactionFeeFlag': transactionFeeFlag,
      if (name != null) 'name': name,
      if (walletType != null) 'walletType': walletType,
    };
    return await requestMarginApi(HttpMethod.post, 'capital/withdraw/apply', signed: true, params: params)
        .then((r) => r.json['id']); // 7213fea8e94b4a5593d507237e5a555b
  }

  /// Fetch deposit history (supporting network)
  /// If both [startTime] and [endTime] are sent, time between [startTime] and [endTime] must be less than 90 days
  /// https://binance-docs.github.io/apidocs/spot/en/#deposit-history-supporting-network-user_data
  Future<ApiResponse> accountGetDepositHistory({
    String? coin,
    int? status, // 0:pending, 6:credited but cannot withdraw, 1:success
    int? startTime, // Default: 90 days from current timestamp
    int? endTime, // Default: present timestamp
    int? offset, // Default: 0
    int? limit, // Default: 1000, Max: 1000
  }) async {
    final params = {
      if (coin != null) 'coin': coin,
      if (status != null) 'status': status,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (offset != null) 'offset': offset,
      if (limit != null) 'limit': limit,
    };
    return await requestMarginApi(HttpMethod.get, 'capital/deposit/hisrec', signed: true, params: params);
  }

  /// Fetch withdraw history (supporting network)
  /// If both [startTime] and [endTime] are sent, time between [startTime] and [endTime] must be less than 90 days
  /// If [withdrawOrderId] is sent, time between [startTime] and [endTime] must be less than 7 days
  /// If [withdrawOrderId] is sent, [startTime] and [endTime] are not sent, will return last 7 days records by default
  /// https://binance-docs.github.io/apidocs/spot/en/#withdraw-history-supporting-network-user_data
  Future<ApiResponse> accountGetWithdrawHistory({
    String? coin,
    String? withdrawOrderId,
    int? status, // 0:Email Sent, 1:Cancelled, 2:Awaiting Approval, 3:Rejected, 4:Processing, 5:Failure, 6:Completed
    int? offset,
    int? limit, // Default: 1000, Max: 1000
    int? startTime, // Default: 90 days from current timestamp
    int? endTime, // Default: present timestamp
  }) async {
    final params = {
      if (coin != null) 'coin': coin,
      if (withdrawOrderId != null) 'withdrawOrderId': withdrawOrderId,
      if (status != null) 'status': status,
      if (offset != null) 'offset': offset,
      if (limit != null) 'limit': limit,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    };
    return await requestMarginApi(HttpMethod.get, 'capital/withdraw/history', signed: true, params: params);
  }

  /// Fetch deposit address with network
  /// If [network] is not send, return with default [network] of the coin
  /// You can get [network] and isDefault in networkList of a coin in the response of [coinsGetInfo]
  /// https://binance-docs.github.io/apidocs/spot/en/#deposit-address-supporting-network-user_data
  Future<ApiResponse> accountGetDepositAddress({required String coin, String? network}) async {
    final params = {'coin': coin, if (network != null) 'network': network};
    return await requestMarginApi(HttpMethod.get, 'capital/deposit/address', signed: true, params: params);
  }

  /// https://binance-docs.github.io/apidocs/spot/en/#account-status-user_data
  Future<String> accountGetStatus() async {
    return await requestMarginApi(HttpMethod.get, 'account/status', signed: true).then((r) => r.json['data']); // Normal
  }

  /// Account API Trading Status
  /// https://binance-docs.github.io/apidocs/spot/en/#account-api-trading-status-user_data
  Future<ApiResponse> accountGetTradingStatus() async {
    return await requestMarginApi(HttpMethod.get, 'account/apiTradingStatus', signed: true);
  }

  /// Dust Log (Exchange assets to BNB)
  /// return last 100 records
  /// https://binance-docs.github.io/apidocs/spot/en/#dustlog-user_data
  Future<ApiResponse> accountGetDustLog({int? startTime, int? endTime}) async {
    final params = {if (startTime != null) 'startTime': startTime, if (endTime != null) 'endTime': endTime};
    return await requestMarginApi(HttpMethod.get, 'asset/dribblet', signed: true, params: params);
  }

  /// Get Assets That Can Be Converted Into BNB
  /// https://binance-docs.github.io/apidocs/spot/en/#get-assets-that-can-be-converted-into-bnb-user_data
  Future<ApiResponse> accountGetAvailableToConvert() async {
    return await requestMarginApi(HttpMethod.post, 'asset/dust-btc', signed: true);
  }

  /// Convert dust assets to BNB
  /// You need `Enable Spot & Margin` trading permission for the API Key for this endpoint
  /// https://binance-docs.github.io/apidocs/spot/en/#dust-transfer-user_data
  Future<ApiResponse> accountConvertToBnb({required List<String> assets}) async {
    if (assets.length > 1) throw Exception('not implemented for several coins'); // FIXME: for more than one coin
    final params = {'asset': assets.join('&asset=')};
    return await requestMarginApi(HttpMethod.post, 'asset/dust', signed: true, params: params);
  }

  /// Get asset(s) dividend records
  /// https://binance-docs.github.io/apidocs/spot/en/#asset-dividend-record-user_data
  Future<ApiResponse> accountAssetsDividends({String? asset, int? startTime, int? endTime, int? limit}) async {
    final params = {
      if (asset != null) 'asset': asset,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (limit != null) 'limit': limit // Default 20, max 500
    };
    return await requestMarginApi(HttpMethod.get, 'asset/assetDividend', signed: true, params: params);
  }

  /// User universal transfer TODO: not tested
  /// You need to enable `Permits Universal Transfer` option for the API Key which requests this endpoint
  /// [fromSymbol] must be sent when type are ISOLATEDMARGIN_MARGIN and ISOLATEDMARGIN_ISOLATEDMARGIN
  /// [toSymbol] must be sent when type are MARGIN_ISOLATEDMARGIN and ISOLATEDMARGIN_ISOLATEDMARGIN
  /// https://binance-docs.github.io/apidocs/spot/en/#user-universal-transfer-user_data
  Future<int> accountUniversalTransfer({
    required String type, // BnApiUniversalTransfer
    required String asset,
    required double amount,
    String? fromSymbol,
    String? toSymbol,
  }) async {
    final params = {
      'type': type,
      'asset': asset,
      'amount': amount,
      if (fromSymbol != null) 'fromSymbol': fromSymbol,
      if (toSymbol != null) 'toSymbol': toSymbol
    };
    return await requestMarginApi(HttpMethod.post, 'asset/transfer', signed: true, params: params)
        .then((r) => r.json['tranId']);
  }

  /// User universal transfer history
  /// [fromSymbol] must be sent when type are ISOLATEDMARGIN_MARGIN and ISOLATEDMARGIN_ISOLATEDMARGIN
  /// [toSymbol] must be sent when type are MARGIN_ISOLATEDMARGIN and ISOLATEDMARGIN_ISOLATEDMARGIN
  /// Support query within the last 6 months only
  /// If [startTime] and [endTime] not sent, return records of the last 7 days by default
  /// https://binance-docs.github.io/apidocs/spot/en/#query-user-universal-transfer-history-user_data
  Future<ApiResponse> accountUniversalTransferHistory({
    required String type, // BnApiUniversalTransfer
    int? startTime,
    int? endTime,
    int? current, // Default 1
    int? size, // Default 10, Max 100
    String? fromSymbol,
    String? toSymbol,
  }) async {
    final params = {
      'type': type,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (current != null) 'current': current,
      if (size != null) 'size': size,
      if (fromSymbol != null) 'fromSymbol': fromSymbol,
      if (toSymbol != null) 'toSymbol': toSymbol
    };
    return await requestMarginApi(HttpMethod.get, 'asset/transfer', signed: true, params: params);
  }

  /// Funding Wallet
  /// Currently supports querying the following business assets:
  ///   Binance Pay, Binance Card, Binance Gift Card, Stock Token
  /// https://binance-docs.github.io/apidocs/spot/en/#funding-wallet-user_data
  Future<ApiResponse> accountFundingWallet({String? asset, bool? needBtcValuation}) async {
    final params = {
      if (asset != null) 'asset': asset,
      if (needBtcValuation != null) 'needBtcValuation': needBtcValuation
    };
    return await requestMarginApi(HttpMethod.post, 'asset/get-funding-asset', signed: true, params: params);
  }

  /// Get user assets, just for positive data
  /// If [asset] is set, then return this asset, otherwise return all assets positive
  /// If [needBtcValuation] is set, then return btcValuation
  /// https://binance-docs.github.io/apidocs/spot/en/#user-asset-user_data
  Future<ApiResponse> accountUserAsset({String? asset, bool? needBtcValuation}) async {
    final params = {
      if (asset != null) 'asset': asset,
      if (needBtcValuation != null) 'needBtcValuation': needBtcValuation
    };
    return await requestMarginApi(HttpMethod.get, 'asset/getUserAsset', signed: true, params: params);
  }

  /// Convert transfer, convert between BUSD and stablecoins TODO: not tested
  /// If the [clientTranId] has been used before, will not do the convert transfer,
  ///   the original transfer will be returned
  Future<ApiResponse> accountConvertBusd({
    required String clientTranId, // The unique user-defined transaction id, min length 20
    required String asset, // The current asset
    required double amount, // The amount must be positive number
    required String targetAsset, // Target asset you want to convert
    String? accountType, // Only MAIN and CARD, default MAIN
  }) async {
    final params = {
      'clientTranId': clientTranId,
      'asset': asset,
      'amount': amount,
      'targetAsset': targetAsset,
      if (accountType != null) 'accountType': accountType
    };
    return await requestMarginApi(HttpMethod.get, 'asset/convert-transfer', signed: true, params: params);
  }

  /// BUSD convert history TODO: not tested
  /// https://binance-docs.github.io/apidocs/spot/en/#busd-convert-history-user_data
  Future<ApiResponse> accountConvertBusdHistory({
    int? tranId, // The transaction id
    String? clientTranId, // The user-defined transaction id
    String? asset, // If it is blank, we will match deducted asset and target asset.
    required int startTime,
    required int endTime,
    String? accountType, // MAIN: main account. CARD: funding account. If it is blank, query spot and card wallet
    int? current, // current page, default 1, the min value is 1
    int? size, // page size, default 10, the max value is 100
  }) async {
    final params = {
      if (tranId != null) 'tranId': tranId,
      if (clientTranId != null) 'clientTranId': clientTranId,
      if (asset != null) 'asset': asset,
      'startTime': startTime,
      'endTime': endTime,
      if (accountType != null) 'accountType': accountType,
      if (current != null) 'current': current,
      if (size != null) 'size': size,
    };
    return await requestMarginApi(HttpMethod.get, 'asset/convert-transfer/queryByPage', signed: true, params: params);
  }

  /// Cloud-Mining payment and refund history
  /// Just return the SUCCESS records of payment and refund
  /// https://binance-docs.github.io/apidocs/spot/en/#get-cloud-mining-payment-and-refund-history-user_data
  Future<ApiResponse> accountCloudMiningHistory({
    int? tranId, // The transaction id
    String? clientTranId, // The user-defined transaction id
    String? asset, // If it is blank, we will match deducted asset and target asset.
    required int startTime,
    required int endTime,
    String? accountType, // MAIN: main account. CARD: funding account. If it is blank, query spot and card wallet
    int? current, // current page, default 1, the min value is 1
    int? size, // page size, default 10, the max value is 100
  }) async {
    final params = {
      if (tranId != null) 'tranId': tranId,
      if (clientTranId != null) 'clientTranId': clientTranId,
      if (asset != null) 'asset': asset,
      'startTime': startTime,
      'endTime': endTime,
      if (accountType != null) 'accountType': accountType,
      if (current != null) 'current': current,
      if (size != null) 'size': size,
    };
    return await requestMarginApi(HttpMethod.get, 'asset/ledger-transfer/cloud-mining/queryByPage',
        signed: true, params: params);
  }

  /// API key permission
  /// https://binance-docs.github.io/apidocs/spot/en/#get-api-key-permission-user_data
  Future<ApiResponse> accountApiPermissions() async {
    return await requestMarginApi(HttpMethod.get, 'account/apiRestrictions', signed: true);
  }

  /// Get a user's auto-conversion settings in deposit/withdrawal
  /// https://binance-docs.github.io/apidocs/spot/en/#query-auto-converting-stable-coins-user_data
  Future<ApiResponse> accountConvertingStableCoins() async {
    return await requestMarginApi(HttpMethod.get, 'capital/contract/convertible-coins', signed: true);
  }

  /// Switch on/off BUSD and stable coins conversion
  /// https://binance-docs.github.io/apidocs/spot/en/#switch-on-off-busd-and-stable-coins-conversion-user_data
  Future<bool> accountConvertStableCoins({
    required String coin, // Must be USDC, USDP or TUSD
    required bool enable, // true: turn on the auto-conversion. false: turn off the auto-conversion
  }) async {
    final params = {'coin': coin, 'enable': enable};
    return await requestMarginApi(HttpMethod.post, 'capital/contract/convertible-coins', signed: true, params: params)
        .then((r) => true);
  }

  //  TODO: not tested
  /// Toggle BNB burn on spot trade and margin interest
  /// [spotBNBBurn] and [interestBNBBurn] should be sent at least one
  /// [spotBNBBurn] Determines whether to use BNB to pay for trading fees on SPOT
  /// [interestBNBBurn] Determines whether to use BNB to pay for margin loan's interest
  Future<ApiResponse> accountToggleBnbBurnSpotMargin({bool? spotBNBBurn, bool? interestBNBBurn}) async {
    final params = {
      if (spotBNBBurn != null) 'spotBNBBurn': spotBNBBurn,
      if (interestBNBBurn != null) 'interestBNBBurn': interestBNBBurn,
    };
    return await requestMarginApi(HttpMethod.post, 'bnbBurn', signed: true, params: params);
  }

  /// Get BNB burn status
  /// https://binance-docs.github.io/apidocs/spot/en/#get-bnb-burn-status-user_data
  Future<ApiResponse> accountGetBnbBurnSpotMargin() async {
    return await requestMarginApi(HttpMethod.get, 'bnbBurn', signed: true);
  }

  // =================================================================================================================
  // Sub-Account Endpoints
  // =================================================================================================================

  // Exchange Endpoints
  Future<ApiResponse> getProducts() => requestWebsite(HttpMethod.get, BnApiUrls.exchangeProducts).then((r) => r);

  Future<ApiResponse> getExchangeInfo() => get('exchangeInfo', version: BnApiUrls.privateApiVersion);

  // Future<ApiResponse> getSymbolInfo(String symbol) =>
  //     getExchangeInfo().then((r) => r.json['symbols'].firstWhere((e) => e['symbol'] == symbol.toUpperCase()));

  // Market Data Endpoints
  Future<ApiResponse> getAllTickers() => get('ticker/price', version: BnApiUrls.privateApiVersion).then((r) => r);

  Future<ApiResponse> getTicker(String symbol) =>
      get('ticker/price', version: BnApiUrls.privateApiVersion, params: {'symbol': symbol}).then((r) => r);

  Future<ApiResponse> getOrderBookTickers(String symbol) =>
      get('ticker/bookTicker', version: BnApiUrls.privateApiVersion).then((r) => r);

  Future<ApiResponse> getOrderBook(Map<String, dynamic> params) =>
      get('depth', version: BnApiUrls.privateApiVersion, params: params).then((r) => r);

  Future<ApiResponse> getRecentTrades(Map<String, dynamic> params) => get('trades', params: params).then((r) => r);

  Future<ApiResponse> getHistoricalTrades(Map<String, dynamic> params) =>
      get('historicalTrades', version: BnApiUrls.privateApiVersion, params: params).then((r) => r);

  Future<ApiResponse> getAggregateTrades(Map<String, dynamic> params) =>
      get('aggTrades', version: BnApiUrls.privateApiVersion, params: params).then((r) => r);

  Stream aggregateTradeIter(String symbol, String? startStr, int? lastID) async* {
    if (startStr != null && lastID != null) {
      throw Exception('startStr and lastID may not be simultaneously specified');
    }
    // If there's no last_id, get one.
    if (lastID == null) {
      // Without a last_id, we actually need the first trade.
      // Normally, we'd get rid of it. See the next loop.
      List trades = [];
      if (startStr == null) {
        trades = await getAggregateTrades({'symbol': symbol, 'fromId': 0}).then((r) => r.json);
      } else {
        // The difference between startTime and endTime should be less
        // or equal than an hour and the result set should contain at least one trade.
        var startTs = 123;
        int endTs;
        // If the resulting set is empty (i.e. no trades in that interval)
        // then we just move forward hour by hour until we find at least on trade or reach present moment
        while (true) {
          endTs = startTs + (60 * 60 * 1000);
          trades =
              await getAggregateTrades({'symbol': symbol, 'startTime': startTs, 'endTime': endTs}).then((r) => r.json);
          if (trades.isNotEmpty) break;
          // If we reach present moment and find no trades then there is
          // nothing to iterate, so we're done
          if (endTs > DateTime.now().millisecondsSinceEpoch) return;
          startTs = endTs;
        }
      }
      for (var i = 0; i < trades.length; i++) {
        yield trades[i];
      }
      lastID = trades[-1][BnApiAggKeys.aggID];

      while (true) {
        // There is no need to wait between queries, to avoid hitting the
        // rate limit. We're using blocking IO, and as long as we're the
        // only thread running calls like this, Binance will automatically
        // add the right delay time on their end, forcing us to wait for
        // data. That really simplifies this function's job. Binance is fucking awesome.
        trades = await getAggregateTrades({'symbol': symbol, 'fromId': lastID}).then((r) => r.json);
        // fromId=n returns a set starting with id n, but we already have that one.
        // So get rid of the first item in the result set.
        trades = trades.sublist(1);
        if (trades.isEmpty) return;
        for (var i = 0; i < trades.length; i++) {
          yield trades[i];
        }
        lastID = trades[-1][BnApiAggKeys.aggID];
      }
    }
  }

  /// Kline/candlestick SPOT/MARGIN bars for a symbol.
  /// https://binance-docs.github.io/apidocs/spot/en/#kline-candlestick-data
  /// Klines are uniquely identified by their open time.
  Future getKLines(String symbol, String interval, {int? limit, int? startTime, int? endTime}) async {
    final params = {
      'symbol': symbol,
      'interval': interval, // TimeFrame
      if (limit != null) 'limit': limit, // Default 500; max 1000
      if (startTime != null) 'startTime': startTime, // 0
      if (endTime != null) 'endTime': endTime, // DateTime.now().millisecondsSinceEpoch
    };
    return await get('klines', version: BnApiUrls.privateApiVersion, params: params);
  }

  /// Current average price for a symbol (5min).
  /// https://binance-docs.github.io/apidocs/spot/en/#current-average-price
  Future getAvgPrice(String symbol) =>
      get('avgPrice', version: BnApiUrls.privateApiVersion, params: {'symbol': symbol});

  // TODO: set params
  Future getTicker24h(String symbol) =>
      get('ticker/24hr', version: BnApiUrls.privateApiVersion, params: {'symbol': symbol}).then((r) => r);

  // TODO: set params
  Future getSymbolTicker(String symbol) =>
      get('ticker/price', version: BnApiUrls.privateApiVersion, params: {'symbol': symbol}).then((r) => r);

  // TODO: set params
  Future getOrderBookTicker(String symbol) =>
      get('ticker/bookTicker', version: BnApiUrls.privateApiVersion, params: {'symbol': symbol}).then((r) => r);

  // Account Endpoints

  /// Send in a new order.
  /// https://binance-docs.github.io/apidocs/spot/en/#new-order-trade
  /// LIMIT_MAKER are LIMIT orders that will be rejected if they would immediately match and trade as a taker.
  /// STOP_LOSS and TAKE_PROFIT will execute a MARKET order when the [stopPrice] is reached.
  /// Any LIMIT or LIMIT_MAKER type order can be made an iceberg order by sending an [icebergQty].
  /// Any order with an [icebergQty] MUST have [timeInForce] set to GTC.
  /// MARKET orders using the [quantity] field specifies the amount of the base asset to buy or sell at the market price
  /// MARKET orders using [quoteOrderQty] specifies the amount the user wants to spend (when buying)
  ///      or receive (when selling) the quote asset; the correct [quantity] will be determined based on the
  ///      market liquidity and [quoteOrderQty].
  /// MARKET orders using [quoteOrderQty] will not break LOT_SIZE filter rules;
  ///     the order will execute a [quantity] that will have the notional value as close as possible to [quoteOrderQty].
  /// same [newClientOrderId] can be accepted only when the previous one is filled, otherwise the order will be rejected
  /// For STOP_LOSS, STOP_LOSS_LIMIT, TAKE_PROFIT_LIMIT and TAKE_PROFIT orders,
  ///     [trailingDelta] can be combined with [stopPrice].
  Future createOrder(
    String symbol,
    String side, // BUY, SELL
    String orderType, {
    String? timeInForce,
    double? quantity,
    double? quoteOrderQty,
    double? price,
    String? newClientOrderId, // A unique id among open orders. Automatically generated if not sent.
    int? strategyId,
    int? strategyType, // The value cannot be less than 1000000.
    double? stopPrice, // Used with STOP_LOSS, STOP_LOSS_LIMIT, TAKE_PROFIT, and TAKE_PROFIT_LIMIT orders.
    int? trailingDelta, // Used with STOP_LOSS, STOP_LOSS_LIMIT, TAKE_PROFIT, and TAKE_PROFIT_LIMIT orders.
    double? icebergQty, // Used with LIMIT, STOP_LOSS_LIMIT, and TAKE_PROFIT_LIMIT to create an iceberg order.
    String? newOrderRespType, // Set the response JSON. ACK, RESULT, or FULL;
    // MARKET and LIMIT order types default to FULL, all other orders default to ACK
  }) async {
    final _data = {
      'symbol': symbol,
      'side': side,
      'type': orderType,
      if (timeInForce != null) 'timeInForce': timeInForce,
      if (quantity != null) 'quantity': quantity,
      if (quoteOrderQty != null) 'quoteOrderQty': quoteOrderQty,
      if (price != null) 'price': price,
      if (newClientOrderId != null) 'newClientOrderId': newClientOrderId,
      if (strategyId != null) 'strategyId': strategyId,
      if (strategyType != null) 'strategyType': strategyType,
      if (stopPrice != null) 'stopPrice': stopPrice,
      if (trailingDelta != null) 'trailingDelta': trailingDelta,
      if (icebergQty != null) 'icebergQty': icebergQty,
      if (newOrderRespType != null) 'newOrderRespType': newOrderRespType,
    };
    return await post('order', signed: true, params: _data);
  }

  Future orderLimit(String symbol, String side, double price, double quantity, {String? timeInForce}) async {
    return await createOrder(
      symbol,
      side,
      BnApiOrderType.limit,
      price: price,
      quantity: quantity,
      timeInForce: timeInForce ?? BnApiTimeInForce.gtc,
    );
  }

  Future order_limit_buy(String symbol, double price, double quantity, {String? timeInForce}) async {
    return await createOrder(
      symbol,
      BnApiOrderSide.buy,
      BnApiOrderType.limit,
      price: price,
      quantity: quantity,
      timeInForce: timeInForce ?? BnApiTimeInForce.gtc,
    );
  }

  Future order_limit_sell(String symbol, double price, double quantity, {String? timeInForce}) async {
    return await createOrder(
      symbol,
      BnApiOrderSide.sell,
      BnApiOrderType.limit,
      price: price,
      quantity: quantity,
      timeInForce: timeInForce ?? BnApiTimeInForce.gtc,
    );
  }

  Future orderMarket(String symbol, String side, double price, double quantity, {String? timeInForce}) async {
    return await createOrder(
      symbol,
      side,
      BnApiOrderType.market,
      price: price,
      quantity: quantity,
      timeInForce: timeInForce ?? BnApiTimeInForce.gtc,
    );
  }

  Future order_market_buy(String symbol, double price, double quantity, {String? timeInForce}) async {
    return await createOrder(
      symbol,
      BnApiOrderSide.buy,
      BnApiOrderType.market,
      price: price,
      quantity: quantity,
      timeInForce: timeInForce ?? BnApiTimeInForce.gtc,
    );
  }

  Future order_market_sell(String symbol, double price, double quantity, {String? timeInForce}) async {
    return await createOrder(
      symbol,
      BnApiOrderSide.sell,
      BnApiOrderType.market,
      price: price,
      quantity: quantity,
      timeInForce: timeInForce ?? BnApiTimeInForce.gtc,
    );
  }

  /// Send in a new OCO
  /// https://binance-docs.github.io/apidocs/spot/en/#new-oco-trade
  Future create_oco_order(
    String symbol,
    String side,
    double price,
    double quantity, {
    String? listClientOrderId, // A unique Id for the entire orderList
    String? limitClientOrderId, // A unique Id for the limit order
    int? limitStrategyId,
    int? limitStrategyType, // The value cannot be less than 1000000
    double? limitIcebergQty,
    int? trailingDelta, // type: LONG
    String? stopClientOrderId,
    double? stopPrice,
    int? stopStrategyId,
    int? stopStrategyType, // The value cannot be less than 1000000
    double? stopLimitPrice, // If provided, stopLimitTimeInForce is required
    double? stopIcebergQty,
    String? stopLimitTimeInForce, // Valid values are GTC/FOK/IOC
    String? newOrderRespType, // Set the response JSON.
  }) async {
    final _data = {
      'symbol': symbol,
      'side': side,
      'price': price,
      'quantity': quantity,
      if (listClientOrderId != null) 'listClientOrderId': listClientOrderId,
      if (limitClientOrderId != null) 'limitClientOrderId': limitClientOrderId,
      if (limitStrategyId != null) 'limitStrategyId': limitStrategyId,
      if (limitStrategyType != null) 'limitStrategyType': limitStrategyType,
      if (limitIcebergQty != null) 'limitIcebergQty': limitIcebergQty,
      if (trailingDelta != null) 'trailingDelta': trailingDelta,
      if (stopClientOrderId != null) 'stopClientOrderId': stopClientOrderId,
      if (stopPrice != null) 'stopPrice': stopPrice,
      if (stopStrategyId != null) 'stopStrategyId': stopStrategyId,
      if (stopStrategyType != null) 'stopStrategyType': stopStrategyType,
      if (stopLimitPrice != null) 'stopLimitPrice': stopLimitPrice,
      if (stopIcebergQty != null) 'stopIcebergQty': stopIcebergQty,
      if (stopLimitTimeInForce != null) 'stopLimitTimeInForce': stopLimitTimeInForce,
      if (newOrderRespType != null) 'newOrderRespType': newOrderRespType,
    };
    return await post('order/oco', signed: true, params: _data);
  }

  /// Test new order creation and signature
  /// Creates and validates a new order but does not send it into the matching engine.
  /// https://binance-docs.github.io/apidocs/spot/en/#test-new-order-trade
  Future createTestOrder(
    String symbol,
    String side, // BUY, SELL
    String orderType, {
    String? timeInForce,
    double? quantity,
    double? quoteOrderQty,
    double? price,
    String? newClientOrderId, // A unique id among open orders. Automatically generated if not sent.
    int? strategyId,
    int? strategyType, // The value cannot be less than 1000000.
    double? stopPrice, // Used with STOP_LOSS, STOP_LOSS_LIMIT, TAKE_PROFIT, and TAKE_PROFIT_LIMIT orders.
    int? trailingDelta, // Used with STOP_LOSS, STOP_LOSS_LIMIT, TAKE_PROFIT, and TAKE_PROFIT_LIMIT orders.
    double? icebergQty, // Used with LIMIT, STOP_LOSS_LIMIT, and TAKE_PROFIT_LIMIT to create an iceberg order.
    String? newOrderRespType, // Set the response JSON. ACK, RESULT, or FULL;
    // MARKET and LIMIT order types default to FULL, all other orders default to ACK
  }) async {
    final _data = {
      'symbol': symbol,
      'side': side,
      'type': orderType,
      if (timeInForce != null) 'timeInForce': timeInForce,
      if (quantity != null) 'quantity': quantity,
      if (quoteOrderQty != null) 'quoteOrderQty': quoteOrderQty,
      if (price != null) 'price': price,
      if (newClientOrderId != null) 'newClientOrderId': newClientOrderId,
      if (strategyId != null) 'strategyId': strategyId,
      if (strategyType != null) 'strategyType': strategyType,
      if (stopPrice != null) 'stopPrice': stopPrice,
      if (trailingDelta != null) 'trailingDelta': trailingDelta,
      if (icebergQty != null) 'icebergQty': icebergQty,
      if (newOrderRespType != null) 'newOrderRespType': newOrderRespType,
    };
    return await post('order/test', signed: true, params: _data);
  }

  /// Check an order's status.
  ///
  /// Either [orderId] or [origClientOrderId] must be sent.
  Future getOrder(String symbol, {int? orderId, String? origClientOrderId}) async {
    assert(orderId != null || origClientOrderId != null, 'orderId or origClientOrderId must be set to get order');
    return await get('order', signed: true, params: {
      'symbol': symbol,
      if (orderId != null) 'orderId': orderId,
      if (origClientOrderId != null) 'origClientOrderId': origClientOrderId,
    });
  }

  /// Get all account orders; active, canceled, or filled.
  /// https://binance-docs.github.io/apidocs/spot/en/#all-orders-user_data
  /// If [orderId] is set, it will get orders >= that [orderId]. Otherwise most recent orders are returned.
  /// If [startTime] and/or [endTime] provided, [orderId] is not required.
  Future getAllOrders(String symbol, {int? orderId, String? startTime, String? endTime, int limit = 500}) async {
    return await get('allOrders', signed: true, params: {
      'symbol': symbol,
      'limit': limit,
      if (orderId != null) 'orderId': orderId,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    });
  }

  /// Cancel an active order.
  /// https://binance-docs.github.io/apidocs/spot/en/#cancel-order-trade
  /// Either [orderId] or [origClientOrderId] must be sent.
  /// If both [orderId] and [origClientOrderId] are provided, [orderId] takes precedence.
  Future cancelOrder(String symbol, {int? orderId, String? origClientOrderId, String? newClientOrderId}) async {
    assert(orderId != null || origClientOrderId != null, 'orderId or origClientOrderId must be set to get order');
    return await delete('order', signed: true, params: {
      'symbol': symbol,
      if (orderId != null) 'orderId': orderId,
      if (origClientOrderId != null) 'origClientOrderId': origClientOrderId,
      if (newClientOrderId != null) 'newClientOrderId': newClientOrderId,
    });
  }

  /// Cancels all active orders on a symbol. This includes OCO orders.
  /// https://binance-docs.github.io/apidocs/spot/en/#cancel-all-open-orders-on-a-symbol-trade
  Future cancelOrders(String symbol) async {
    return await delete('openOrders', signed: true, params: {'symbol': symbol}); // List of orders
  }

  /// Get all open orders on a symbol.
  /// https://binance-docs.github.io/apidocs/spot/en/#current-open-orders-user_data
  Future getOpenOrders(String symbol) async {
    return await delete('openOrders', signed: true, params: {'symbol': symbol}); // List of orders
  }

  /// Cancels an existing order and places a new order on the same symbol.
  /// https://binance-docs.github.io/apidocs/spot/en/#cancel-an-existing-order-and-send-a-new-order-trade
  Future cancelReplaceOrder(String symbol) async {
    // TODO: not done
    return await post('order/cancelReplace', signed: true, params: {'symbol': symbol});
  }

  // User Stream Endpoints

  /// Get current account information.
  /// https://binance-docs.github.io/apidocs/spot/en/#account-information-user_data
  Future getAccount() => get('account', signed: true);

  Future get_my_trades() async {
    return await get('myTrades', signed: true);
  }

  // User Stream Endpoints

  Future<String> stream_get_listen_key() async {
    final _response = await post('userDataStream', signed: false, params: {});
    return _response.json['listenKey'];
  }

  Future stream_keepAlive(String listenKey) async {
    return await put('userDataStream', signed: false, params: {'listenKey': listenKey});
  }

  Future stream_close(String listenKey) async {
    return await delete('userDataStream', signed: false, params: {'listenKey': listenKey});
  }

  // =================================================================================================================
  // Margin Trading Endpoints
  // =================================================================================================================

  /// Transfer between spot account and cross margin account
  /// [type] 1: transfer from main account to cross margin 2: transfer from cross margin to main account
  /// https://binance-docs.github.io/apidocs/spot/en/#cross-margin-account-transfer-margin
  Future<int> marginTransferWithSpot({required String asset, required double amount, required int type}) async {
    final params = {'asset': asset, 'amount': amount, 'type': type};
    return await requestMarginApi(HttpMethod.post, 'margin/transfer', signed: true, params: params)
        .then((r) => r.json['tranId']);
  }

  /// Get cross margin transfer history
  /// The max interval between [startTime] and [endTime] is 30 days. Returns data for last 7 days by default.
  /// Set [archived] to true to query data from 6 months ago
  Future<ApiResponse> marginTransferWithSpotHistory({
    String? asset,
    String? type, // Transfer Type: ROLL_IN, ROLL_OUT
    int? startTime,
    int? endTime,
    int? current, // Currently querying page. Start from 1. Default:1
    int? size, // Default:10 Max:100
    bool? archived, // Default: false. Set to true for archived data from 6 months ago
  }) async {
    final params = {
      if (asset != null) 'asset': asset,
      if (type != null) 'type': type,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (current != null) 'current': current,
      if (size != null) 'size': size,
      if (archived != null) 'archived': archived,
    };
    return await requestMarginApi(HttpMethod.get, 'margin/transfer', signed: true, params: params);
  }

  /// Apply for a loan
  /// If [isIsolated] = true, [symbol] must be sent
  /// [isIsolated] = false for crossed margin loan
  /// https://binance-docs.github.io/apidocs/spot/en/#margin-account-borrow-margin
  Future<ApiResponse> marginAccountBorrow(
      {required String asset, required double amount, bool? isIsolated, String? symbol}) async {
    final params = {
      'asset': asset,
      'amount': amount,
      if (isIsolated != null) 'isIsolated': isIsolated, // is isolated margin or not, default "FALSE"
      if (symbol != null) 'symbol': symbol, // isolated symbol
    };
    return await requestMarginApi(HttpMethod.post, 'margin/loan', signed: true, params: params)
        .then((r) => r.json['tranId']);
  }

  /// Query loan records
  /// [txId] or [startTime] must be sent. [txId] takes precedence
  /// If [isolatedSymbol] is not sent, crossed margin data will be returned
  /// The max interval between [startTime] and [endTime] is 30 days
  /// If [startTime] and [endTime] not sent, return records of the last 7 days by default
  /// Set [archived] to true to query data from 6 months ago
  /// https://binance-docs.github.io/apidocs/spot/en/#query-loan-record-user_data
  Future<ApiResponse> marginAccountBorrowDetails({
    required String asset,
    String? isolatedSymbol, // isolated symbol
    int? txId, // the tranId in [marginAccountBorrow]
    int? startTime,
    int? endTime,
    int? current, // Currently querying page. Start from 1. Default:1
    int? size, // Default:10 Max:100
    bool? archived, // Default: false. Set to true for archived data from 6 months ago
  }) async {
    final params = {
      'asset': asset,
      if (isolatedSymbol != null) 'isolatedSymbol': isolatedSymbol,
      if (txId != null) 'txId': txId,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (current != null) 'current': current,
      if (size != null) 'size': size,
      if (archived != null) 'archived': archived,
    };
    return await requestMarginApi(HttpMethod.get, 'margin/loan', signed: true, params: params);
  }

  /// Repay loan for margin account
  /// If [isIsolated] = true, [symbol] must be sent
  /// [isIsolated] = false for crossed margin loan
  /// https://binance-docs.github.io/apidocs/spot/en/#margin-account-repay-margin
  Future<ApiResponse> marginAccountRepay(
      {required String asset, required double amount, bool? isIsolated, String? symbol}) async {
    final params = {
      'asset': asset,
      'amount': amount,
      if (isIsolated != null) 'isIsolated': isIsolated, // is isolated margin or not, default "FALSE"
      if (symbol != null) 'symbol': symbol, // isolated symbol
    };
    return await requestMarginApi(HttpMethod.post, 'margin/repay', signed: true, params: params)
        .then((r) => r.json['tranId']);
  }

  /// Query repay record
  /// [txId] or [startTime] must be sent. [txId] takes precedence
  /// If [isolatedSymbol] is not sent, crossed margin data will be returned
  /// The max interval between [startTime] and [endTime] is 30 days
  /// If [startTime] and [endTime] not sent, return records of the last 7 days by default
  /// Set [archived] to true to query data from 6 months ago
  /// https://binance-docs.github.io/apidocs/spot/en/#query-repay-record-user_data
  Future<ApiResponse> marginAccountRepayDetails({
    required String asset,
    String? isolatedSymbol, // isolated symbol
    int? txId, // the tranId in [marginAccountRepay]
    int? startTime,
    int? endTime,
    int? current, // Currently querying page. Start from 1. Default:1
    int? size, // Default:10 Max:100
    bool? archived,
  }) async {
    final params = {
      'asset': asset,
      if (isolatedSymbol != null) 'isolatedSymbol': isolatedSymbol,
      if (txId != null) 'txId': txId,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (current != null) 'current': current,
      if (size != null) 'size': size,
      if (archived != null) 'archived': archived,
    };
    return await requestMarginApi(HttpMethod.get, 'margin/repay', signed: true, params: params);
  }

  /// Get margin asset
  /// https://binance-docs.github.io/apidocs/spot/en/#query-margin-asset-market_data
  Future<ApiResponse> marginAsset({required String asset}) async {
    return await requestMarginApi(HttpMethod.get, 'margin/asset', params: {'asset': asset});
  }

  /// Get all margin assets
  /// https://binance-docs.github.io/apidocs/spot/en/#get-all-margin-assets-market_data
  Future<ApiResponse> marginAllAsset() async => await requestMarginApi(HttpMethod.get, 'margin/allAssets');

  /// Get cross margin pair
  /// https://binance-docs.github.io/apidocs/spot/en/#query-cross-margin-pair-market_data
  Future<ApiResponse> marginSymbol({required String symbol}) async {
    return await requestMarginApi(HttpMethod.get, 'margin/pair', params: {'symbol': symbol});
  }

  /// Get all cross margin pairs
  /// https://binance-docs.github.io/apidocs/spot/en/#get-all-cross-margin-pairs-market_data
  Future<ApiResponse> marginAllSymbol() async {
    return await requestMarginApi(HttpMethod.get, 'margin/allPairs');
  }

  /// Query margin priceIndex
  /// https://binance-docs.github.io/apidocs/spot/en/#query-margin-priceindex-market_data
  Future<ApiResponse> marginPriceIndex({required String symbol}) async {
    return await requestMarginApi(HttpMethod.get, 'margin/priceIndex', params: {'symbol': symbol});
  }

  /// Post a new order for margin account
  /// [timeInForce] required if limit order
  /// https://binance-docs.github.io/apidocs/spot/en/#margin-account-new-order-trade
  Future<ApiResponse> marginCreateOrder({
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
    final params = {
      'symbol': symbol,
      'side': side,
      'type': type,
      if (isIsolated != null) 'isIsolated': isIsolated,
      if (timeInForce != null) 'timeInForce': timeInForce,
      if (quantity != null) 'quantity': quantity,
      if (quoteOrderQty != null) 'quoteOrderQty': quoteOrderQty,
      if (price != null) 'price': price,
      if (newClientOrderId != null) 'newClientOrderId': newClientOrderId,
      if (stopPrice != null) 'stopPrice': stopPrice,
      if (sideEffectType != null) 'sideEffectType': sideEffectType,
      if (icebergQty != null) 'icebergQty': icebergQty,
      if (newOrderRespType != null) 'newOrderRespType': newOrderRespType,
    };
    return await requestMarginApi(HttpMethod.post, 'margin/order', signed: true, params: params);
  }

  /// Margin account cancel order
  /// Either [orderId] or [origClientOrderId] must be sent.
  /// https://binance-docs.github.io/apidocs/spot/en/#margin-account-cancel-order-trade
  Future<ApiResponse> marginCancelOrder({
    required String symbol,
    bool? isIsolated, // isolated margin or not, default false
    int? orderId,
    String? origClientOrderId,
    String? newClientOrderId, // Used to uniquely identify this cancel. Automatically generated by default
  }) async {
    final params = {
      'symbol': symbol,
      if (isIsolated != null) 'isIsolated': isIsolated,
      if (orderId != null) 'orderId': orderId,
      if (origClientOrderId != null) 'origClientOrderId': origClientOrderId,
      if (newClientOrderId != null) 'newClientOrderId': newClientOrderId
    };
    return await requestMarginApi(HttpMethod.delete, 'margin/order', signed: true, params: params);
  }

  /// Cancels all active orders on a symbol for margin account. This includes OCO orders.
  /// https://binance-docs.github.io/apidocs/spot/en/#margin-account-cancel-all-open-orders-on-a-symbol-trade
  Future<ApiResponse> marginCancelOrders({required String symbol, bool? isIsolated}) async {
    final params = {'symbol': symbol, if (isIsolated != null) 'isIsolated': isIsolated};
    return await requestMarginApi(HttpMethod.delete, 'margin/openOrders', signed: true, params: params);
  }

  /// Get interest history
  /// If [isolatedSymbol] is not sent, crossed margin data will be returned
  /// The max interval between [startTime] and [endTime] is 30 days
  /// If [startTime] and [endTime] not sent, return records of the last 7 days by default
  /// Set [archived] to true to query data from 6 months ago
  /// https://binance-docs.github.io/apidocs/spot/en/#get-interest-history-user_data
  Future<ApiResponse> marginInterestHistory({
    String? asset,
    String? isolatedSymbol, // isolated symbol
    int? startTime,
    int? endTime,
    int? current, // Currently querying page. Start from 1. Default:1
    int? size, // Default:10 Max:100
    bool? archived,
  }) async {
    final params = {
      if (asset != null) 'asset': asset,
      if (isolatedSymbol != null) 'isolatedSymbol': isolatedSymbol,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (current != null) 'current': current,
      if (size != null) 'size': size,
      if (archived != null) 'archived': archived,
    };
    return await requestMarginApi(HttpMethod.get, 'margin/interestHistory', signed: true, params: params);
  }

  /// Get force liquidation record
  /// https://binance-docs.github.io/apidocs/spot/en/#get-force-liquidation-record-user_data
  Future<ApiResponse> marginForceLiquidationRec({
    String? isolatedSymbol, // isolated symbol
    int? startTime,
    int? endTime,
    int? current, // Currently querying page. Start from 1. Default:1
    int? size, // Default:10 Max:100
  }) async {
    final params = {
      if (isolatedSymbol != null) 'isolatedSymbol': isolatedSymbol,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (current != null) 'current': current,
      if (size != null) 'size': size,
    };
    return await requestMarginApi(HttpMethod.get, 'margin/forceLiquidationRec', signed: true, params: params);
  }

  /// Cross margin account details
  /// https://binance-docs.github.io/apidocs/spot/en/#query-cross-margin-account-details-user_data
  Future<ApiResponse> marginAccount() async => await requestMarginApi(HttpMethod.get, 'margin/account', signed: true);

  /// Get margin account's order
  /// Either [orderId] or [origClientOrderId] must be sent
  /// https://binance-docs.github.io/apidocs/spot/en/#query-margin-account-39-s-order-user_data
  Future<ApiResponse> marginGetOrder(
      {required String symbol, bool? isIsolated, int? orderId, String? origClientOrderId}) async {
    final params = {
      'symbol': symbol,
      if (isIsolated != null) 'isIsolated': isIsolated,
      if (orderId != null) 'orderId': orderId,
      if (origClientOrderId != null) 'origClientOrderId': origClientOrderId,
    };
    return await requestMarginApi(HttpMethod.get, 'margin/order', signed: true, params: params);
  }

  /// Get margin account's open order
  /// [symbol] is mandatory for isolated margin
  /// https://binance-docs.github.io/apidocs/spot/en/#query-margin-account-39-s-open-orders-user_data
  Future<ApiResponse> marginGetOpenOrders({String? symbol, bool? isIsolated}) async {
    final params = {if (symbol != null) 'symbol': symbol, if (isIsolated != null) 'isIsolated': isIsolated};
    return await requestMarginApi(HttpMethod.get, 'margin/openOrders', signed: true, params: params);
  }

  /// Get margin account's all order (60 times/min)
  /// If [orderId] is set, it will get orders >= that [orderId]. Otherwise most recent orders are returned
  /// https://binance-docs.github.io/apidocs/spot/en/#query-margin-account-39-s-all-orders-user_data
  Future<ApiResponse> marginGetAllOrders({
    required String symbol,
    bool? isIsolated, // isolated margin or not, default false
    int? orderId,
    int? startTime,
    int? endTime,
    int? limit, // Default 500; max 500
  }) async {
    final params = {
      'symbol': symbol,
      if (isIsolated != null) 'isIsolated': isIsolated,
      if (orderId != null) 'orderId': orderId,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (limit != null) 'limit': limit,
    };
    return await requestMarginApi(HttpMethod.get, 'margin/allOrders', signed: true, params: params);
  }

  /// Margin account's create OCO
  Future<ApiResponse> create_margin_oco_order() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'margin/order/oco', signed: true, params: _params);
  }

  /// Margin account's cancel OCO
  Future<ApiResponse> cancel_margin_oco_order() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.delete, 'margin/orderList', signed: true, params: _params);
  }

  /// Get margin account's OCO
  Future<ApiResponse> get_margin_oco_order() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/orderList', signed: true, params: _params);
  }

  /// Get margin account's all OCO
  Future<ApiResponse> get_open_margin_oco_orders() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/allOrderList', signed: true, params: _params);
  }

  /// Get margin account's open OCO
  Future<ApiResponse> get_all_margin_oco_orders() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/openOrderList', signed: true, params: _params);
  }

  /// Get margin account's trade list
  /// If [fromId] is set, it will get trades >= that [fromId]. Otherwise most recent trades are returned.
  /// https://binance-docs.github.io/apidocs/spot/en/#query-margin-account-39-s-trade-list-user_data
  Future<ApiResponse> marginGetTrades({
    required String symbol,
    bool? isIsolated, // isolated margin or not, default false
    int? orderId,
    int? startTime,
    int? endTime,
    int? fromId, // TradeId to fetch from. Default gets most recent trades
    int? limit, // Default 500; max 1000.
  }) async {
    final params = {
      'symbol': symbol,
      if (isIsolated != null) 'isIsolated': isIsolated,
      if (orderId != null) 'orderId': orderId, // TradeId to fetch from. Default gets most recent trades.
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (fromId != null) 'fromId': fromId,
      if (limit != null) 'limit': limit,
    };
    return await requestMarginApi(HttpMethod.get, 'margin/myTrades', signed: true, params: params);
  }

  Future<ApiResponse> get_max_margin_loan({required String asset, String? isolatedSymbol}) async {
    final params = {'asset': asset, if (isolatedSymbol != null) 'isolatedSymbol': isolatedSymbol};
    return await requestMarginApi(HttpMethod.get, 'margin/maxBorrowable', signed: true, params: params);
  }

  /// Get max transfer-out amount
  /// If [isolatedSymbol] is not sent, crossed margin data will be sent
  /// https://binance-docs.github.io/apidocs/spot/en/#query-max-transfer-out-amount-user_data
  Future<double> marginTransferMax({required String asset, String? isolatedSymbol}) async {
    final params = {'asset': asset, if (isolatedSymbol != null) 'isolatedSymbol': isolatedSymbol};
    return await requestMarginApi(HttpMethod.get, 'margin/maxTransferable', signed: true, params: params)
        .then((r) => double.parse(r.json['amount']));
  }

  /// Get personal margin level information
  /// https://binance-docs.github.io/apidocs/spot/en/#get-summary-of-margin-account-user_data
  Future<ApiResponse> marginGetLevelInfo() async {
    return await requestMarginApi(HttpMethod.get, 'margin/tradeCoeff', signed: true);
  }

  /// Get margin interest rate history
  Future<ApiResponse> marginInterestRateHistory({
    required String asset,
    int? vipLevel, // Default: user's vip level
    int? startTime, // Default: 7 days ago
    int? endTime, // Default: present. Maximum range: 1 months.
  }) async {
    final params = {
      'asset': asset,
      if (vipLevel != null) 'vipLevel': vipLevel,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    };
    return await requestMarginApi(HttpMethod.get, 'margin/interestRateHistory', signed: true, params: params);
  }

  /// Get cross margin fee data
  /// User's current specific margin data will be returned if [vipLevel] is omitted
  /// https://binance-docs.github.io/apidocs/spot/en/#query-cross-margin-fee-data-user_data
  Future<ApiResponse> marginFee({String? coin, int? vipLevel}) async {
    final params = {
      if (coin != null) 'coin': coin,
      if (vipLevel != null) 'vipLevel': vipLevel,
    };
    return await requestMarginApi(HttpMethod.get, 'margin/crossMarginData', signed: true, params: params);
  }

  /// Get current margin order count usage
  /// Displays the user's current margin order count usage for all intervals
  /// https://binance-docs.github.io/apidocs/spot/en/#query-current-margin-order-count-usage-trade
  Future<ApiResponse> margin_order_count_usage({String? symbol, bool? isIsolated}) async {
    final params = {
      if (symbol != null) 'symbol': symbol,
      if (isIsolated != null) 'isIsolated': isIsolated,
    };
    return await requestMarginApi(HttpMethod.get, 'margin/rateLimit/order', signed: true, params: params);
  }

  /// Margin dustlog
  /// Query the historical information of user's margin account small-value asset conversion BNB
  /// https://binance-docs.github.io/apidocs/spot/en/#margin-dustlog-user_data
  Future<ApiResponse> margin_dust_log({int? startTime, int? endTime}) async {
    final params = {
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    };
    return await requestMarginApi(HttpMethod.get, 'margin/dribblet', signed: true, params: params);
  }

  /// Cross margin collateral ratio
  /// https://binance-docs.github.io/apidocs/spot/en/#cross-margin-collateral-ratio-market_data
  Future<ApiResponse> margin_collateral_ratio() async {
    return await requestMarginApi(HttpMethod.get, 'margin/crossMarginCollateralRatio', signed: true);
  }

  /// Get small liability exchange coin list
  /// https://binance-docs.github.io/apidocs/spot/en/#get-small-liability-exchange-coin-list-user_data
  Future<ApiResponse> margin_liability_exchange_coin_list() async {
    return await requestMarginApi(HttpMethod.get, 'margin/exchange-small-liability', signed: true);
  }

  /// Small liability exchange
  /// Only convert once within 6 hours
  /// Only liability valuation less than 10 BUSD are supported
  /// The maximum number of [assetNames] is 10
  /// https://binance-docs.github.io/apidocs/spot/en/#small-liability-exchange-margin
  Future<ApiResponse> margin_liability_exchange({required List<String> assetNames}) async {
    final params = {'assetNames': assetNames.join(',')};
    return await requestMarginApi(HttpMethod.post, 'margin/exchange-small-liability', signed: true, params: params);
  }

  Future<ApiResponse> margin_liability_exchange_history({
    required int current, // Currently querying page. Start from 1. Default:1
    required int size, // Default:10, Max:100
    int? startTime, // Default: 30 days from current timestamp
    int? endTime, // Default: present timestamp
  }) async {
    final params = {
      'current': current,
      'size': size,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    };
    return await requestMarginApi(HttpMethod.get, 'margin/exchange-small-liability-history',
        signed: true, params: params);
  }

  // =================================================================================================================
  // Isolated Trading Endpoints
  // =================================================================================================================

  /// Get isolated margin transfer history
  /// The max interval between [startTime] and [endTime] is 30 days
  /// If [startTime] and [endTime] not sent, return records of the last 7 days by default
  /// Set [archived] to true to query data from 6 months ago
  /// https://binance-docs.github.io/apidocs/spot/en/#get-isolated-margin-transfer-history-user_data
  Future<ApiResponse> isolatedTransferHistory({
    required String symbol,
    String? asset,
    String? transFrom, // SPOT, ISOLATED_MARGIN
    String? transTo, // SPOT, ISOLATED_MARGIN
    int? startTime,
    int? endTime,
    int? current, // Current page, default 1
    int? size, // Default 10, max 100
    bool? archived, // Default: false. Set to true for archived data from 6 months ago
  }) async {
    final params = {
      'symbol': symbol,
      if (asset != null) 'asset': asset,
      if (transFrom != null) 'transFrom': transFrom,
      if (transTo != null) 'transTo': transTo,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      if (current != null) 'current': current,
      if (size != null) 'size': size,
      if (archived != null) 'archived': archived,
    };
    return await requestMarginApi(HttpMethod.get, 'margin/isolated/transfer', signed: true, params: params);
  }

  /// Isolated margin account transfer
  /// https://binance-docs.github.io/apidocs/spot/en/#isolated-margin-account-transfer-margin
  Future<int> isolatedTransferWithSpot({
    required String asset,
    required String symbol,
    required String transFrom, // SPOT, ISOLATED_MARGIN
    required String transTo, // ISOLATED_MARGIN, SPOT
    required double amount,
  }) async {
    final params = {
      'asset': asset,
      'symbol': symbol,
      'transFrom': transFrom,
      'transTo': transTo,
      'amount': amount,
    };
    return await requestMarginApi(HttpMethod.post, 'margin/isolated/transfer', signed: true, params: params)
        .then((r) => r.json['tranId']);
  }

  /// Get isolated margin account info
  /// If [symbols] is not sent, all isolated assets will be returned
  /// If [symbols] is sent, only the isolated assets of the sent symbols will be returned
  /// Max 5 [symbols] can be sent; separated by ",". e.g. "BTCUSDT,BNBUSDT,ADAUSDT"
  /// https://binance-docs.github.io/apidocs/spot/en/#query-isolated-margin-account-info-user_data
  Future<ApiResponse> isolatedMarginAccount({List<String>? symbols}) async {
    final params = {if (symbols != null) 'symbols': symbols.join(',')};
    return await requestMarginApi(HttpMethod.get, 'margin/isolated/account', signed: true, params: params);
  }

  /// Enable isolated margin account for a specific [symbol]
  /// Only supports activation of previously disabled accounts
  /// https://binance-docs.github.io/apidocs/spot/en/#enable-isolated-margin-account-trade
  Future<bool> isolatedMarginAccountEnable({required String symbol}) async {
    final params = {'symbol': symbol};
    return await requestMarginApi(HttpMethod.post, 'margin/isolated/account', signed: true, params: params)
        .then((r) => r.json['success']);
  }

  /// Disable isolated margin account for a specific [symbol]
  /// Each trading pair can only be deactivated once every 24 hours
  /// https://binance-docs.github.io/apidocs/spot/en/#disable-isolated-margin-account-trade
  Future<bool> isolatedMarginAccountDisable({required String symbol}) async {
    final params = {'symbol': symbol};
    return await requestMarginApi(HttpMethod.delete, 'margin/isolated/account', signed: true, params: params)
        .then((r) => r.json['success']);
  }

  /// Get enabled isolated margin account limit
  /// https://binance-docs.github.io/apidocs/spot/en/#query-enabled-isolated-margin-account-limit-user_data
  Future<ApiResponse> isolatedMarginAccountLimit() async {
    return await requestMarginApi(HttpMethod.get, 'margin/isolated/accountLimit', signed: true);
  }

  /// Get isolated margin symbol
  /// https://binance-docs.github.io/apidocs/spot/en/#query-isolated-margin-symbol-user_data
  Future<ApiResponse> isolatedSymbol({required String symbol}) async {
    return await requestMarginApi(HttpMethod.get, 'margin/isolated/pair', signed: true, params: {'symbol': symbol});
  }

  /// Get all isolated margin symbol
  /// https://binance-docs.github.io/apidocs/spot/en/#get-all-isolated-margin-symbol-user_data
  Future<ApiResponse> isolatedSymbols() async {
    return await requestMarginApi(HttpMethod.get, 'margin/isolated/allPairs', signed: true);
  }

  /// Get isolated margin fee data
  /// User's current specific margin data will be returned if [vipLevel] is omitted
  /// https://binance-docs.github.io/apidocs/spot/en/#query-isolated-margin-fee-data-user_data
  Future<ApiResponse> isolatedFee({String? symbol, int? vipLevel}) async {
    final params = {
      if (symbol != null) 'symbol': symbol,
      if (vipLevel != null) 'vipLevel': vipLevel,
    };
    return await requestMarginApi(HttpMethod.get, 'margin/isolatedMarginData', signed: true, params: params);
  }

  /// Get isolated margin tier data
  /// https://binance-docs.github.io/apidocs/spot/en/#query-isolated-margin-tier-data-user_data
  Future<ApiResponse> isolatedTier({required String symbol, int? tier}) async {
    final params = {'symbol': symbol, if (tier != null) 'tier': tier};
    return await requestMarginApi(HttpMethod.get, 'margin/isolatedMarginTier', signed: true, params: params);
  }

  // TODO: FROM HERE !!!

  // Cross-margin

  Future<String> margin_stream_get_listen_key() async {
    final _response = await requestMarginApi(HttpMethod.post, 'userDataStream', signed: false, params: {});
    return _response.json['listenKey'];
  }

  Future<ApiResponse> margin_stream_keepAlive(String listenKey) async {
    final Map<String, dynamic> _params = {'listenKey': listenKey};
    return await requestMarginApi(HttpMethod.put, 'userDataStream', signed: false, params: _params);
  }

  Future<ApiResponse> margin_stream_close(String listenKey) async {
    final Map<String, dynamic> _params = {'listenKey': listenKey};
    return await requestMarginApi(HttpMethod.delete, 'userDataStream', signed: false, params: _params);
  }

  // Isolated margin

  Future<String> isolated_margin_stream_get_listen_key(String symbol) async {
    final Map<String, dynamic> _params = {'symbol': symbol};
    final _response =
        await requestMarginApi(HttpMethod.post, 'userDataStream/isolated', signed: false, params: _params);
    return _response.json['listenKey'];
  }

  Future isolated_margin_stream_keepAlive(String symbol, String listenKey) async {
    final Map<String, dynamic> _params = {'symbol': symbol, 'listenKey': listenKey};
    return await requestMarginApi(HttpMethod.put, 'userDataStream/isolated', signed: false, params: _params);
  }

  Future isolated_margin_stream_close(String symbol, String listenKey) async {
    final Map<String, dynamic> _params = {'symbol': symbol, 'listenKey': listenKey};
    return await requestMarginApi(HttpMethod.delete, 'userDataStream/isolated', signed: false, params: _params);
  }

  // Lending Endpoints

  Future get_lending_product_list() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'lending/daily/product/list', signed: true, params: _params);
  }

  Future get_lending_daily_quota_left() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'lending/daily/userLeftQuota', signed: true, params: _params);
  }

  Future purchase_lending_product() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'lending/daily/purchase', signed: true, params: _params);
  }

  Future get_lending_daily_redemption_quota() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'lending/daily/userRedemptionQuota', signed: true, params: _params);
  }

  Future redeem_lending_product() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'lending/daily/redeem', signed: true, params: _params);
  }

  Future get_lending_position() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'lending/daily/token/position', signed: true, params: _params);
  }

  Future get_fixed_activity_project_list() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'lending/project/list', signed: true, params: _params);
  }

  Future get_lending_account() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'lending/union/account', signed: true, params: _params);
  }

  Future get_lending_purchase_history() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'lending/union/purchaseRecord', signed: true, params: _params);
  }

  Future get_lending_redemption_history() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'lending/union/redemptionRecord', signed: true, params: _params);
  }

  Future get_lending_interest_history() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'lending/union/interestHistory', signed: true, params: _params);
  }

  Future change_fixed_activity_to_daily_position() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'lending/positionChanged', signed: true, params: _params);
  }

  // Sub Accounts

  Future get_sub_account_list() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'sub-account/list', signed: true, params: _params);
  }

  Future get_sub_account_transfer_history() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'sub-account/sub/transfer/history', signed: true, params: _params);
  }

  Future get_sub_account_futures_transfer_history() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'sub-account/futures/internalTransfer',
        signed: true, params: _params);
  }

  Future create_sub_account_futures_transfer() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'sub-account/futures/internalTransfer',
        signed: true, params: _params);
  }

  Future get_sub_account_assets() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'sub-account/assets', signed: true, params: _params);
  }

  Future query_subAccount_spot_summary() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'sub-account/spotSummary', signed: true, params: _params);
  }

  Future get_subAccount_deposit_address() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'capital/deposit/subAddress', signed: true, params: _params);
  }

  Future get_subAccount_deposit_history() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'capital/deposit/subHisrec', signed: true, params: _params);
  }

  Future get_subAccount_futures_margin_status() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'sub-account/status', signed: true, params: _params);
  }

  Future enable_subAccount_margin() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'sub-account/margin/enable', signed: true, params: _params);
  }

  Future get_subAccount_margin_details() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'sub-account/margin/account', signed: true, params: _params);
  }

  Future get_subAccount_margin_summary() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'sub-account/margin/accountSummary', signed: true, params: _params);
  }

  Future enable_subAccount_futures() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'sub-account/futures/enable', signed: true, params: _params);
  }

  Future get_subAccount_futures_details() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'sub-account/futures/account', signed: true, params: _params);
  }

  Future get_subAccount_futures_summary() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'sub-account/futures/accountSummary', signed: true, params: _params);
  }

  Future get_subAccount_futures_positionRisk() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'sub-account/futures/positionRisk', signed: true, params: _params);
  }

  Future make_subAccount_futures_transfer() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'sub-account/futures/transfer', signed: true, params: _params);
  }

  Future make_subAccount_margin_transfer() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'sub-account/margin/transfer', signed: true, params: _params);
  }

  Future make_subAccount_to_subAccount_transfer() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'sub-account/transfer/subToSub', signed: true, params: _params);
  }

  Future make_subAccount_to_master_transfer() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'sub-account/transfer/subToMaster', signed: true, params: _params);
  }

  Future get_subAccount_transfer_history() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'sub-account/transfer/subUserHistory', signed: true, params: _params);
  }

  Future make_subAccount_universal_transfer() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'sub-account/universalTransfer', signed: true, params: _params);
  }

  Future get_universal_transfer_history() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'sub-account/universalTransfer', signed: true, params: _params);
  }

  // Futures API

  Future futures_ping() async {
    return await requestFuturesApi(HttpMethod.get, 'ping');
  }

  Future futures_time() async {
    return await requestFuturesApi(HttpMethod.get, 'time');
  }

  Future futures_exchange_info() async {
    return await requestFuturesApi(HttpMethod.get, 'exchangeInfo');
  }

  Future futures_order_book() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'depth', params: _params);
  }

  Future futures_historical_trades() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'historicalTrades', params: _params);
  }

  Future futures_aggregate_trades() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'aggTrades', params: _params);
  }

  Future futures_kLines() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'klines', params: _params);
  }

  Future futures_continous_kLines() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'continuousKlines', params: _params);
  }

  Future futures_mark_price() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'premiumIndex', params: _params);
  }

  Future futures_funding_rate() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'fundingRate', params: _params);
  }

  Future futures_top_longshort_account_ratio() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'topLongShortAccountRatio', params: _params);
  }

  Future futures_top_longshort_position_ratio() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'topLongShortPositionRatio', params: _params);
  }

  Future futures_global_longshort_ratio() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'globalLongShortAccountRatio', params: _params);
  }

  Future futures_ticker() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'ticker/24hr', params: _params);
  }

  Future futures_symbol_ticker() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'ticker/price', params: _params);
  }

  Future futures_orderbook_ticker() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'ticker/bookTicker', params: _params);
  }

  Future futures_liquidation_orders() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'forceOrders', params: _params);
  }

  Future futures_adl_quantile_estimate() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'adlQuantile', signed: true, params: _params);
  }

  Future futures_open_interest() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'openInterest', params: _params);
  }

  Future futures_open_interest_hist() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'openInterestHist', params: _params);
  }

  Future futures_leverage_bracket() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'leverageBracket', signed: true, params: _params);
  }

  Future futures_account_transfer() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.post, 'futures/transfer', signed: true, params: _params);
  }

  Future transfer_history() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'futures/transfer', signed: true, params: _params);
  }

  Future futures_create_order() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.post, 'order', signed: true, params: _params);
  }

  Future futures_place_batch_order() async {
    // TODO: not done
    // query_string = urlencode(params)
    // query_string = query_string.replace('%27', '%22')
    // params['batchOrders'] = query_string[12:]

    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.post, 'batchOrders', signed: true, params: _params);
  }

  Future futures_get_order() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'order', signed: true, params: _params);
  }

  Future futures_get_open_orders() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'openOrders', signed: true, params: _params);
  }

  Future futures_get_all_orders() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'allOrders', signed: true, params: _params);
  }

  Future futures_cancel_order() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.delete, 'order', signed: true, params: _params);
  }

  Future futures_cancel_all_open_orders() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.delete, 'allOpenOrders', signed: true, params: _params);
  }

  Future futures_cancel_orders() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.delete, 'batchOrders', signed: true, params: _params);
  }

  Future futures_account_balance() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'balance', signed: true, params: _params);
  }

  Future futures_account() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'account', signed: true, params: _params);
  }

  Future futures_change_leverage() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.post, 'leverage', signed: true, params: _params);
  }

  Future futures_change_margin_type() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.post, 'marginType', signed: true, params: _params);
  }

  Future futures_change_position_margin() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.post, 'positionMargin', signed: true, params: _params);
  }

  Future futures_position_margin_history() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'positionMargin/history', signed: true, params: _params);
  }

  Future futures_position_information() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'positionRisk', signed: true, params: _params);
  }

  Future futures_account_trades() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'userTrades', signed: true, params: _params);
  }

  Future futures_income_history() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'income', signed: true, params: _params);
  }

  Future futures_change_position_mode() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.post, 'positionSide/dual', signed: true, params: _params);
  }

  Future futures_get_position_mode() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesApi(HttpMethod.get, 'positionSide/dual', signed: true, params: _params);
  }

  Future futures_change_multi_assets_mode(bool multiAssetsMargin) async {
    final Map<String, dynamic> _params = {'multiAssetsMargin': multiAssetsMargin}; // TODO: check '$multiAssetsMargin'
    return await requestFuturesApi(HttpMethod.post, 'multiAssetsMargin', signed: true, params: _params);
  }

  Future futures_get_multi_assets_mode() async {
    return await requestFuturesApi(HttpMethod.get, 'multiAssetsMargin', signed: true, params: {});
  }

  Future<String> futures_stream_get_listen_key() =>
      requestFuturesApi(HttpMethod.post, 'listenKey', signed: false, params: {}).then((r) => r.json['listenKey']);

  Future futures_stream_keepAlive(String listenKey) async {
    final Map<String, dynamic> _params = {'listenKey': listenKey};
    return await requestFuturesApi(HttpMethod.put, 'listenKey', signed: false, params: _params);
  }

  Future futures_stream_close(String listenKey) async {
    final Map<String, dynamic> _params = {'listenKey': listenKey};
    return await requestFuturesApi(HttpMethod.delete, 'listenKey', signed: false, params: _params);
  }

  // COIN Futures API

  Future futures_coin_ping() async {
    return await requestFuturesCoinApi(HttpMethod.get, 'ping');
  }

  Future futures_coin_time() async {
    return await requestFuturesCoinApi(HttpMethod.get, 'time');
  }

  Future futures_coin_exchange_info() async {
    return await requestFuturesCoinApi(HttpMethod.get, 'exchangeInfo');
  }

  Future futures_coin_order_book() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'depth', params: _params);
  }

  Future futures_coin_recent_trades() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'trades', params: _params);
  }

  Future futures_coin_historical_trades() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'historicalTrades', params: _params);
  }

  Future futures_coin_aggregate_trades() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'historicalTrades', params: _params);
  }

  Future futures_coin_klines() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'klines', params: _params);
  }

  Future futures_coin_continous_klines() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'continuousKlines', params: _params);
  }

  Future futures_coin_index_price_klines() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'indexPriceKlines', params: _params);
  }

  Future futures_coin_mark_price_klines() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'markPriceKlines', params: _params);
  }

  Future futures_coin_mark_price() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'premiumIndex', params: _params);
  }

  Future futures_coin_funding_rate() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'fundingRate', params: _params);
  }

  Future futures_coin_ticker() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'ticker/24hr', params: _params);
  }

  Future futures_coin_symbol_ticker() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'ticker/price', params: _params);
  }

  Future futures_coin_orderbook_ticker() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'ticker/bookTicker', params: _params);
  }

  Future futures_coin_liquidation_orders() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'forceOrders', params: _params);
  }

  Future futures_coin_open_interest() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'openInterest', params: _params);
  }

  Future futures_coin_open_interest_hist() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'openInterestHist', params: _params);
  }

  Future futures_coin_leverage_bracket() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'leverageBracket', signed: true, version: 2, params: _params);
  }

  Future futures_coin_create_order() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.post, 'order', signed: true, params: _params);
  }

  Future futures_coin_place_batch_order() async {
    // TODO: not done
    // query_string = urlencode(params)
    // query_string = query_string.replace('%27', '%22')
    // params['batchOrders'] = query_string[12:]

    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.post, 'batchOrders', signed: true, params: _params);
  }

  Future futures_coin_get_order() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'order', signed: true, params: _params);
  }

  Future futures_coin_get_open_orders() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'openOrders', signed: true, params: _params);
  }

  Future futures_coin_get_all_orders() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'allOrders', signed: true, params: _params);
  }

  Future futures_coin_cancel_order() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.delete, 'order', signed: true, params: _params);
  }

  Future futures_coin_cancel_all_open_orders() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.delete, 'allOpenOrders', signed: true, params: _params);
  }

  Future futures_coin_cancel_orders() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.delete, 'batchOrders', signed: true, params: _params);
  }

  Future futures_coin_account_balance() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'balance', signed: true, params: _params);
  }

  Future futures_coin_account() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'account', signed: true, params: _params);
  }

  Future<ApiResponse> futures_coin_change_leverage() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.post, 'leverage', signed: true, params: _params);
  }

  Future<ApiResponse> futures_coin_change_margin_type() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.post, 'marginType', signed: true, params: _params);
  }

  Future<ApiResponse> futures_coin_change_position_margin() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.post, 'positionMargin', signed: true, params: _params);
  }

  Future<ApiResponse> futures_coin_position_margin_history() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'positionMargin/history', signed: true, params: _params);
  }

  Future<ApiResponse> futures_coin_position_information() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'positionRisk', signed: true, params: _params);
  }

  Future<ApiResponse> futures_coin_account_trades() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'userTrades', signed: true, params: _params);
  }

  Future<ApiResponse> futures_coin_income_history() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'income', signed: true, params: _params);
  }

  Future<ApiResponse> futures_coin_change_position_mode() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.post, 'positionSide/dual', signed: true, params: _params);
  }

  Future<ApiResponse> futures_coin_get_position_mode() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'positionSide/dual', signed: true, params: _params);
  }

  Future<String> futures_coin_stream_get_listen_key() =>
      requestFuturesCoinApi(HttpMethod.post, 'listenKey', signed: false, params: {}).then((r) => r.json['listenKey']);

  Future futures_coin_stream_keepAlive(String listenKey) async {
    final Map<String, dynamic> _params = {'listenKey': listenKey};
    return await requestFuturesCoinApi(HttpMethod.put, 'listenKey', signed: false, params: _params);
  }

  Future futures_coin_stream_close(String listenKey) async {
    final Map<String, dynamic> _params = {'listenKey': listenKey};
    return await requestFuturesCoinApi(HttpMethod.delete, 'listenKey', signed: false, params: _params);
  }

  /// =================================================================================================================
  /// Options API
  /// =================================================================================================================

  // Quoting interface endpoints

  Future options_ping() async {
    return await requestOptionsApi(HttpMethod.get, 'ping');
  }

  Future options_time() async {
    return await requestOptionsApi(HttpMethod.get, 'time');
  }

  Future options_info() async {
    return await requestOptionsApi(HttpMethod.get, 'optionInfo');
  }

  Future options_exchange_info() async {
    return await requestOptionsApi(HttpMethod.get, 'exchangeInfo');
  }

  Future options_index_price() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.get, 'index', params: _params);
  }

  Future options_price() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.get, 'ticker', params: _params);
  }

  Future options_mark_price() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.get, 'mark', params: _params);
  }

  Future options_order_book() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.get, 'depth', params: _params);
  }

  Future options_klines() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.get, 'klines', params: _params);
  }

  Future options_recent_trades() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.get, 'trades', params: _params);
  }

  Future options_historical_trades() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.get, 'historicalTrades', params: _params);
  }

  // Account and trading interface endpoints

  Future options_account_info() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.get, 'account', signed: true, params: _params);
  }

  Future options_funds_transfer() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.post, 'transfer', signed: true, params: _params);
  }

  Future options_positions() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.get, 'position', signed: true, params: _params);
  }

  Future options_bill() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.post, 'bill', signed: true, params: _params);
  }

  Future options_place_order() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.post, 'order', signed: true, params: _params);
  }

  Future options_place_batch_order() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.post, 'batchOrders', signed: true, params: _params);
  }

  Future options_cancel_order() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.delete, 'order', signed: true, params: _params);
  }

  Future options_cancel_batch_order() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.delete, 'batchOrders', signed: true, params: _params);
  }

  Future options_cancel_all_orders() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.delete, 'allOpenOrders', signed: true, params: _params);
  }

  Future options_query_order() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.get, 'order', signed: true, params: _params);
  }

  Future options_query_pending_orders() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.get, 'openOrders', signed: true, params: _params);
  }

  Future options_query_order_history() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.get, 'historyOrders', signed: true, params: _params);
  }

  Future options_user_trades() async {
    final Map<String, dynamic> _params = {};
    return await requestOptionsApi(HttpMethod.get, 'userTrades', signed: true, params: _params);
  }

  // Fiat Endpoints

  Future get_fiat_deposit_withdraw_history() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'fiat/orders', signed: true, params: _params);
  }

  Future get_fiat_payments_history() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'fiat/payments', signed: true, params: _params);
  }

  // C2C Endpoints

  Future get_c2c_trade_history() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'c2c/orderMatch/listUserOrderHistory', signed: true, params: _params);
  }
}
