import 'package:bn_api/bn_api.dart';

main() async {
  final String API_KEY = '';
  final String API_SECRET = '';
  final String symbol = 'LINKBUSD';
  final String asset = 'LINK';
  final int endTime = DateTime.now().millisecondsSinceEpoch;
  final int startTime = endTime - const Duration(days: 30).inMilliseconds;

  final _binance = BnSerializedApi(apiKey: API_KEY, apiSecret: API_SECRET, debug: true);

  // final systemStatus = await _binance.serverGetStatus();
  // print('System status: $systemStatus');

  // final allCoinsInfo = await _binance.coinsGetInfo();
  // print('All coins info: $allCoinsInfo');

  // final accountSnapshot = await _binance.accountGetSnapshot(type: BnApiTradeType.margin);
  // print('Account snapshot: $accountSnapshot');

  // TODO: NOT TESTED
  // final accountDepositHistory = await _binance.accountGetDepositHistory();
  // print('Deposit History: $accountDepositHistory');

  // final accountWithdrawHistory = await _binance.accountGetWithdrawHistory();
  // print('Withdraw History: $accountWithdrawHistory');

  // final accountDepositAddress = await _binance.accountGetDepositAddress(coin: asset);
  // print('Deposit Address: $accountDepositAddress');

  // final accountTradeStatus = await _binance.accountGetTradingStatus();
  // print('Account trade status $accountTradeStatus');

  // final dustLog = await _binance.accountGetDustLog();
  // print('Dust Log: $dustLog');

  // final availableToConvert = await _binance.accountGetAvailableToConvert();
  // print('Available To Convert: $availableToConvert');

  // TODO: NOT TESTED
  // final accountConverted = await _binance.accountGetConvertToBnb(assets: ['BSW', 'OMG']);
  // print('Account Converted: $accountConverted');

  // final accountAssetsDividends = await _binance.accountAssetsDividends();
  // print('Account Assets Dividends: $accountAssetsDividends');

  // final assetsWithdrawDetail = await _binance.assetsGetWithdrawDetail(asset: asset);
  // print('Assets Withdraw Detail: $assetsWithdrawDetail');

  // final symbolsTradeFee = await _binance.symbolsTradeFee(symbol: symbol);
  // print('Symbols Trade Fee: $symbolsTradeFee');

  // final transferHistory = await _binance.accountUniversalTransferHistory(type: BnApiUniversalTransfer.crossToSpot);
  // print('Universal Transfer History: $transferHistory');

  // final fundingWallet = await _binance.accountFundingWallet(needBtcValuation: true);
  // print('Funding Wallet: $fundingWallet');

  // final accountUserAsset = await _binance.accountUserAsset(needBtcValuation: true);
  // print('User Assets: $accountUserAsset');

  // final accountConvertBusdHistory = await _binance.accountConvertBusdHistory(startTime: startTime, endTime: endTime);
  // print('Convert Busd History: $accountConvertBusdHistory');

  // final accountCloudMiningHistory = await _binance.accountCloudMiningHistory(startTime: startTime, endTime: endTime);
  // print('Cloud Mining History: $accountCloudMiningHistory');

  // final accountApiPermissions = await _binance.accountApiPermissions();
  // print('Account Api Permissions: $accountApiPermissions');

  // final accountConvertStableCoins = await _binance.accountConvertStableCoins(coin: 'USDC', enable: true);
  // print('Convert Stable Coins: $accountConvertStableCoins');

  // final accountConvertingStableCoins = await _binance.accountConvertingStableCoins();
  // print('Converting Stable Coins: $accountConvertingStableCoins');

  // final marginAccountBorrowDetails =
  //     await _binance.marginAccountBorrowDetails(asset: 'USDT', isolatedSymbol: 'COMPUSDT', startTime: startTime);
  // print('Margin Account Borrow: $marginAccountBorrowDetails');

  // final marginAccountRepayDetails =
  //     await _binance.marginAccountRepayDetails(asset: 'USDT', isolatedSymbol: 'COMPUSDT', startTime: startTime);
  // print('Margin Account Borrow: $marginAccountRepayDetails');

  // final marginAsset = await _binance.marginAsset(asset: asset);
  // print('Margin Asset $marginAsset');

  // final marginAllAsset = await _binance.marginAllAsset();
  // print('Margin All Asset $marginAllAsset');

  // final marginSymbol = await _binance.marginSymbol(symbol: symbol);
  // print('Margin Symbol $marginSymbol');

  // final marginAllSymbol = await _binance.marginAllSymbol();
  // print('Margin All Symbol $marginAllSymbol');

  // final marginPriceIndex = await _binance.marginPriceIndex(symbol: symbol);
  // print('Margin Price Index $marginPriceIndex');

  // TODO: NOT TESTED
  // final marginCreateOrder = await _binance.marginCreateOrder(
  //     symbol: symbol,
  //     side: BnApiOrderSide.buy,
  //     type: BnApiOrderType.limit,
  //     timeInForce: BnApiTimeInForce.gtc,
  //     isIsolated: true,
  //     quantity: 2,
  //     price: 5.5,
  //     sideEffectType: BnApiOrderSideEffect.margin);
  // print('Margin Create Isolated Order $marginCreateOrder');

  // TODO: NOT TESTED
  // final marginCancelOrder =
  //     await _binance.marginCancelOrder(symbol: symbol, isIsolated: true, orderId: marginCreateOrder.orderId);
  // print('Margin Cancel Isolated Order $marginCancelOrder');

  // TODO: NOT TESTED
  // final marginOrder2 = await _binance.marginCreateOrder(
  //     symbol: symbol,
  //     side: BnApiOrderSide.buy,
  //     type: BnApiOrderType.limit,
  //     timeInForce: BnApiTimeInForce.gtc,
  //     isIsolated: true,
  //     quantity: 2,
  //     price: 5.5,
  //     sideEffectType: BnApiOrderSideEffect.margin);
  // print('Margin Create Isolated Order $marginOrder2');

  // TODO: NOT TESTED
  // final marginGetOrder = await _binance.marginGetOrder(symbol: symbol, isIsolated: true, orderId: marginOrder2.orderId);
  // print('Margin Get Order  $marginGetOrder');

  // TODO: NOT TESTED
  // final marginCancelOrders = await _binance.marginCancelOrders(symbol: symbol, isIsolated: true);
  // print('Margin Cancel Isolated Orders $marginCancelOrders');

  // TODO: NOT TESTED
  // final marginTransferWithSpotHistory = await _binance.marginTransferWithSpotHistory();
  // print('Cross Margin Transfer With Spot History $marginTransferWithSpotHistory');

  // TODO: NOT TESTED
  // final marginInterestHistory = await _binance.marginInterestHistory();
  // print('Margin Interest History $marginInterestHistory');

  // TODO: NOT TESTED
  // final marginForceLiquidationRec = await _binance.marginForceLiquidationRec();
  // print('Margin Force Liquidation Records $marginForceLiquidationRec');

  // final marginAccount = await _binance.marginAccount();
  // print('Margin Cross Margin Account Info - $marginAccount');
  // print('Margin Cross Margin Account Asset: ${marginAccount.getAssetInfo('ADA')}');

  // final marginGetOpenOrders = await _binance.marginGetOpenOrders(symbol: 'OCEANUSDT', isIsolated: true);
  // print('Margin Open Orders $marginGetOpenOrders');

  // final marginGetAllOrders = await _binance.marginGetAllOrders(symbol: 'OCEANUSDT', isIsolated: true);
  // print('Margin All Orders $marginGetAllOrders');

  // TODO: NOT TESTED
  // final marginGetTrades = await _binance.marginGetTrades(symbol: 'OCEANUSDT', isIsolated: true);
  // print('Margin Trades $marginGetTrades');

  // final marginGetLevelInfo = await _binance.marginGetLevelInfo();
  // print('Margin Personal Level Info $marginGetLevelInfo');

  // final marginTransferMax = await _binance.marginTransferMax(asset: 'USDT', isolatedSymbol: 'OCEANUSDT');
  // print('Margin TransferMax $marginTransferMax');

  // final isolatedTransferHistory = await _binance.isolatedTransferHistory(symbol: 'OCEANUSDT');
  // print('Isolated Margin Transfer History $isolatedTransferHistory');

  // final isolatedMarginAccount = await _binance.isolatedMarginAccount(symbols: ['COMPUSDT', 'OCEANUSDT']);
  // print('Isolated Margin Account Info - $isolatedMarginAccount');
  // print('Isolated Margin Account Symbol ${isolatedMarginAccount.getSymbolInfo('OCEANUSDT')}');

  // final isolatedMarginAccountLimit = await _binance.isolatedMarginAccountLimit();
  // print('Isolated Margin Account Limit - $isolatedMarginAccountLimit');

  // final accountGetBnbBurnSpotMargin = await _binance.accountGetBnbBurnSpotMargin();
  // print('Bnb Burn Spot Margin - $accountGetBnbBurnSpotMargin');

  // final isolatedSymbol = await _binance.isolatedSymbol(symbol: symbol);
  // print('Isolated Margin Symbol $isolatedSymbol');

  // final isolatedSymbols = await _binance.isolatedSymbols();
  // print('All Isolated Margin Symbols $isolatedSymbols');

  // final marginInterestRateHistory = await _binance.marginInterestRateHistory(asset: asset, vipLevel: 2);
  // print('Margin Interest Rate History $marginInterestRateHistory');

  // final marginFee = await _binance.marginFee(coin: asset, vipLevel: 2);
  // print('Margin Fee $marginFee');

  // final isolatedFee = await _binance.isolatedFee();
  // print('Isolated Margin Fee $isolatedFee');

  // final isolatedTier = await _binance.isolatedTier(symbol: symbol);
  // print('Isolated Margin Tier $isolatedTier');

  // ==========================================================================================

  // final _klines = await _binance.getKLines(symbol, BnApiTimeFrame.min5, limit: 30);
  // print('KLINESs $_klines');
  // final _avgPrice = await _binance.getAvgPrice(symbol);
  // print('AvgPrice $_avgPrice');

  // final List<SymbolProduct> _products = await _binance.productList();
  // print('Products ${_products}');
  // final _info = await _binance.getExchangeInfo();
  // print('Info ${_info}');
  // print('XXX ${_info.getSymbolInfo('ETHBTC')}');

  // ==========================================================================================
}
