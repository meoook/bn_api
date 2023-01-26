class BnApiUrls {
  static const String webUrl = 'www.binance.com';

  static const String apiUrl = 'api.binance.com';
  static const String apiUrlTestnet = 'testnet.binance.vision';

  static const String futuresUrl = 'fapi.binance.com';
  static const String futuresUrlTestnet = 'testnet.binancefuture.com';

  static const String futuresCoinUrl = 'dapi.binance.com';
  static const String futuresCoinUrlTestnet = 'testnet.binancefuture.com';

  static const String optionsUrl = 'vapi.binance.com';
  static const String optionsUrlTestnet = 'testnet.binanceops.com';

  static const String exchangeProducts = 'exchange-api/v1/public/asset-service/product/get-products';

  static const String publicApiVersion = 'v1';
  static const String privateApiVersion = 'v3';
  static const String marginApiVersion = 'v1';
  static const String futuresApiVersion = 'v1';
  static const String futuresApiVersion2 = 'v2';
  static const String optionsApiVersion = 'v1';
}

class BnApiOrderSide {
  static const String buy = 'BUY';
  static const String sell = 'SELL';
}

class BnApiTradeType {
  static const String spot = 'SPOT';
  static const String margin = 'MARGIN';
  static const String futures = 'FUTURES';
}

class BnApiOrderType {
  static const String limit = 'LIMIT';
  static const String market = 'MARKET';
  static const String stopLoss = 'STOP_LOSS';
  static const String stopLossLimit = 'STOP_LOSS_LIMIT';
  static const String takeProfit = 'TAKE_PROFIT';
  static const String takeProfitLimit = 'TAKE_PROFIT_LIMIT';
  static const String limitMaker = 'LIMIT_MAKER';

  static const String futureLimit = 'LIMIT';
  static const String futureMarket = 'MARKET';
  static const String futureStop = 'STOP';
  static const String futureStopMARKET = 'STOP_MARKET';
  static const String futureTakeProfit = 'TAKE_PROFIT';
  static const String futureTakeProfitMarket = 'TAKE_PROFIT_MARKET';
  static const String futureLimitMaker = 'LIMIT_MAKER';
}

class BnApiAggKeys {
  // For accessing the data returned by Client.aggregate_trades().
  static const String aggID = 'a';
  static const String aggPrice = 'p';
  static const String aggQuantity = 'q';
  static const String aggFirstTradeID = 'f';
  static const String aggLastTradeID = 'l';
  static const String aggTime = 'T';
  static const String aggBuyerMakers = 'm';
  static const String aggBestMatch = 'M';
}

class BnApiTimeInForce {
  static const String gtc = 'GTC'; // Good till cancelled
  static const String ioc = 'IOC'; // Immediate or cancel
  static const String fok = 'FOK'; // Fill or kill
}

class BnApiOrderSideEffect {
  static const String no_side = 'NO_SIDE_EFFECT'; // For normal trade order
  static const String margin = 'MARGIN_BUY'; // For margin trade order
  static const String auto = 'AUTO_REPAY'; // For making auto repayment after order filled
}

class BnApiSymbolStatus {
  static const String preTrading = 'PRE_TRADING';
  static const String trading = 'TRADING';
  static const String postTrading = 'POST_TRADING';
  static const String endOfDay = 'END_OF_DAY';
  static const String halt = 'HALT';
  static const String auctionMatch = 'AUCTION_MATCH';
  static const String breakTrading = 'BREAK';
}

class BnApiTimeFrame {
  static const String min1 = '1m';
  static const String min3 = '3m';
  static const String min5 = '5m';
  static const String min15 = '15m';
  static const String min30 = '30m';
  static const String hour1 = '1h';
  static const String hour2 = '2h';
  static const String hour4 = '4h';
  static const String hour6 = '6h';
  static const String hour8 = '8h';
  static const String hour12 = '12h';
  static const String day1 = '1d';
  static const String day3 = '3d';
  static const String week = '1w';
  static const String month = '1M';
  static const List<String> choices = [
    '1m',
    '3m',
    '5m',
    '15m',
    '1h',
    '2h',
    '4h',
    '6h',
    '8h',
    '12h',
    '1d',
    '3d',
    '1w',
    '1M'
  ];
}
