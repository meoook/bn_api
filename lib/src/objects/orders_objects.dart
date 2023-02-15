class BnApiMarginOrderFill {
  final double price;
  final double qty;
  final double commission;
  final String commissionAsset;

  BnApiMarginOrderFill(Map m)
      : price = m['price'],
        qty = m['qty'],
        commission = m['commission'],
        commissionAsset = m['commissionAsset'];

  @override
  String toString() {
    return ' $qty $price commission $commission $commissionAsset';
  }
}

class BnApiMarginOrder {
  // Response ACK
  final String symbol;
  final int orderId;
  final String clientOrderId;
  final bool isIsolated;
  final DateTime transactTime;
  // Response RESULT
  final double? price;
  final double? origQty;
  final double? executedQty;
  final double? cummulativeQuoteQty;
  final String? status; // BnApiOrderStatus: NEW, FILLED, CANCELED ...
  final String? timeInForce; // BnApiTimeInForce: GTC, IOC, FOK
  final String? type; // BnApiOrderType: LIMIT, MARKET ...
  final String? side; // BnApiOrderSide: BUY, SELL
  // Response FULL
  final double? marginBuyBorrowAmount; // will not return if no margin trade happens
  final String? marginBuyBorrowAsset; // will not return if no margin trade happens
  final List<BnApiMarginOrderFill>? fills;

  BnApiMarginOrder(Map m)
      : symbol = m['symbol'],
        orderId = m['orderId'],
        isIsolated = m['isIsolated'],
        clientOrderId = m['clientOrderId'],
        transactTime = DateTime.fromMillisecondsSinceEpoch(m['transactTime']),
        price = m['price'] == null ? null : double.parse(m['price']),
        origQty = m['origQty'] == null ? null : double.parse(m['origQty']),
        executedQty = m['executedQty'] == null ? null : double.parse(m['executedQty']),
        cummulativeQuoteQty = m['cummulativeQuoteQty'] == null ? null : double.parse(m['cummulativeQuoteQty']),
        status = m['status'],
        timeInForce = m['timeInForce'],
        type = m['type'],
        side = m['side'],
        marginBuyBorrowAmount = m['marginBuyBorrowAmount'] == null ? null : double.parse(m['marginBuyBorrowAmount']),
        marginBuyBorrowAsset = m['marginBuyBorrowAsset'],
        fills = m['fills'] == null || m['fills'].isEmpty ? null : m['fills'].map((e) => BnApiMarginOrderFill(e));

  @override
  String toString() {
    return '$symbol $type $status qty: $origQty price: $price';
  }
}

// =================================================================================================================

class BnApiMarginOrderGet {
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
  final int accountId;
  final bool isIsolated;

  BnApiMarginOrderGet(Map m)
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
        accountId = m['accountId'],
        isIsolated = m['isIsolated'];

  @override
  String toString() {
    return '$symbol $type $status qty: $origQty price: $price';
  }
}

// =================================================================================================================

class BnApiMarginOrderCancel {
  final String symbol;
  final bool isIsolated;
  final int orderId;
  final String clientOrderId;
  final String origClientOrderId;
  final double price;
  final double origQty;
  final double executedQty;
  final double cummulativeQuoteQty;
  final String status; // BnApiOrderStatus: NEW, FILLED, CANCELED
  final String timeInForce; // BnApiTimeInForce: GTC, IOC, FOK
  final String type; // BnApiOrderType: LIMIT, MARKET
  final String side; // BnApiOrderSide: BUY, SELL

  BnApiMarginOrderCancel(Map m)
      : symbol = m['symbol'],
        orderId = m['orderId'],
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

// =================================================================================================================

class BnApiMarginCutOrder {
  final String symbol;
  final int orderId;
  final int clientOrderId;

  BnApiMarginCutOrder(Map m)
      : symbol = m['symbol'],
        orderId = m['orderId'],
        clientOrderId = m['clientOrderId'];

  @override
  String toString() {
    return '$symbol';
  }
}

class BnApiMarginListOrder {
  // can return on marginCancelOrders
  final int orderListId;
  final String symbol;
  final String contingencyType;
  final String listStatusType;
  final String listOrderStatus;
  final String listClientOrderId;
  final DateTime transactionTime;
  final bool isIsolated;

  final List<BnApiMarginCutOrder> orders;
  final List<BnApiMarginOrder> orderReports;

  BnApiMarginListOrder(Map m)
      : orderListId = m['orderListId'],
        symbol = m['symbol'],
        contingencyType = m['contingencyType'],
        listStatusType = m['listStatusType'],
        listOrderStatus = m['listOrderStatus'],
        listClientOrderId = m['listClientOrderId'],
        transactionTime = DateTime.fromMillisecondsSinceEpoch(m['transactionTime']),
        isIsolated = m['isIsolated'],
        orders = m['orders'] == null ? null : m['orders'].map((e) => BnApiMarginCutOrder(e)),
        orderReports = m['orderReports'] == null ? null : m['orderReports'].map((e) => BnApiMarginOrder(e));

  @override
  String toString() {
    return '$symbol';
  }
}

// =================================================================================================================
