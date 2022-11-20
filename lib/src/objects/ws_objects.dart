class IndividualSymbolTicker {
  final String symbol;
  final double changePrice;
  final double changePercent;
  final double priceLast;
  final double priceHigh;
  final double priceLow;
  final double baseAssetVolume;
  final double quoteAssetVolume;
  final int numberOfTrades;

  IndividualSymbolTicker.fromDefault(this.symbol)
      : changePrice = 0,
        changePercent = 0,
        priceLast = 0,
        priceHigh = 0,
        priceLow = 0,
        baseAssetVolume = 0,
        quoteAssetVolume = 0,
        numberOfTrades = 0;

  IndividualSymbolTicker(Map m)
      : symbol = m['s'],
        changePrice = double.parse(m['p']),
        changePercent = double.parse(m['P']),
        priceLast = double.parse(m['c']),
        priceHigh = double.parse(m['h']),
        priceLow = double.parse(m['l']),
        baseAssetVolume = double.parse(m['v']),
        quoteAssetVolume = double.parse(m['q']),
        numberOfTrades = m['n'];
}
