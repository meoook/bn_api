library binance;

export 'src/objects.dart';

import 'src/new/websocket.dart';
import 'src/bn_api.dart';

// class Binance with BnApi
class Binance with BinanceWebsocket {}
