enum KLinesType { spot, futures, futuresCoin }

enum HttpMethod { get, post, put, delete }

class BinanceApiException implements Exception {
  final int code;
  final String message;

  BinanceApiException(this.code, this.message);

  @override
  String toString() => message;
}
