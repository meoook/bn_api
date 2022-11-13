import 'dart:convert';
export 'constants.dart';
export 'objects/exchange_info.dart';
export 'objects/acc_objects.dart';
export 'objects/orders_objects.dart';

// enum KLinesType { spot, futures, futuresCoin }

enum HttpMethod { get, post, put, delete }

enum Status { preTrading, trading, postTrading, endOfDay, halt, auctionMatch, breakTrading }

/// Maps [Status] to a Binance string
const statusMap = <String, Status>{
  'PRE_TRADING': Status.preTrading,
  'TRADING': Status.trading,
  'POST_TRADING': Status.postTrading,
  'END_OF_DAY': Status.endOfDay,
  'HALT': Status.halt,
  'AUCTION_MATCH': Status.auctionMatch,
  'BREAK': Status.breakTrading
};

class BinanceApiException implements Exception {
  late int code;
  late String message;

  BinanceApiException(String data) {
    try {
      final _json = jsonDecode(data);
      code = _json['code'];
      message = _json['msg'];
    } catch (e) {
      code = 600;
      message = 'Fail to serialize error to JSON';
    }
  }

  @override
  String toString() => '$code $message';
}

class SymbolProduct {
  final String symbol;
  final Status status;

  final num open;
  final num high;
  final num low;
  final num close;

  final String baseAsset;
  final String baseAssetName;
  final num baseAssetPrecision;

  final String quoteAsset;
  final String quoteAssetName;
  final num quoteAssetPrecision;

  // final List<OrderType> orderTypes;
  // final bool icebergAllowed;
  // List<Filter> filters;

  SymbolProduct(Map m)
      : symbol = m['s'],
        status = statusMap[m['st']]!,
        open = m['o'],
        high = m['h'],
        low = m['l'],
        close = m['c'],
        baseAsset = m['b'],
        baseAssetName = m['an'],
        baseAssetPrecision = m['i'],
        quoteAsset = m['q'],
        quoteAssetName = m['qn'],
        quoteAssetPrecision = m['ts']
  // orderTypes = List<String>.from(m['orderTypes']).map((s) => orderTypeMap[s]!).toList(),
  // icebergAllowed = m['icebergAllowed']
  ;

  @override
  String toString() {
    return '$baseAsset:$quoteAsset $status';
  }
}

class CandleStick {
  /// Kline/candlestick
  final DateTime openTime; // Kline open time
  final double openPrice; // Open price
  final double highPrice; // High price
  final double lowPrice; // Low price
  final double closePrice; // Close price
  final double volume; // Volume
  final DateTime closeTime; // Kline Close time
  final double quoteVolume; // Quote asset volume
  final int numberOfTrades; // Number of trades
  final double takerBaseVolume; // Taker buy base asset volume
  final double takerQuoteVolume; // Taker buy quote asset volume

  CandleStick(List m)
      : openTime = DateTime.fromMillisecondsSinceEpoch(m[0]),
        openPrice = double.parse(m[1]),
        highPrice = double.parse(m[2]),
        lowPrice = double.parse(m[3]),
        closePrice = double.parse(m[4]),
        volume = double.parse(m[5]),
        closeTime = DateTime.fromMillisecondsSinceEpoch(m[6]),
        quoteVolume = double.parse(m[7]),
        numberOfTrades = m[8],
        takerBaseVolume = double.parse(m[9]),
        takerQuoteVolume = double.parse(m[10]);

  @override
  String toString() {
    return 'close: $closePrice volume: $volume';
  }
}

class AvgPrice {
  /// AvgPrice
  final int mins;
  final double price;

  AvgPrice(Map m)
      : mins = m['mins'],
        price = double.parse(m['price']);

  @override
  String toString() {
    return 'mins: $mins price: $price';
  }
}
