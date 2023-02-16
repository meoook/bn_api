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

class BnApiOrderRespType {
  static const String ack = 'ACK';
  static const String result = 'RESULT';
  static const String full = 'FULL';
}

class BnApiOrderStatus {
  static const String orderStatusNew = 'NEW';
  static const String orderStatusPartiallyFilled = 'PARTIALLY_FILLED';
  static const String orderStatusFilled = 'FILLED';
  static const String orderStatusCanceled = 'CANCELED';
  static const String orderStatusPendingCancel = 'PENDING_CANCEL';
  static const String orderStatusRejected = 'REJECTED';
  static const String orderStatusExpired = 'EXPIRED';
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
  static const List<String> _minutes = [min1, min3, min5, min15, min30];
  static const List<String> _hours = [hour1, hour2, hour4, hour6, hour8, hour12];
  static const List<String> _days = [day1, day3, week, month];
  static const List<String> choices = [..._minutes, ..._hours, ..._days];
}

class BnApiUniversalTransfer {
  static const String spotToFuture = "MAIN_UMFUTURE"; // Spot to USDⓈ-M Futures
  static const String spotToCoinFuture = "MAIN_CMFUTURE"; // Spot to COIN-M Futures
  static const String spotToCross = "MAIN_MARGIN"; // Spot to Margin (cross)
  static const String futureToSpot = "UMFUTURE_MAIN"; // USDⓈ-M Futures to Spot
  static const String futureToCross = "UMFUTURE_MARGIN"; // USDⓈ-M Futures to Margin（cross）account
  static const String coinFutureToSpot = "CMFUTURE_MAIN"; // COIN-M Futures to Spot
  static const String coinFutureToMargin = "CMFUTURE_MARGIN"; // COIN-M Futures to Margin(cross)
  static const String crossToSpot = "MARGIN_MAIN"; // Margin（cross）to Spot
  static const String crossToFuture = "MARGIN_UMFUTURE"; // Margin (cross) to USDⓈ-M Futures
  static const String crossToCoinFuture = "MARGIN_CMFUTURE"; // Margin (cross) to COIN-M Futures
  static const String isolatedToCross = "ISOLATEDMARGIN_MARGIN"; // Isolated margin to Margin (cross)
  static const String crossToIsolated = "MARGIN_ISOLATEDMARGIN"; // Margin (cross) to Isolated margin
  static const String isolatedToIsolated = "ISOLATEDMARGIN_ISOLATEDMARGIN"; // Isolated margin to Isolated margin
  static const String spotToFunding = "MAIN_FUNDING"; // Spot to Funding
  static const String fundingToSpot = "FUNDING_MAIN"; // Funding to Spot
  static const String fundingToFuture = "FUNDING_UMFUTURE"; // Funding to USDⓈ-M Futures
  static const String futureToFunding = "UMFUTURE_FUNDING"; // USDⓈ-M Futures to Funding
  static const String marginToFunding = "MARGIN_FUNDING"; // Margin (cross) to Funding
  static const String fundingToMargin = "FUNDING_MARGIN"; // Funding to Margin (cross)
  static const String fundingToCoinFuture = "FUNDING_CMFUTURE"; // Funding to COIN-M Futures
  static const String coinFutureToFunding = "CMFUTURE_FUNDING"; //  COIN-M Futures to Funding
}
