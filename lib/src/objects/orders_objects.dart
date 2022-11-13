class MarginOrder {
  /// Margin Order: GET
  final String symbol;
  final int orderId;
  final String clientOrderId;
  final double price;
  final double origQty;
  final double executedQty;
  final double cummulativeQuoteQty;
  final String status; // NEW, FILLED, CANCELED
  final String timeInForce; // GTC, IOC, FOK
  final String type; // LIMIT, MARKET
  final String side; // BUY, SELL
  final double stopPrice;
  final double icebergQty;
  final DateTime time;
  final DateTime updateTime;
  final bool isWorking;
  final bool isIsolated;

  MarginOrder(Map m)
      : symbol = m['symbol'],
        orderId = m['orderId'],
        clientOrderId = m['clientOrderId'],
        price = double.parse(m['price']),
        origQty = double.parse(m['origQty']),
        executedQty = double.parse(m['executedQty']),
        cummulativeQuoteQty = double.parse(m['cummulativeQuoteQty']),
        status = m['status'],
        timeInForce = m['timeInForce'],
        type = m['type'],
        side = m['side'],
        stopPrice = double.parse(m['stopPrice']),
        icebergQty = double.parse(m['icebergQty']),
        time = DateTime.fromMillisecondsSinceEpoch(m['time']),
        updateTime = DateTime.fromMillisecondsSinceEpoch(m['updateTime']),
        isWorking = m['isWorking'],
        isIsolated = m['isIsolated'];

  @override
  String toString() {
    return 'margin $symbol $type $status qty: $origQty price: $price';
  }
}

class MarginCancelOrder {
  /// Margin Order: CANCEL
  final String symbol;
  final int orderId;
  final String clientOrderId;
  final String origClientOrderId;
  final double price;
  final double origQty;
  final double executedQty;
  final double cummulativeQuoteQty;
  final String status; // NEW, FILLED, CANCELED
  final String timeInForce; // GTC, IOC, FOK
  final String type; // LIMIT, MARKET
  final String side; // BUY, SELL
  final bool isIsolated;

  MarginCancelOrder(Map m)
      : symbol = m['symbol'],
        orderId = int.parse(m['orderId']),
        clientOrderId = m['clientOrderId'],
        origClientOrderId = m['origClientOrderId'],
        price = double.parse(m['price']),
        origQty = double.parse(m['origQty']),
        executedQty = double.parse(m['executedQty']),
        cummulativeQuoteQty = double.parse(m['cummulativeQuoteQty']),
        status = m['status'],
        timeInForce = m['timeInForce'],
        type = m['type'],
        side = m['side'],
        isIsolated = m['isIsolated'];

  @override
  String toString() {
    return 'margin $symbol $type $status qty: $origQty price: $price';
  }
}

class MarginOrderFill {
  final double price;
  final double qty;
  final double commission;
  final String commissionAsset;
  MarginOrderFill(Map m)
      : price = m['price'],
        qty = m['qty'],
        commission = m['commission'],
        commissionAsset = m['commissionAsset'];
}

class MarginCreatedOrder {
  /// Margin Order: CREATE
  final String symbol;
  final int orderId;
  final String clientOrderId;
  final DateTime transactTime;
  final double price;
  final double origQty;
  final double executedQty;
  final double cummulativeQuoteQty;
  final String status; // NEW, FILLED, CANCELED
  final String timeInForce; // GTC
  final String type; // LIMIT, MARKET
  final bool isIsolated;
  final String side; // BUY, SELL

  late double? marginBuyBorrowAmount; // will not return if no margin trade happens
  late String? marginBuyBorrowAsset; // will not return if no margin trade happens

  final List<MarginOrderFill> fills = [];

  MarginCreatedOrder(Map m)
      : symbol = m['symbol'],
        orderId = m['orderId'],
        clientOrderId = m['clientOrderId'],
        transactTime = DateTime.fromMillisecondsSinceEpoch(m['transactTime']),
        price = double.parse(m['price']),
        origQty = double.parse(m['origQty']),
        executedQty = double.parse(m['executedQty']),
        cummulativeQuoteQty = double.parse(m['cummulativeQuoteQty']),
        status = m['status'],
        timeInForce = m['timeInForce'],
        type = m['type'],
        isIsolated = m['isIsolated'],
        side = m['side'] {
    if (m.containsKey('marginBuyBorrowAmount')) marginBuyBorrowAmount = double.parse(m['marginBuyBorrowAmount']);
    if (m.containsKey('marginBuyBorrowAsset')) marginBuyBorrowAsset = m['marginBuyBorrowAsset'];
    if (m.containsKey('fills')) m['fills'].forEach((e) => fills.add(MarginOrderFill(e)));
  }

  @override
  String toString() {
    return 'margin $symbol $type $status qty: $origQty price: $price';
  }
}
