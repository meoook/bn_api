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

class MarginAsset {
  /// MarginAsset
  final String assetName;
  final String assetFullName;
  final bool isBorrowable;
  final bool isMortgageable;
  final double userMinBorrow;
  final double userMinRepay;

  MarginAsset(Map m)
      : assetName = m['assetName'],
        assetFullName = m['assetFullName'],
        isBorrowable = m['isBorrowable'],
        isMortgageable = m['isMortgageable'],
        userMinBorrow = double.parse(m['userMinBorrow']),
        userMinRepay = double.parse(m['userMinRepay']);

  @override
  String toString() {
    return '$assetFullName';
  }
}

class MarginTrade {
  /// MarginTrade
  final double commission;
  final String commissionAsset;
  final int id;
  final bool isBestMatch;
  final bool isBuyer;
  final bool isMaker;
  final int orderId;
  final double price;
  final double qty;
  final String symbol;
  final bool isIsolated;
  final DateTime time;

  MarginTrade(Map m)
      : commission = m['commission'], // double.parse(m['userMinBorrow']),
        commissionAsset = m['commissionAsset'],
        id = m['id'],
        isBestMatch = m['isBestMatch'],
        isBuyer = m['isBuyer'],
        isMaker = m['isMaker'],
        orderId = m['orderId'],
        price = m['price'], // double.parse(m['userMinBorrow']),
        qty = m['qty'], // double.parse(m['userMinBorrow']),
        symbol = m['symbol'],
        isIsolated = m['isIsolated'],
        time = DateTime.fromMillisecondsSinceEpoch(m['time']);

  @override
  String toString() {
    return '$orderId qty: $qty price: $price';
  }
}

class IsolatedTransfer {
  /// IsolatedTransfer
  final double amount;
  final String asset;
  final String status;
  final DateTime timestamp;
  final int txId;
  final String transFrom;
  final String transTo;
  final String? clientTag;

  IsolatedTransfer(Map m)
      : amount = double.parse(m['amount']),
        asset = m['asset'],
        status = m['status'],
        timestamp = DateTime.fromMillisecondsSinceEpoch(m['timestamp']),
        txId = m['txId'],
        transFrom = m['transFrom'],
        transTo = m['transTo'],
        clientTag = m.containsKey('clientTag') ? m['clientTag'] : null;

  @override
  String toString() {
    return '$asset to $transTo amount: $amount';
  }
}

class MarginLevelInfo {
  /// MarginLevelInfo
  final double normalBar;
  final double marginCallBar;
  final double forceLiquidationBar;

  MarginLevelInfo(Map m)
      : normalBar = double.parse(m['normalBar']),
        marginCallBar = double.parse(m['marginCallBar']),
        forceLiquidationBar = double.parse(m['forceLiquidationBar']);

  @override
  String toString() {
    return 'margin liquidation level: $forceLiquidationBar';
  }
}

class IsolatedMarginAssetDetail {
  final String asset;
  final bool borrowEnabled;
  final double borrowed;
  final double free;
  final double interest;
  final double locked;
  final double netAsset;
  final double netAssetOfBtc;
  final bool repayEnabled;
  final double totalAsset;

  IsolatedMarginAssetDetail(Map m)
      : asset = m['asset'],
        borrowEnabled = m['borrowEnabled'],
        borrowed = double.parse(m['borrowed']),
        free = double.parse(m['free']),
        interest = double.parse(m['interest']),
        locked = double.parse(m['locked']),
        netAsset = double.parse(m['netAsset']),
        netAssetOfBtc = double.parse(m['netAssetOfBtc']),
        repayEnabled = m['repayEnabled'],
        totalAsset = double.parse(m['totalAsset']);

  @override
  String toString() {
    return '$asset $netAsset';
  }
}

class IsolatedMarginAsset {
  final String symbol;
  final bool isolatedCreated;
  final double marginLevel;
  final String marginLevelStatus;
  final int marginRatio;
  final double indexPrice;
  final double liquidatePrice;
  final double liquidateRate;
  final bool tradeEnabled;
  final bool enabled;
  final IsolatedMarginAssetDetail baseAsset;
  final IsolatedMarginAssetDetail quoteAsset;

  IsolatedMarginAsset(Map m)
      : symbol = m['symbol'],
        isolatedCreated = m['isolatedCreated'],
        marginLevel = double.parse(m['marginLevel']),
        marginLevelStatus = m['marginLevelStatus'],
        marginRatio = int.parse(m['marginRatio']),
        indexPrice = double.parse(m['indexPrice']),
        liquidatePrice = double.parse(m['liquidatePrice']),
        liquidateRate = double.parse(m['liquidateRate']),
        tradeEnabled = m['tradeEnabled'],
        enabled = m['enabled'],
        baseAsset = IsolatedMarginAssetDetail(m['baseAsset']),
        quoteAsset = IsolatedMarginAssetDetail(m['quoteAsset']);

  @override
  String toString() {
    return 'BaseAsset $baseAsset, QuoteAsset $quoteAsset';
  }
}

class IsolatedMarginAccountInfo {
  /// IsolatedMarginAccountInfo
  final double? totalAssetOfBtc;
  final double? totalLiabilityOfBtc;
  final double? totalNetAssetOfBtc;
  final List<IsolatedMarginAsset> assets;

  IsolatedMarginAccountInfo(Map m)
      : totalAssetOfBtc = m.containsKey('totalAssetOfBtc') ? double.parse(m['totalAssetOfBtc']) : null,
        totalLiabilityOfBtc = m.containsKey('totalLiabilityOfBtc') ? double.parse(m['totalLiabilityOfBtc']) : null,
        totalNetAssetOfBtc = m.containsKey('totalNetAssetOfBtc') ? double.parse(m['totalNetAssetOfBtc']) : null,
        assets = List.from(m['assets'].map((e) => IsolatedMarginAsset(e)));

  @override
  String toString() {
    return 'Isolated Margin Account:${totalAssetOfBtc != null ? ' $totalAssetOfBtc ₿ of' : ''} ${assets.length} assets';
  }

  IsolatedMarginAsset getAssetInfo(String symbol) => assets.firstWhere((e) => e.symbol == symbol.toUpperCase());
}
