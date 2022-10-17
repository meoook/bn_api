import 'package:bn_api/bn_api.dart';

main() async {
  final _binance = BnApi();

  final x = await _binance.getProducts();
  print('All ok $x');
}
