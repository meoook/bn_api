# binance api

**_Binance Api on Dart language. Max copied from python library._**

* web site: [github.com][git]
* version: 0.0.1
* author: [meok][author]
* build: http, websocket

## Example

```dart
import 'package:binance/bn_api.dart';

main() async {
  final _binance = Binance();

  final trades = await _binance.getTrades(); 
}
```

## Functions

- [ ] Serilize
- [ ] Websocket

## Release notes

[Release notes][log]

[git]: <https://github.com/meoook/bn_api> "Git repository"
[log]: <CHANGELOG.md> "Release notes"
[author]: <https://bazha.ru> "meok home page"
