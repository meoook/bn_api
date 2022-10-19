import 'package:bn_api/bn_api.dart';

main() async {
  final _binance = BnApi();

  final List _products = await _binance.getProducts().then((r) => r.json['data']);
  final data = List<SymbolProduct>.from(_products.map((e) => SymbolProduct.fromJson(e)));
  print('All ok ${data}');
}
