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

class BnApiOrderType {
  static const String orderTypeLimit = 'LIMIT';
  static const String orderTypeMarket = 'MARKET';
  static const String orderTypeStopLoss = 'STOP_LOSS';
  static const String orderTypeStopLossLimit = 'STOP_LOSS_LIMIT';
  static const String orderTypeTakeProfit = 'TAKE_PROFIT';
  static const String orderTypeTakeProfitLimit = 'TAKE_PROFIT_LIMIT';
  static const String orderTypeLimitMaker = 'LIMIT_MAKER';

  static const String futureOrderTypeLimit = 'LIMIT';
  static const String futureOrderTypeMarket = 'MARKET';
  static const String futureOrderTypeStop = 'STOP';
  static const String futureOrderTypeStopMARKET = 'STOP_MARKET';
  static const String futureOrderTypeTakeProfit = 'TAKE_PROFIT';
  static const String futureOrderTypeTakeProfitMarket = 'TAKE_PROFIT_MARKET';
  static const String futureOrderTypeLimitMaker = 'LIMIT_MAKER';
}

class BnAggKeys {
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

class BnTimeInForce {
  static const String timeInForceGtc = 'GTC'; // Good till cancelled
  static const String timeInForceIoc = 'IOC'; // Immediate or cancel
  static const String timeInForceFok = 'FOK'; // Fill or kill
}
