class _FilterNames {
  static const String price = 'PRICE_FILTER';
  static const String percentPrice = 'PERCENT_PRICE';
  static const String lotSize = 'LOT_SIZE';
  static const String minNotional = 'MIN_NOTIONAL';
  static const String iceberg = 'ICEBERG_PARTS';
  static const String marketLot = 'MARKET_LOT_SIZE';
  static const String trailingDelta = 'TRAILING_DELTA';
  static const String maxOrders = 'MAX_NUM_ORDERS';
  static const String maxAlgoOrders = 'MAX_NUM_ALGO_ORDERS';
}

class SymbolFilters {
  // PRICE_FILTER
  late double minPrice;
  late double maxPrice;
  late double tickSize;
  // PERCENT_PRICE
  late double multiplierUp;
  late double multiplierDown;
  late int avgPriceMins;
  // LOT_SIZE
  late double minQty;
  late double maxQty;
  late double stepSize;
  // MIN_NOTIONAL
  late double minNotional;
  late bool applyToMarket;
  late int notionalAvgPriceMins;
  // ICEBERG_PARTS
  late int icebergLimit;
  // MARKET_LOT_SIZE
  late double marketMinQty;
  late double marketMaxQty;
  late double marketStepSize;
  // TRAILING_DELTA
  late int minTrailingAboveDelta;
  late int maxTrailingAboveDelta;
  late int minTrailingBelowDelta;
  late int maxTrailingBelowDelta;
  // MAX_NUM_ORDERS
  late int maxNumOrders;
  // MAX_NUM_ALGO_ORDERS
  late int maxNumAlgoOrders;

  SymbolFilters(List filters) {
    filters.forEach((_filter) {
      switch (_filter['filterType']) {
        case _FilterNames.price:
          minPrice = double.parse(_filter['minPrice']);
          maxPrice = double.parse(_filter['maxPrice']);
          tickSize = double.parse(_filter['tickSize']);
          break;
        case _FilterNames.percentPrice:
          multiplierUp = double.parse(_filter['multiplierUp']);
          multiplierDown = double.parse(_filter['multiplierDown']);
          avgPriceMins = _filter['avgPriceMins'];
          break;
        case _FilterNames.lotSize:
          minQty = double.parse(_filter['minQty']);
          maxQty = double.parse(_filter['maxQty']);
          stepSize = double.parse(_filter['stepSize']);
          break;
        case _FilterNames.minNotional:
          minNotional = double.parse(_filter['minNotional']);
          applyToMarket = _filter['applyToMarket'];
          notionalAvgPriceMins = _filter['avgPriceMins'];
          break;
        case _FilterNames.iceberg:
          icebergLimit = _filter['limit'];
          break;
        case _FilterNames.marketLot:
          marketMinQty = double.parse(_filter['minQty']);
          marketMaxQty = double.parse(_filter['maxQty']);
          marketStepSize = double.parse(_filter['stepSize']);
          break;
        case _FilterNames.trailingDelta:
          minTrailingAboveDelta = _filter['minTrailingAboveDelta'];
          maxTrailingAboveDelta = _filter['maxTrailingAboveDelta'];
          minTrailingBelowDelta = _filter['minTrailingBelowDelta'];
          maxTrailingBelowDelta = _filter['maxTrailingBelowDelta'];
          break;
        case _FilterNames.maxOrders:
          maxNumOrders = _filter['maxNumOrders'];
          break;
        case _FilterNames.maxAlgoOrders:
          maxNumAlgoOrders = _filter['maxNumAlgoOrders'];
          break;
      }
    });
  }
}

class SymbolInfo {
  final String name;
  final String status; // TRADING,
  final String baseAsset;
  final int baseAssetPrecision;
  final String quoteAsset;
  final int quotePrecision;
  final int quoteAssetPrecision;
  final int baseCommissionPrecision;
  final int quoteCommissionPrecision;
  final List<String> orderTypes; // LIMIT, LIMIT_MAKER, MARKET, STOP_LOSS_LIMIT, TAKE_PROFIT_LIMIT
  final bool icebergAllowed;
  final bool ocoAllowed;
  final bool quoteOrderQtyMarketAllowed;
  final bool allowTrailingStop;
  final bool cancelReplaceAllowed;
  final bool isSpotTradingAllowed;
  final bool isMarginTradingAllowed;
  final SymbolFilters filters;
  final List<String> permissions;

  SymbolInfo(Map m)
      : name = m['symbol'],
        status = m['status'],
        baseAsset = m['baseAsset'],
        baseAssetPrecision = m['baseAssetPrecision'],
        quoteAsset = m['quoteAsset'],
        quotePrecision = m['quotePrecision'],
        quoteAssetPrecision = m['quoteAssetPrecision'],
        baseCommissionPrecision = m['baseCommissionPrecision'],
        quoteCommissionPrecision = m['quoteCommissionPrecision'],
        orderTypes = List<String>.from(m['orderTypes'].map((e) => '$e')),
        icebergAllowed = m['icebergAllowed'],
        ocoAllowed = m['ocoAllowed'],
        quoteOrderQtyMarketAllowed = m['quoteOrderQtyMarketAllowed'],
        allowTrailingStop = m['allowTrailingStop'],
        cancelReplaceAllowed = m['cancelReplaceAllowed'],
        isSpotTradingAllowed = m['isSpotTradingAllowed'],
        isMarginTradingAllowed = m['isMarginTradingAllowed'],
        filters = SymbolFilters(m['filters']),
        permissions = List<String>.from(m['permissions'].map((e) => '$e'));

  @override
  String toString() {
    return '$name $status';
  }
}

class RateLimit {
  final String rateLimitType;
  final String interval;
  final int intervalNum;
  final int limit;

  RateLimit(Map m)
      : rateLimitType = m['rateLimitType'],
        interval = m['interval'],
        intervalNum = m['intervalNum'],
        limit = m['limit'];

  @override
  String toString() {
    return '$rateLimitType: $limit per $interval';
  }
}

class ExchangeInfo {
  final List<SymbolInfo> symbols;
  final String timezone; // UTC
  final DateTime serverTime;
  final List<RateLimit> rateLimits;
  final List exchangeFilters;

  ExchangeInfo(Map m)
      : symbols = List<SymbolInfo>.from(m['symbols'].map((e) => SymbolInfo(e))),
        serverTime = DateTime.fromMillisecondsSinceEpoch(m['serverTime']),
        rateLimits = List<RateLimit>.from(m['rateLimits'].map((e) => RateLimit(e))),
        exchangeFilters = m['exchangeFilters'],
        timezone = m['timezone'];

  @override
  String toString() {
    return '$timezone $serverTime $rateLimits';
  }

  SymbolInfo getSymbolInfo(String symbol) => symbols.firstWhere((e) => e.name == symbol);
}
