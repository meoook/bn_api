class MarginOrder {
  final String symbol;
  final int orderId;
  final String clientOrderId;
  final double price;
  final double origQty;
  final double executedQty;
  final double cummulativeQuoteQty;
  final String status; // NEW, CANCELED
  final String timeInForce; // GTC
  final String type; // LIMIT
  final String side; // BUY, SELL
  final double stopPrice;
  final double icebergQty;
  final DateTime time;
  final DateTime updateTime;
  final bool isWorking;
  final bool isIsolated;

  MarginOrder(Map m)
      : symbol = m['symbol'],
        orderId = m['orderId'], // double.parse(_filter['multiplierDown']);
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
    return '$symbol $type $status qty: $origQty price: $price';
  }
}
