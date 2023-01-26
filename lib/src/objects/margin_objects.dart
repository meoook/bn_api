class MarginAsset {
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

class MarginLevelInfo {
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
