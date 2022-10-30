import 'dart:convert';
export 'objects/exchange_info.dart';

enum KLinesType { spot, futures, futuresCoin }

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
      message = _json['message'];
    } catch (e) {
      code = 600;
      message = 'Fail to serialize error to JSON';
    }
  }

  @override
  String toString() => message;
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
