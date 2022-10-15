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
      _timeOffset = Duration(milliseconds: srvTime - now.millisecondsSinceEpoch - now.timeZoneOffset.inMilliseconds);
    } catch (err) {
      throw Exception('failed to init API $err'); // TODO: other type of exception
    }
  }

  // General Endpoints
  Future<bool> ping() => _get('ping', version: BnApiUrls.privateApiVersion).then((r) => true);

  Future<int> getServerTime() => _get('time', version: BnApiUrls.privateApiVersion).then((r) => r['serverTime']);

  // Exchange Endpoints
  Future getProducts() => _requestWebsite(HttpMethod.get, BnApiUrls.exchangeProducts).then((r) => r);

  Future getExchangeInfo() => _get('exchangeInfo', version: BnApiUrls.privateApiVersion).then((r) => r);

  Future getSymbolInfo(String symbol) =>
      getExchangeInfo().then((value) => value['symbols'].firstWhere((e) => e['symbol'] == symbol.toUpperCase()));

  // Market Data Endpoints
  Future getAllTickers() => _get('ticker/price', version: BnApiUrls.privateApiVersion).then((r) => r);

  Future getTicker(String symbol) =>
      _get('ticker/price', version: BnApiUrls.privateApiVersion, params: {'symbol': symbol}).then((r) => r);

  Future getOrderBookTickers(String symbol) =>
      _get('ticker/bookTicker', version: BnApiUrls.privateApiVersion).then((r) => r);

  Future getOrderBook(Map<String, dynamic> params) =>
      _get('depth', version: BnApiUrls.privateApiVersion, params: params).then((r) => r);

  Future getRecentTrades(Map<String, dynamic> params) => _get('trades', params: params).then((r) => r);

  Future getHistoricalTrades(Map<String, dynamic> params) =>
      _get('historicalTrades', version: BnApiUrls.privateApiVersion, params: params).then((r) => r);

  Future getAggregateTrades(Map<String, dynamic> params) =>
      _get('aggTrades', version: BnApiUrls.privateApiVersion, params: params).then((r) => r);

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
    return await _get('klines', version: BnApiUrls.privateApiVersion, params: params);
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
    var kline = await _kLines(
      params,
      kLinesType: kLinesType,
    );
    return kline[0][0];
  }

  Future getHistoricalKLines(String symbol, int interval,
      {String? startStr, String? endStr, int limit = 1000, KLinesType kLinesType = KLinesType.spot}) async {
    return await _historicalKLines(symbol, interval,
        startStr: startStr, endStr: endStr, limit: limit, kLinesType: kLinesType);
  }

  Future _historicalKLines(String symbol, int interval,
      {String? startStr, String? endStr, int limit = 1000, KLinesType kLinesType = KLinesType.spot}) async {
    final outputData = [];
    // timeframe = interval_to_milliseconds(interval)
  }

// # convert interval to useful value in seconds
// timeframe = interval_to_milliseconds(interval)
//
// # establish first available start timestamp
// start_ts = convert_ts_str(start_str)
// if start_ts is not None:
// first_valid_ts = await self._get_earliest_valid_timestamp(symbol, interval, klines_type)
// start_ts = max(start_ts, first_valid_ts)
//
// # if an end time was passed convert it
// end_ts = convert_ts_str(end_str)
// if end_ts and start_ts and end_ts <= start_ts:
// return output_data
//
// idx = 0
// while True:
// # fetch the klines from start_ts up to max 500 entries or the end_ts if set
// temp_data = await self._klines(
// klines_type=klines_type,
// symbol=symbol,
// interval=interval,
// limit=limit,
// startTime=start_ts,
// endTime=end_ts
// )
//
// # append this loops data to our output data
// if temp_data:
// output_data += temp_data
//
// # handle the case where exactly the limit amount of data was returned last loop
// # or check if we received less than the required limit and exit the loop
// if not len(temp_data) or len(temp_data) < limit:
// # exit the while loop
// break
//
// # set our start timestamp using the last value in the array
// # and increment next call by our timeframe
// start_ts = temp_data[-1][0] + timeframe
//
// # exit loop if we reached end_ts before reaching <limit> klines
// if end_ts and start_ts >= end_ts:
// break
//
// # sleep after every 3rd call to be kind to the API
// idx += 1
// if idx % 3 == 0:
// await asyncio.sleep(1)
//
// return output_data
// _historical_klines.__doc__ = Client._historical_klines.__doc__
//
// async def get_historical_klines_generator(self, symbol, interval, start_str=None, end_str=None, limit=1000,
// klines_type: HistoricalKlinesType = HistoricalKlinesType.SPOT):
// return self._historical_klines_generator(
// symbol, interval, start_str, end_str=end_str, limit=limit, klines_type=klines_type
// )
// get_historical_klines_generator.__doc__ = Client.get_historical_klines_generator.__doc__
//
// async def _historical_klines_generator(self, symbol, interval, start_str=None, end_str=None, limit=1000,
// klines_type: HistoricalKlinesType = HistoricalKlinesType.SPOT):
//
// # convert interval to useful value in seconds
// timeframe = interval_to_milliseconds(interval)
//
// # if a start time was passed convert it
// start_ts = convert_ts_str(start_str)
//
// # establish first available start timestamp
// if start_ts is not None:
// first_valid_ts = await self._get_earliest_valid_timestamp(symbol, interval, klines_type)
// start_ts = max(start_ts, first_valid_ts)
//
// # if an end time was passed convert it
// end_ts = convert_ts_str(end_str)
// if end_ts and start_ts and end_ts <= start_ts:
// return
//
// idx = 0
// while True:
// # fetch the klines from start_ts up to max 500 entries or the end_ts if set
// output_data = await self._klines(
// klines_type=klines_type,
// symbol=symbol,
// interval=interval,
// limit=limit,
// startTime=start_ts,
// endTime=end_ts
// )
//
// # yield data
// if output_data:
// for o in output_data:
// yield o
//
// # handle the case where exactly the limit amount of data was returned last loop
// # check if we received less than the required limit and exit the loop
// if not len(output_data) or len(output_data) < limit:
// # exit the while loop
// break
//
// # increment next call by our timeframe
// start_ts = output_data[-1][0] + timeframe
//
// # exit loop if we reached end_ts before reaching <limit> klines
// if end_ts and start_ts >= end_ts:
// break
//
// # sleep after every 3rd call to be kind to the API
// idx += 1
// if idx % 3 == 0:
// await asyncio.sleep(1)
// _historical_klines_generator.__doc__ = Client._historical_klines_generator.__doc__
}
