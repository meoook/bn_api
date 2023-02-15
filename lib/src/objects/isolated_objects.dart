class BnApiIsolatedMarginTransfer {
  final double amount;
  final String asset;
  final String status;
  final DateTime timestamp;
  final int txId;
  final String transFrom;
  final String transTo;
  final String? clientTag;

  BnApiIsolatedMarginTransfer(Map m)
      : amount = double.parse(m['amount']),
        asset = m['asset'],
        status = m['status'],
        timestamp = DateTime.fromMillisecondsSinceEpoch(m['timestamp']),
        txId = m['txId'],
        transFrom = m['transFrom'],
        transTo = m['transTo'],
        clientTag = m['clientTag'];

  @override
  String toString() {
    return '$asset to $transTo amount: $amount';
  }
}

// =================================================================================================================

class BnApiIsolatedMarginAssetDetail {
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

  BnApiIsolatedMarginAssetDetail(Map m)
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

class BnApiIsolatedMarginAsset {
  final String symbol;
  final bool isolatedCreated;
  final double marginLevel;
  final String marginLevelStatus; // EXCESSIVE, NORMAL, MARGIN_CALL, PRE_LIQUIDATION, FORCE_LIQUIDATION
  final int marginRatio;
  final double indexPrice;
  final double liquidatePrice;
  final double liquidateRate;
  final bool tradeEnabled;
  final bool enabled;
  final BnApiIsolatedMarginAssetDetail baseAsset;
  final BnApiIsolatedMarginAssetDetail quoteAsset;

  BnApiIsolatedMarginAsset(Map m)
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
        baseAsset = BnApiIsolatedMarginAssetDetail(m['baseAsset']),
        quoteAsset = BnApiIsolatedMarginAssetDetail(m['quoteAsset']);

  @override
  String toString() {
    return 'base: $baseAsset quote: $quoteAsset';
  }
}

class BnApiIsolatedMarginAccountInfo {
  final double? totalAssetOfBtc;
  final double? totalLiabilityOfBtc;
  final double? totalNetAssetOfBtc;
  final List<BnApiIsolatedMarginAsset> assets;

  BnApiIsolatedMarginAccountInfo(Map m)
      : totalAssetOfBtc = m['totalAssetOfBtc'] == null ? null : double.parse(m['totalAssetOfBtc']),
        totalLiabilityOfBtc = m['totalLiabilityOfBtc'] == null ? null : double.parse(m['totalLiabilityOfBtc']),
        totalNetAssetOfBtc = m['totalNetAssetOfBtc'] == null ? null : double.parse(m['totalNetAssetOfBtc']),
        assets = List.from(m['assets'].map((e) => BnApiIsolatedMarginAsset(e)));

  @override
  String toString() {
    return 'Isolated Margin Account:${totalAssetOfBtc != null ? ' $totalAssetOfBtc ₿ of' : ''} ${assets.length} assets';
  }

  BnApiIsolatedMarginAsset getSymbolInfo(String symbol) => assets.firstWhere((e) => e.symbol == symbol.toUpperCase());
}

// =================================================================================================================

class BnApiIsolatedMarginAccountLimit {
  final int enabledAccount;
  final int maxAccount;

  BnApiIsolatedMarginAccountLimit(Map m)
      : enabledAccount = m['enabledAccount'],
        maxAccount = m['maxAccount'];

  @override
  String toString() {
    return 'enabled $enabledAccount of $maxAccount';
  }
}

// =================================================================================================================

class BnApiIsolatedSymbol {
  final String symbol;
  final String base;
  final String quote;
  final bool isBuyAllowed;
  final bool isMarginTrade;
  final bool isSellAllowed;

  BnApiIsolatedSymbol(Map m)
      : symbol = m['symbol'],
        base = m['base'],
        quote = m['quote'],
        isBuyAllowed = m['isBuyAllowed'],
        isMarginTrade = m['isMarginTrade'],
        isSellAllowed = m['isSellAllowed'];

  @override
  String toString() {
    return '$base:$quote';
  }
}

// =================================================================================================================

class BnApiIsolatedCoinFee {
  final String coin;
  final double dailyInterest;
  final double borrowLimit;

  BnApiIsolatedCoinFee(Map m)
      : coin = m['coin'],
        dailyInterest = double.parse(m['dailyInterest']),
        borrowLimit = double.parse(m['borrowLimit']);

  @override
  String toString() {
    return '$coin fee: $dailyInterest';
  }
}

class BnApiIsolatedFeeItem {
  final String symbol;
  final int vipLevel;
  final int leverage;
  late BnApiIsolatedCoinFee base;
  late BnApiIsolatedCoinFee quote;

  BnApiIsolatedFeeItem(Map m)
      : symbol = m['symbol'],
        vipLevel = m['vipLevel'],
        leverage = int.parse(m['leverage']) {
    m['data'].forEach((e) {
      if (symbol.startsWith(e['coin']))
        this.base = BnApiIsolatedCoinFee(e);
      else
        this.quote = BnApiIsolatedCoinFee(e);
    });
  }

  @override
  String toString() {
    return '$symbol leverage: $leverage base: $base quote: $quote';
  }
}

// =================================================================================================================

class BnApiIsolatedTierItem {
  final String symbol;
  final int tier;
  final double effectiveMultiple;
  final double initialRiskRatio;
  final double liquidationRiskRatio;
  final double baseAssetMaxBorrowable;
  final double quoteAssetMaxBorrowable;

  BnApiIsolatedTierItem(Map m)
      : symbol = m['symbol'],
        tier = m['tier'],
        effectiveMultiple = double.parse(m['effectiveMultiple']),
        initialRiskRatio = double.parse(m['initialRiskRatio']),
        liquidationRiskRatio = double.parse(m['liquidationRiskRatio']),
        baseAssetMaxBorrowable = double.parse(m['baseAssetMaxBorrowable']),
        quoteAssetMaxBorrowable = double.parse(m['quoteAssetMaxBorrowable']);

  @override
  String toString() {
    return '$symbol tier: $tier multiple: $effectiveMultiple';
  }
}

// =================================================================================================================
