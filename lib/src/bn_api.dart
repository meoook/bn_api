import 'base_api.dart';
import 'constants.dart';
import 'objects.dart';

class BnApi extends BaseClient {
  BnApi({String? apiKey, String? apiSecret, bool testnet = false, Map<String, String>? requestParams})
      : super(apiKey: apiKey, apiSecret: apiSecret, testnet: testnet, requestParams: requestParams) {
    _init();
  }

  void _init() async {
    try {
      await ping();
      // calculate timestamp offset between local and binance server
      final srvTime = await getServerTime();
      final DateTime now = DateTime.now();
      timeOffset = Duration(milliseconds: srvTime - now.millisecondsSinceEpoch);
    } catch (err) {
      throw Exception('failed to init API $err'); // TODO: other type of exception
    }
  }

  // General Endpoints
  Future<bool> ping() => get('ping', version: BnApiUrls.privateApiVersion).then((r) => true);

  Future<int> getServerTime() => get('time', version: BnApiUrls.privateApiVersion).then((r) => r['serverTime']);

  // Exchange Endpoints
  Future getProducts() => requestWebsite(HttpMethod.get, BnApiUrls.exchangeProducts).then((r) => r);

  Future getExchangeInfo() => get('exchangeInfo', version: BnApiUrls.privateApiVersion).then((r) => r);

  Future getSymbolInfo(String symbol) =>
      getExchangeInfo().then((value) => value['symbols'].firstWhere((e) => e['symbol'] == symbol.toUpperCase()));

  // Market Data Endpoints
  Future getAllTickers() => get('ticker/price', version: BnApiUrls.privateApiVersion).then((r) => r);

  Future getTicker(String symbol) =>
      get('ticker/price', version: BnApiUrls.privateApiVersion, params: {'symbol': symbol}).then((r) => r);

  Future getOrderBookTickers(String symbol) =>
      get('ticker/bookTicker', version: BnApiUrls.privateApiVersion).then((r) => r);

  Future getOrderBook(Map<String, dynamic> params) =>
      get('depth', version: BnApiUrls.privateApiVersion, params: params).then((r) => r);

  Future getRecentTrades(Map<String, dynamic> params) => get('trades', params: params).then((r) => r);

  Future getHistoricalTrades(Map<String, dynamic> params) =>
      get('historicalTrades', version: BnApiUrls.privateApiVersion, params: params).then((r) => r);

  Future getAggregateTrades(Map<String, dynamic> params) =>
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
        trades = await getAggregateTrades({'symbol': symbol, 'fromId': 0});
      } else {
        // The difference between startTime and endTime should be less
        // or equal than an hour and the result set should contain at least one trade.
        var startTs = 123;
        int endTs;
        // If the resulting set is empty (i.e. no trades in that interval)
        // then we just move forward hour by hour until we find at least on trade or reach present moment
        while (true) {
          endTs = startTs + (60 * 60 * 1000);
          trades = await getAggregateTrades({'symbol': symbol, 'startTime': startTs, 'endTime': endTs});
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
      lastID = trades[-1][BnAggKeys.aggID];

      while (true) {
        // There is no need to wait between queries, to avoid hitting the
        // rate limit. We're using blocking IO, and as long as we're the
        // only thread running calls like this, Binance will automatically
        // add the right delay time on their end, forcing us to wait for
        // data. That really simplifies this function's job. Binance is fucking awesome.
        trades = await getAggregateTrades({'symbol': symbol, 'fromId': lastID});
        // fromId=n returns a set starting with id n, but we already have that one.
        // So get rid of the first item in the result set.
        trades = trades.sublist(1);
        if (trades.isEmpty) return;
        for (var i = 0; i < trades.length; i++) {
          yield trades[i];
        }
        lastID = trades[-1][BnAggKeys.aggID];
      }
    }
  }

  Future getKLines(Map<String, dynamic> params) async {
    return await get('klines', version: BnApiUrls.privateApiVersion, params: params);
  }

  Future _kLines(Map<String, dynamic> params, {KLinesType kLinesType = KLinesType.spot}) async {
    if (params.containsKey('endTime') && params['endTime'].isEmpty) params.remove('endTime');
    switch (kLinesType) {
      case KLinesType.spot:
        return await getKLines(params);
      // case KLinesType.futures:
      //   return await futuresKlines(params);
      // case KLinesType.futuresCoin:
      //   return await futuresCoinKlines(params);
    }
  }

  Future _getEarliestValidTimestamp(String symbol, int interval, {KLinesType kLinesType = KLinesType.spot}) async {
    final params = {
      'symbol': symbol,
      'interval': interval,
      'limit': 1,
      'startTime': 0,
      'endTime': DateTime.now().millisecondsSinceEpoch
    };
    var kline = await _kLines(params, kLinesType: kLinesType);
    return kline[0][0];
  }

  Future getHistoricalKLines(String symbol, int interval,
      {String? startStr, String? endStr, int limit = 1000, KLinesType kLinesType = KLinesType.spot}) async {
    return await _historicalKLines(symbol, interval,
        startStr: startStr, endStr: endStr, limit: limit, kLinesType: kLinesType);
  }

  Future _historicalKLines(String symbol, int interval,
      {String? startStr, String? endStr, int limit = 1000, KLinesType kLinesType = KLinesType.spot}) async {
    // TODO: not implemented
    // final outputData = [];
    // timeframe = interval_to_milliseconds(interval)
  }

  Future getHistoricalKLinesGenerator(String symbol, int interval,
      {String? startStr, String? endStr, int limit = 1000, KLinesType kLinesType = KLinesType.spot}) async {
    return await _historicalKLinesGenerator(symbol, interval,
        startStr: startStr, endStr: endStr, limit: limit, kLinesType: kLinesType);
  }

  Future _historicalKLinesGenerator(String symbol, int interval,
      {String? startStr, String? endStr, int limit = 1000, KLinesType kLinesType = KLinesType.spot}) async {
    // TODO: not implemented
  }

  // TODO: set params
  Future getAvgPrice(String symbol) =>
      get('avgPrice', version: BnApiUrls.privateApiVersion, params: {'symbol': symbol}).then((r) => r);

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
    String side,
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
      BnApiOrderType.orderTypeLimit,
      price: price,
      quantity: quantity,
      timeInForce: timeInForce ?? BnTimeInForce.timeInForceGtc,
    );
  }

  Future order_limit_buy(String symbol, double price, double quantity, {String? timeInForce}) async {
    return await createOrder(
      symbol,
      BaseClient.sideBuy,
      BnApiOrderType.orderTypeLimit,
      price: price,
      quantity: quantity,
      timeInForce: timeInForce ?? BnTimeInForce.timeInForceGtc,
    );
  }

  Future order_limit_sell(String symbol, double price, double quantity, {String? timeInForce}) async {
    return await createOrder(
      symbol,
      BaseClient.sideSell,
      BnApiOrderType.orderTypeLimit,
      price: price,
      quantity: quantity,
      timeInForce: timeInForce ?? BnTimeInForce.timeInForceGtc,
    );
  }

  Future orderMarket(String symbol, String side, double price, double quantity, {String? timeInForce}) async {
    return await createOrder(
      symbol,
      side,
      BnApiOrderType.orderTypeMarket,
      price: price,
      quantity: quantity,
      timeInForce: timeInForce ?? BnTimeInForce.timeInForceGtc,
    );
  }

  Future order_market_buy(String symbol, double price, double quantity, {String? timeInForce}) async {
    return await createOrder(
      symbol,
      BaseClient.sideBuy,
      BnApiOrderType.orderTypeMarket,
      price: price,
      quantity: quantity,
      timeInForce: timeInForce ?? BnTimeInForce.timeInForceGtc,
    );
  }

  Future order_market_sell(String symbol, double price, double quantity, {String? timeInForce}) async {
    return await createOrder(
      symbol,
      BaseClient.sideSell,
      BnApiOrderType.orderTypeMarket,
      price: price,
      quantity: quantity,
      timeInForce: timeInForce ?? BnTimeInForce.timeInForceGtc,
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
    String side,
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
  Future get_account() async {
    return await get('account', signed: true);
  }

  /// Get balance for selected asset/coin
  ///  "asset": "BTC",
  ///  "free": "4723846.89208129",
  ///  "locked": "0.00000000"
  Future<Map<String, dynamic>?> getAssetBalance(String asset) async {
    final Map _res = await get_account();
    if (_res.containsKey('balances')) {
      final List<Map<String, dynamic>> _balances = _res['balances'];
      final _balancesIterator = _balances.iterator;
      while (_balancesIterator.moveNext()) {
        final Map<String, dynamic> _balance = _balancesIterator.current;
        if (_balance['asset'].toLowerCase() == asset.toLowerCase()) return _balance;
      }
    }
    return null;
  }

  Future get_my_trades() async {
    return await get('myTrades', signed: true);
  }

  Future get_system_status() async {
    return await requestMarginApi(HttpMethod.get, 'system/status');
  }

  Future get_account_status() async {
    return await requestMarginApi(HttpMethod.get, 'account/status', signed: true);
  }

  Future get_account_api_trading_status() async {
    return await requestMarginApi(HttpMethod.get, 'account/apiTradingStatus', signed: true);
  }

  Future get_account_api_permissions() async {
    return await requestMarginApi(HttpMethod.get, 'account/apiRestrictions', signed: true);
  }

  Future get_dust_assets() async {
    return await requestMarginApi(HttpMethod.post, 'asset/dust-btc', signed: true);
  }

  Future get_dust_log() async {
    return await requestMarginApi(HttpMethod.get, 'asset/dribblet', signed: true);
  }

  Future transfer_dust() async {
    return await requestMarginApi(HttpMethod.post, 'asset/dust', signed: true);
  }

  Future get_asset_dividend_history() async {
    return await requestMarginApi(HttpMethod.get, 'asset/assetDividend', signed: true);
  }

  Future make_universal_transfer() async {
    return await requestMarginApi(HttpMethod.post, 'asset/transfer', signed: true);
  }

  Future query_universal_transfer_history() async {
    return await requestMarginApi(HttpMethod.get, 'asset/transfer', signed: true);
  }

  Future get_trade_fee() async {
    return await requestMarginApi(HttpMethod.get, 'asset/tradeFee', signed: true);
  }

  Future get_asset_details() async {
    return await requestMarginApi(HttpMethod.get, 'asset/assetDetail', signed: true);
  }

  // Withdraw Endpoints
  Future withdraw({String? coin, String? name}) async {
    // force a name for the withdrawal if one not set
    final Map<String, dynamic> _params = {
      if (coin != null && name == null) 'name': coin else if (name != null) 'name': name,
    };
    return await requestMarginApi(HttpMethod.post, 'capital/withdraw/apply', signed: true, params: _params);
  }

  Future get_deposit_history() async {
    return await requestMarginApi(HttpMethod.get, 'capital/deposit/hisrec', signed: true);
  }

  Future get_withdraw_history() async {
    return await requestMarginApi(HttpMethod.get, 'capital/withdraw/history', signed: true);
  }

  Future get_withdraw_history_id(int withdrawID) async {
    final _history = await get_withdraw_history();

    final _historyIterator = _history.iterator;
    while (_historyIterator.moveNext()) {
      final Map<String, dynamic> _entry = _historyIterator.current;
      if (_entry.containsKey('id') && _entry['id'] == withdrawID) return _entry;
    }
    throw Exception('there is no entry with withdraw id $withdrawID');
  }

  Future get_deposit_address(String coin, {String? network}) async {
    final Map<String, dynamic> _params = {
      'coin': coin,
      if (network != null) 'network': network,
    };
    return await requestMarginApi(HttpMethod.get, 'capital/deposit/address', signed: true, params: _params);
  }

  // User Stream Endpoints

  Future stream_get_listen_key() async {
    final result = await post('userDataStream', signed: false, params: {});
    return result['listenKey'];
  }

  Future stream_keepAlive(String listenKey) async {
    return await put('userDataStream', signed: false, params: {'listenKey': listenKey});
  }

  Future stream_close(String listenKey) async {
    return await delete('userDataStream', signed: false, params: {'listenKey': listenKey});
  }

  // Margin Trading Endpoints

  Future get_margin_account() async {
    return await requestMarginApi(HttpMethod.get, 'margin/account', signed: true);
  }

  Future get_isolated_margin_account() async {
    return await requestMarginApi(HttpMethod.get, 'margin/isolated/account', signed: true);
  }

  Future enable_isolated_margin_account() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'margin/isolated/account', signed: true, params: _params);
  }

  Future disable_isolated_margin_account() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.delete, 'margin/isolated/account', signed: true, params: _params);
  }

  Future get_margin_asset() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/asset', params: _params);
  }

  Future get_margin_symbol() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/pair', params: _params);
  }

  Future get_margin_all_assets() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/allAssets', params: _params);
  }

  Future get_margin_all_pairs() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/allPairs', params: _params);
  }

  Future create_isolated_margin_account() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'margin/isolated/create', signed: true, params: _params);
  }

  Future get_isolated_margin_symbol() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/isolated/pair', signed: true, params: _params);
  }

  Future get_all_isolated_margin_symbols() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/isolated/allPairs', signed: true, params: _params);
  }

  Future toggle_bnb_burn_spot_margin() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'bnbBurn', signed: true, params: _params);
  }

  Future get_bnb_burn_spot_margin() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'bnbBurn', signed: true, params: _params);
  }

  Future get_margin_price_index() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/priceIndex', params: _params);
  }

  Future transfer_margin_to_spot() async {
    final Map<String, dynamic> _params = {'type': 2};
    return await requestMarginApi(HttpMethod.post, 'margin/transfer', signed: true, params: _params);
  }

  Future transfer_spot_to_margin() async {
    final Map<String, dynamic> _params = {'type': 1};
    return await requestMarginApi(HttpMethod.post, 'margin/transfer', signed: true, params: _params);
  }

  Future transfer_isolated_margin_to_spot() async {
    final Map<String, dynamic> _params = {'transFrom': 'ISOLATED_MARGIN', 'transTo': 'SPOT'};
    return await requestMarginApi(HttpMethod.post, 'margin/isolated/transfer', signed: true, params: _params);
  }

  Future transfer_spot_to_isolated_margin() async {
    final Map<String, dynamic> _params = {'transFrom': 'SPOT', 'transTo': 'ISOLATED_MARGIN'};
    return await requestMarginApi(HttpMethod.post, 'margin/isolated/transfer', signed: true, params: _params);
  }

  Future create_margin_loan() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'margin/loan', signed: true, params: _params);
  }

  Future repay_margin_loan() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'margin/repay', signed: true, params: _params);
  }

  Future create_margin_order() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'margin/order', signed: true, params: _params);
  }

  Future cancel_margin_order() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.delete, 'margin/order', signed: true, params: _params);
  }

  Future get_margin_loan_details() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/loan', signed: true, params: _params);
  }

  Future get_margin_repay_details() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/repay', signed: true, params: _params);
  }

  Future get_cross_margin_data() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/crossMarginData', signed: true, params: _params);
  }

  Future get_margin_interest_history() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/interestHistory', signed: true, params: _params);
  }

  Future get_margin_force_liquidation_rec() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/forceLiquidationRec', signed: true, params: _params);
  }

  Future get_margin_order() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/order', signed: true, params: _params);
  }

  Future get_open_margin_orders() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/openOrders', signed: true, params: _params);
  }

  Future get_all_margin_orders() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/allOrders', signed: true, params: _params);
  }

  Future get_margin_trades() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/myTrades', signed: true, params: _params);
  }

  Future get_max_margin_loan() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/maxBorrowable', signed: true, params: _params);
  }

  Future get_max_margin_transfer() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/maxTransferable', signed: true, params: _params);
  }

  // Margin OCO

  Future create_margin_oco_order() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.post, 'margin/order/oco', signed: true, params: _params);
  }

  Future cancel_margin_oco_order() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.delete, 'margin/orderList', signed: true, params: _params);
  }

  Future get_margin_oco_order() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/orderList', signed: true, params: _params);
  }

  Future get_open_margin_oco_orders() async {
    final Map<String, dynamic> _params = {};
    return await requestMarginApi(HttpMethod.get, 'margin/allOrderList', signed: true, params: _params);
  }

  // Cross-margin

  Future margin_stream_get_listen_key() async {
    final _response = await requestMarginApi(HttpMethod.post, 'userDataStream', signed: false, params: {});
    return _response['listenKey'];
  }

  Future margin_stream_keepAlive(String listenKey) async {
    final Map<String, dynamic> _params = {'listenKey': listenKey};
    return await requestMarginApi(HttpMethod.put, 'userDataStream', signed: false, params: _params);
  }

  Future margin_stream_close(String listenKey) async {
    final Map<String, dynamic> _params = {'listenKey': listenKey};
    return await requestMarginApi(HttpMethod.delete, 'userDataStream', signed: false, params: _params);
  }

  // Isolated margin

  Future isolated_margin_stream_get_listen_key(String symbol) async {
    final Map<String, dynamic> _params = {'symbol': symbol};
    final _res = await requestMarginApi(HttpMethod.post, 'userDataStream/isolated', signed: false, params: _params);
    return _res['listenKey'];
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

  Future futures_historical_kLines(String symbol, int interval, String startStr,
      [String? endStr, int limit = 500]) async {
    return await _historicalKLines(symbol, interval,
        startStr: startStr, endStr: endStr, limit: limit, kLinesType: KLinesType.futures);
  }

  Future futures_historical_kLines_generator(String symbol, int interval, String startStr, [String? endStr]) async {
    return await _historicalKLinesGenerator(symbol, interval,
        startStr: startStr, endStr: endStr, kLinesType: KLinesType.futures);
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

  Future futures_stream_get_listen_key() =>
      requestFuturesApi(HttpMethod.post, 'listenKey', signed: false, params: {}).then((r) => r['listenKey']);

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

  Future new_transfer_history() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'asset/transfer', signed: true, params: _params);
  }

  Future universal_transfer() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.post, 'asset/transfer', signed: true, params: _params);
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

  Future futures_coin_change_leverage() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.post, 'leverage', signed: true, params: _params);
  }

  Future futures_coin_change_margin_type() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.post, 'marginType', signed: true, params: _params);
  }

  Future futures_coin_change_position_margin() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.post, 'positionMargin', signed: true, params: _params);
  }

  Future futures_coin_position_margin_history() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'positionMargin/history', signed: true, params: _params);
  }

  Future futures_coin_position_information() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'positionRisk', signed: true, params: _params);
  }

  Future futures_coin_account_trades() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'userTrades', signed: true, params: _params);
  }

  Future futures_coin_income_history() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'income', signed: true, params: _params);
  }

  Future futures_coin_change_position_mode() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.post, 'positionSide/dual', signed: true, params: _params);
  }

  Future futures_coin_get_position_mode() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'positionSide/dual', signed: true, params: _params);
  }

  Future futures_coin_stream_get_listen_key() =>
      requestFuturesCoinApi(HttpMethod.post, 'listenKey', signed: false, params: {}).then((r) => r['listenKey']);

  Future futures_coin_stream_keepAlive(String listenKey) async {
    final Map<String, dynamic> _params = {'listenKey': listenKey};
    return await requestFuturesCoinApi(HttpMethod.put, 'listenKey', signed: false, params: _params);
  }

  Future futures_coin_stream_close(String listenKey) async {
    final Map<String, dynamic> _params = {'listenKey': listenKey};
    return await requestFuturesCoinApi(HttpMethod.delete, 'listenKey', signed: false, params: _params);
  }

  Future get_all_coins_info() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'capital/config/getall', signed: true, params: _params);
  }

  Future get_account_snapshot() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.get, 'accountSnapshot', signed: true, params: _params);
  }

  Future disable_fast_withdraw_switch() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.post, 'disableFastWithdrawSwitch', signed: true, params: _params);
  }

  Future enable_fast_withdraw_switch() async {
    final Map<String, dynamic> _params = {};
    return await requestFuturesCoinApi(HttpMethod.post, 'enableFastWithdrawSwitch', signed: true, params: _params);
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
