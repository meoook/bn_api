class IsolatedMarginTransfer {
  final double amount;
  final String asset;
  final String status;
  final DateTime timestamp;
  final int txId;
  final String transFrom;
  final String transTo;
  final String? clientTag;

  IsolatedMarginTransfer(Map m)
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

class IsolatedMarginSymbol {
  final String base;
  final bool isBuyAllowed;
  final bool isMarginTrade;
  final bool isSellAllowed;
  final String quote;
  final String symbol;

  IsolatedMarginSymbol(Map m)
      : base = m['base'],
        isBuyAllowed = m['isBuyAllowed'],
        isMarginTrade = m['isMarginTrade'],
        isSellAllowed = m['isSellAllowed'],
        quote = m['quote'],
        symbol = m['symbol'];

  @override
  String toString() {
    return '$base:$quote';
  }
}

class IsolatedMarginFee {
  final String symbol;
  final int vipLevel;
  final int leverage;
  final List allData;

  IsolatedMarginFee(Map m)
      : symbol = m['symbol'],
        vipLevel = m['vipLevel'],
        leverage = int.parse(m['leverage']),
        allData = m['data'];

  @override
  String toString() {
    return '$symbol leverage: $leverage';
  }
}
