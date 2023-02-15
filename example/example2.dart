import 'package:bn_api/bn_api.dart';

main() async {
  final String API_KEY = '';
  final String API_SECRET = '';
  final String base = 'COMP';
  // final String base = 'OCEAN';
  final String quote = 'USDT';
  final String symbol = '$base$quote';

  final int endTime = DateTime.now().millisecondsSinceEpoch;
  final int startTime = endTime - const Duration(days: 30).inMilliseconds;

  final _binance = BnSerializedApi(apiKey: API_KEY, apiSecret: API_SECRET);

  print('============================================================================================================');
  // marginTransferWithSpot

  // final isolatedFee = await _binance.isolatedFee();
  // print('Isolated Margin Fee $isolatedFee');
  // print('============================================================================================================');

  final isolatedMarginAccount = await _binance.isolatedMarginAccount(symbols: [symbol]);
  print('Isolated Margin Account Info - $isolatedMarginAccount');
  print('Isolated Margin Account Symbol ${isolatedMarginAccount.getSymbolInfo(symbol)}');
  print('============================================================================================================');

  // final marginTransferMax = await _binance.marginTransferMax(asset: quote, isolatedSymbol: symbol);
  // print('Margin TransferMax $marginTransferMax');
  // print('============================================================================================================');

  // final marginGetOpenOrders = await _binance.marginGetOpenOrders(symbol: symbol, isIsolated: true);
  // print('Margin Open Orders $marginGetOpenOrders');
  // print('============================================================================================================');

  // final marginCreateOrder = await _binance.marginCreateOrder(
  //     symbol: symbol,
  //     side: BnApiOrderSide.buy,
  //     type: BnApiOrderType.limit,
  //     timeInForce: BnApiTimeInForce.gtc,
  //     isIsolated: true,
  //     quantity: 0.25,
  //     price: 42.5,
  //     sideEffectType: BnApiOrderSideEffect.margin);
  // print('Margin Create Isolated Order $marginCreateOrder');
  // print('============================================================================================================');

  // final marginCancelOrder =
  //     await _binance.marginCancelOrder(symbol: symbol, isIsolated: true, orderId: marginCreateOrder.orderId);
  // print('Margin Cancel Isolated Order $marginCancelOrder');
  // print('============================================================================================================');

  // final marginOrder2 = await _binance.marginCreateOrder(
  //     symbol: symbol,
  //     side: BnApiOrderSide.buy,
  //     type: BnApiOrderType.limit,
  //     timeInForce: BnApiTimeInForce.gtc,
  //     isIsolated: true,
  //     quantity: 0.25,
  //     price: 42.5,
  //     sideEffectType: BnApiOrderSideEffect.margin);
  // print('Margin Create Isolated Order $marginOrder2');
  // print('============================================================================================================');

  // final marginGetOrder = await _binance.marginGetOrder(symbol: symbol, isIsolated: true, orderId: marginOrder2.orderId);
  // print('Margin Get Order $marginGetOrder');
  // print('============================================================================================================');

  // final marginCancelOrders = await _binance.marginCancelOrders(symbol: symbol, isIsolated: true);
  // print('Margin Cancel Isolated Orders $marginCancelOrders');
  // print('============================================================================================================');

  // final marginGetTrades = await _binance.marginGetTrades(symbol: symbol, isIsolated: true);
  // print('Margin Trades $marginGetTrades');
}
