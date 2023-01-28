# binance api

**_Binance Api on Dart language._**

* web site: [github.com][git]
* version: 0.1.11
* author: [meok][author]
* dependencies: http, web_socket_channel, test

Actual for [binance API][binance] version 2023-01-19 

## Example

```dart
import 'package:bn_api/bn_api.dart';

main() async {
  final _binance = BnApi();

  final List _products = await _binance.getProducts().then((r) => r.json['data']);
  final serializedProducts = List<SymbolProduct>.from(_products.map((e) => SymbolProduct.fromJson(e)));
}
```

## Endpoints

- [ ] Wallet
- [ ] Sub-Account
- [ ] Market Data
- [ ] Websocket ?
- [ ] Spot Account/Trade
- [ ] Margin Account/Trade
- [ ] User Data Streams
- [ ] Savings
- [ ] Stacking
- [ ] Mining
- [ ] Futures
- [ ] Futures Algo
- [ ] Portfolio Margin
- [ ] BLVT
- [ ] BSwap
- [ ] Fiat
- [ ] C2C
- [ ] VIP Loans
- [ ] Crypto Loans
- [ ] Pay
- [ ] Convert
- [ ] Rebate
- [ ] NFT
- [ ] Gift Card

## Functionality

- [ ] Serialized API
- [ ] Websocket

## Release notes

[Release notes][log]

[git]: <https://github.com/meoook/bn_api> "Git repository"
[binance]: <https://binance-docs.github.io/apidocs/spot/en/#change-log> "Binance API"
[log]: <CHANGELOG.md> "Release notes"
[author]: <https://bazha.ru> "meok home page"
