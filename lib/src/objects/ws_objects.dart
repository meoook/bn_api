class IndividualSymbolTicker {
  String symbol = '';
  double changePrice = 0;
  double changePercent = 0;
  double priceLast = 0;
  double priceHigh = 0;
  double priceLow = 0;
  double baseAssetVolume = 0;
  double quoteAssetVolume = 0;
  int numberOfTrades = 0;

  void update(Map m) {
    symbol = m['s'];
    changePrice = double.parse(m['p']);
    changePercent = double.parse(m['P']);
    priceLast = double.parse(m['c']);
    priceHigh = double.parse(m['h']);
    priceLow = double.parse(m['l']);
    baseAssetVolume = double.parse(m['v']);
    quoteAssetVolume = double.parse(m['q']);
    numberOfTrades = m['n'];
  }
}
