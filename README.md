# binance api

**_Binance Api on Dart language. Max copied from python library._**

* web site: [github.com][git]
* version: 0.1.9
* author: [meok][author]
* build: http, websocket

Actual for binance API version 2022-11-22 [binance-api][binance]

## Example

```dart
import 'package:bn_api/bn_api.dart';

main() async {
  final _binance = BnApi();

  final List _products = await _binance.getProducts().then((r) => r.json['data']);
  final serializedProducts = List<SymbolProduct>.from(_products.map((e) => SymbolProduct.fromJson(e)));
}
```

## Functions

- [ ] Serilize
- [ ] Websocket

## Release notes

[Release notes][log]

[git]: <https://github.com/meoook/bn_api> "Git repository"
[binance]: <https://binance-docs.github.io/apidocs/spot/en/#change-log> "Binance API"
[log]: <CHANGELOG.md> "Release notes"
[author]: <https://bazha.ru> "meok home page"
