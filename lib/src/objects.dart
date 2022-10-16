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
  final int code;
  final String message;

  BinanceApiException(this.code, this.message);

  @override
  String toString() => message;
}


class SymbolProduct {
  final String symbol;

  final Status status;

  final String baseAsset;
  final num baseAssetPrecision;

  final String quoteAsset;
  final num quotePrecision;

  final List<OrderType> orderTypes;
  final bool icebergAllowed;
  // List<Filter> filters;

  Symbol.fromMap(Map m)
      : symbol = m['symbol'],
        status = statusMap[m['status']]!,
        baseAsset = m['baseAsset'],
        baseAssetPrecision = m['baseAssetPrecision'],
        quoteAsset = m['quoteAsset'],
        quotePrecision = m['quotePrecision'],
        orderTypes = List<String>.from(m['orderTypes']).map((s) => orderTypeMap[s]!).toList(),
        icebergAllowed = m['icebergAllowed'];
}