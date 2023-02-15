// =================================================================================================================

class BnApiMarginTransferItem {
  final String asset;
  final int txId;
  final String type; // ROLL_IN, ROLL_OUT
  final double amount;
  final DateTime timestamp;
  final String status; // PENDING, CONFIRMED, FAILED

  BnApiMarginTransferItem(Map m)
      : asset = m['asset'],
        txId = m['txId'],
        type = m['type'],
        amount = double.parse(m['amount']),
        timestamp = DateTime.fromMillisecondsSinceEpoch(m['timestamp']),
        status = m['status'];

  @override
  String toString() {
    return '$asset $amount $type';
  }
}

// =================================================================================================================

class BnApiMarginBorrowItem {
  final String asset;
  final int txId;
  final String? isolatedSymbol; // isolated symbol, will not be returned for crossed margin
  final double principal;
  final DateTime timestamp;
  final String status; // PENDING, CONFIRMED, FAILED

  BnApiMarginBorrowItem(Map m)
      : asset = m['asset'],
        txId = m['txId'],
        isolatedSymbol = m['isolatedSymbol'],
        principal = double.parse(m['principal']),
        timestamp = DateTime.fromMillisecondsSinceEpoch(m['timestamp']),
        status = m['status'];

  @override
  String toString() {
    return '$asset principal: $principal';
  }
}

// =================================================================================================================

class BnApiMarginRepayItem {
  final String asset;
  final int txId;
  final double amount; // Total amount repaid
  final double interest; // Interest repaid
  final String? isolatedSymbol; // isolated symbol, will not be returned for crossed margin
  final double principal;
  final DateTime timestamp;
  final String status; // PENDING, CONFIRMED, FAILED

  BnApiMarginRepayItem(Map m)
      : asset = m['asset'],
        txId = m['txId'],
        amount = double.parse(m['amount']),
        interest = double.parse(m['interest']),
        isolatedSymbol = m['isolatedSymbol'],
        principal = double.parse(m['principal']),
        timestamp = DateTime.fromMillisecondsSinceEpoch(m['timestamp']),
        status = m['status'];

  @override
  String toString() {
    return '$asset principal: $principal amount: $amount';
  }
}

// =================================================================================================================

class BnApiMarginAsset {
  final String assetName;
  final String assetFullName;
  final bool isBorrowable;
  final bool isMortgageable;
  final double userMinBorrow;
  final double userMinRepay;

  BnApiMarginAsset(Map m)
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

// =================================================================================================================

class BnApiMarginSymbol {
  final int id;
  final String symbol;
  final String base;
  final String quote;
  final bool isMarginTrade;
  final bool isBuyAllowed;
  final bool isSellAllowed;

  BnApiMarginSymbol(Map m)
      : id = m['id'],
        symbol = m['symbol'],
        base = m['base'],
        quote = m['quote'],
        isMarginTrade = m['isMarginTrade'],
        isBuyAllowed = m['isBuyAllowed'],
        isSellAllowed = m['isSellAllowed'];

  @override
  String toString() {
    return '$symbol';
  }
}

// =================================================================================================================

class BnApiMarginPriceIndex {
  final String symbol;
  final double price;
  final DateTime calcTime;

  BnApiMarginPriceIndex(Map m)
      : symbol = m['symbol'],
        price = double.parse(m['price']),
        calcTime = DateTime.fromMillisecondsSinceEpoch(m['calcTime']);

  @override
  String toString() {
    return '$symbol $price';
  }
}

// =================================================================================================================

class BnApiMarginTrade {
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

  BnApiMarginTrade(Map m)
      : commission = double.parse(m['commission']),
        commissionAsset = m['commissionAsset'],
        id = m['id'],
        isBestMatch = m['isBestMatch'],
        isBuyer = m['isBuyer'],
        isMaker = m['isMaker'],
        orderId = m['orderId'],
        price = double.parse(m['price']),
        qty = double.parse(m['qty']),
        symbol = m['symbol'],
        isIsolated = m['isIsolated'],
        time = DateTime.fromMillisecondsSinceEpoch(m['time']);

  @override
  String toString() {
    return '$symbol qty: $qty price: $price';
  }
}

// =================================================================================================================

class BnApiMarginLevelInfo {
  final double normalBar;
  final double marginCallBar;
  final double forceLiquidationBar;

  BnApiMarginLevelInfo(Map m)
      : normalBar = double.parse(m['normalBar']),
        marginCallBar = double.parse(m['marginCallBar']),
        forceLiquidationBar = double.parse(m['forceLiquidationBar']);

  @override
  String toString() {
    return 'level: $normalBar';
  }
}

// =================================================================================================================

class BnApiMarginInterestHistoryItem {
  /// type in response has 4 enums:
  /// PERIODIC interest charged per hour
  /// ON_BORROW first interest charged on borrow
  /// PERIODIC_CONVERTED interest charged per hour converted into BNB
  /// ON_BORROW_CONVERTED first interest charged on borrow converted into BNB

  final int txId;
  final DateTime interestAccuredTime;
  final String asset;
  final String? rawAsset; // will not be returned for isolated margin
  final double principal;
  final double interest;
  final double interestRate;
  final String type; // PERIODIC, ON_BORROW, PERIODIC_CONVERTED, ON_BORROW_CONVERTED
  final String? isolatedSymbol; // isolated symbol, will not be returned for crossed margin

  BnApiMarginInterestHistoryItem(Map m)
      : txId = m['txId'],
        interestAccuredTime = DateTime.fromMillisecondsSinceEpoch(m['interestAccuredTime']),
        asset = m['asset'],
        rawAsset = m['rawAsset'],
        principal = double.parse(m['principal']),
        interest = double.parse(m['interest']),
        interestRate = double.parse(m['interestRate']),
        type = m['type'],
        isolatedSymbol = m['isolatedSymbol'];

  @override
  String toString() {
    return '$asset principal: $principal interest: $interest rate: $interestRate';
  }
}

// =================================================================================================================

class BnApiMarginForceLiquidationItem {
  final int orderId;
  final double avgPrice;
  final double executedQty;
  final double price;
  final double qty;
  final String side; // BnApiOrderSide: BUY, SELL
  final String symbol;
  final String timeInForce; // BnApiTimeInForce: GTC, IOC, FOK
  final bool isIsolated;
  final DateTime updatedTime;

  BnApiMarginForceLiquidationItem(Map m)
      : orderId = m['orderId'],
        avgPrice = double.parse(m['avgPrice']),
        executedQty = double.parse(m['executedQty']),
        price = double.parse(m['price']),
        qty = double.parse(m['qty']),
        side = m['side'],
        symbol = m['symbol'],
        timeInForce = m['timeInForce'],
        isIsolated = m['isIsolated'],
        updatedTime = DateTime.fromMillisecondsSinceEpoch(m['updatedTime']);

  @override
  String toString() {
    return '$symbol $side qty: $qty price: $avgPrice';
  }
}

// =================================================================================================================

class BnApiCrossMarginAsset {
  final String asset;
  final double borrowed;
  final double free;
  final double interest;
  final double locked;
  final double netAsset;

  BnApiCrossMarginAsset(Map m)
      : asset = m['asset'],
        borrowed = double.parse(m['borrowed']),
        free = double.parse(m['free']),
        interest = double.parse(m['interest']),
        locked = double.parse(m['locked']),
        netAsset = double.parse(m['netAsset']);

  @override
  String toString() {
    return '$asset $netAsset';
  }
}

class BnApiCrossMarginAccountInfo {
  final bool borrowEnabled;
  final bool tradeEnabled;
  final bool transferEnabled;
  final double marginLevel;
  final double totalAssetOfBtc;
  final double totalLiabilityOfBtc;
  final double totalNetAssetOfBtc;
  final List<BnApiCrossMarginAsset> userAssets;

  BnApiCrossMarginAccountInfo(Map m)
      : borrowEnabled = m['borrowEnabled'],
        tradeEnabled = m['tradeEnabled'],
        transferEnabled = m['transferEnabled'],
        marginLevel = double.parse(m['marginLevel']),
        totalAssetOfBtc = double.parse(m['totalAssetOfBtc']),
        totalLiabilityOfBtc = double.parse(m['totalLiabilityOfBtc']),
        totalNetAssetOfBtc = double.parse(m['totalNetAssetOfBtc']),
        userAssets = List.from(m['userAssets'].map((e) => BnApiCrossMarginAsset(e)));

  @override
  String toString() {
    return 'Cross Margin Account: $totalAssetOfBtc ₿ level: $marginLevel';
  }

  BnApiCrossMarginAsset getAssetInfo(String asset) => userAssets.firstWhere((e) => e.asset == asset.toUpperCase());
}

// =================================================================================================================

class BnApiMarginInterestRateItem {
  final String asset;
  final double dailyInterestRate;
  final DateTime timestamp;
  final int vipLevel;

  BnApiMarginInterestRateItem(Map m)
      : asset = m['asset'],
        dailyInterestRate = double.parse(m['dailyInterestRate']),
        timestamp = DateTime.fromMillisecondsSinceEpoch(m['timestamp']),
        vipLevel = m['vipLevel'];

  @override
  String toString() {
    return '$asset VIP: $vipLevel rate: $dailyInterestRate';
  }
}

// =================================================================================================================

class BnApiMarginFeeItem {
  final String coin;
  final int vipLevel;
  final bool transferIn;
  final bool borrowable;
  final double dailyInterest;
  final double yearlyInterest;
  final double borrowLimit;
  final List<String> marginablePairs;

  BnApiMarginFeeItem(Map m)
      : coin = m['coin'],
        vipLevel = m['vipLevel'],
        transferIn = m['transferIn'],
        borrowable = m['borrowable'],
        dailyInterest = double.parse(m['dailyInterest']),
        yearlyInterest = double.parse(m['yearlyInterest']),
        borrowLimit = double.parse(m['borrowLimit']),
        marginablePairs = List.from(m['marginablePairs'].map((e) => '$e'));

  @override
  String toString() {
    return '$coin VIP: $vipLevel rate: $dailyInterest';
  }
}
