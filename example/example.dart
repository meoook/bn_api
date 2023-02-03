import 'package:bn_api/bn_api.dart';

main() async {
  final String API_KEY = '';
  final String API_SECRET = '';
  final String symbol = 'LINKBUSD';
  final String asset = 'LINK';
  final int startTime = DateTime.now().millisecondsSinceEpoch - const Duration(days: 30).inMilliseconds;

  final _binance = BnSerializedApi(apiKey: API_KEY, apiSecret: API_SECRET, debug: true);

  // final systemStatus = await _binance.serverGetStatus();
  // print('System status: $systemStatus');

  // final allCoinsInfo = await _binance.coinsGetInfo();
  // print('All coins info: $allCoinsInfo');

  // final accountSnapshot = await _binance.accountGetSnapshot(type: BnApiTradeType.margin);
  // print('Account snapshot: $accountSnapshot');

  // final accountDepositHistory = await _binance.accountGetDepositHistory();
  // print('Deposit History: $accountDepositHistory'); // TODO: Not tested

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

  // final accountConverted = await _binance.accountGetConvertToBnb(assets: ['BSW', 'OMG']);
  // print('Account Converted: $accountConverted'); // TODO: Not tested

  // final accountAssetsDividends = await _binance.accountAssetsDividends();
  // print('Account Assets Dividends: $accountAssetsDividends');

  // final assetsWithdrawDetail = await _binance.assetsGetWithdrawDetail(asset: asset);
  // print('Assets Withdraw Detail: $assetsWithdrawDetail');

  // final symbolsTradeFee = await _binance.symbolsTradeFee(symbol: symbol);
  // print('Symbols Trade Fee: $symbolsTradeFee');

  final transferHistory = await _binance.accountUniversalTransferHistory(type: BnApiUniversalTransfer.crossToSpot);
  print('Universal Transfer History: $transferHistory');

  // final List<SymbolProduct> _products = await _binance.productList();
  // print('Products ${_products}');
  // final _info = await _binance.getExchangeInfo();
  // print('Info ${_info}');
  // print('XXX ${_info.getSymbolInfo('ETHBTC')}');

  // Create margin isolated order
  // final _create = await _binance.createMarginOrder(symbol, BnApiOrderSide.buy, BnApiOrderType.limit,
  //     timeInForce: BnTimeInForce.gtc,
  //     isIsolated: true,
  //     quantity: 2,
  //     price: 5.5,
  //     sideEffectType: BnApiOrderSideEffect.margin);
  // print('Created $_create');
  // final _infoAll = await _binance.getOpenMarginOrders(symbol: symbol, isIsolated: true);
  // print('Check all $_infoAll');
  // final _info = await _binance.getMarginOrder(symbol: symbol, isIsolated: true, orderId: _create.orderId);
  // print('Check $_info');
  // final _cancel = await _binance.cancelMarginOrder(symbol: symbol, isIsolated: true, orderId: _create.orderId);
  // print('Cancels $_cancel');
  // final _klines = await _binance.getKLines(symbol, BnApiTimeFrame.min5, limit: 30);
  // print('KLINESs $_klines');
  // final _avgPrice = await _binance.getAvgPrice(symbol);
  // print('AvgPrice $_avgPrice');
  // final _marginAsset = await _binance.getMarginAsset(asset);
  // print('MarginAsset $_marginAsset');
  // final _marginTrades = await _binance.getMarginTrades(symbol, startTime: 1561973357171);
  // print('MarginTrades $_marginTrades');  // TODO: Not tested
  // final _marginLevelInfo = await _binance.getMarginLevelInfo('test@mail.ru');
  // print('MarginLevelInfo $_marginLevelInfo');
  // Get Isolated Margin Transfer History
  // final _getIsolatedTransferHistory = await _binance.getIsolatedTransferHistory(symbol, asset: asset);
  // print('Isolated Margin Transfer History $_getIsolatedTransferHistory');
  // final _isolatedMarginAccountInfo = await _binance.getIsolatedMarginAccount(symbol);
  // print('Isolated Margin Account Info no symbol $_isolatedMarginAccountInfo');
  // print('Isolated Margin Account Info ${_isolatedMarginAccountInfo.getAssetInfo(symbol)}');
  // final _allIsolatedMarginSymbols = await _binance.getAllIsolatedMarginSymbols();
  // print('getAllIsolatedMarginSymbols $_allIsolatedMarginSymbols');
  // final _getIsolatedMarginFee = await _binance.getIsolatedMarginFee();
  // print('getIsolatedMarginFee $_getIsolatedMarginFee');
}
