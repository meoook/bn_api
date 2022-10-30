import 'bn_api.dart';
import 'objects.dart';
import 'objects/acc_objects.dart';

class BnSerializedApi {
  final BnApi _api;

  BnSerializedApi({String? apiKey, String? apiSecret}) : _api = BnApi(apiKey: apiKey, apiSecret: apiSecret);

  Future<List<SymbolProduct>> productList() async {
    final List _products = await _api.getProducts().then((r) => r.json['data']);
    return List<SymbolProduct>.from(_products.map((e) => SymbolProduct(e)));
  }

  Future<ExchangeInfo> getExchangeInfo() async {
    final Map _info = await _api.getExchangeInfo().then((r) => r.json);
    return ExchangeInfo(_info);
  }

  Future<AccPermissions> getAccountApiPermissions() async {
    final Map _info = await _api.getAccountApiPermissions().then((r) => r.json);
    return AccPermissions(_info);
  }
}
