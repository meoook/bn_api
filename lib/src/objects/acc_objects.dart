class AccPermissions {
  final bool ipRestrict;
  final DateTime createTime;
  final DateTime tradingAuthorityExpirationTime;
  final bool enableReading;
  final bool enableSpotAndMarginTrading;
  final bool enableWithdrawals;
  final bool enableInternalTransfer;
  final bool enableMargin;
  final bool enableFutures;
  final bool permitsUniversalTransfer;
  final bool enableVanillaOptions;

  AccPermissions(Map m)
      : ipRestrict = m['ipRestrict'],
        createTime = DateTime.fromMillisecondsSinceEpoch(m['createTime']),
        tradingAuthorityExpirationTime = DateTime.fromMillisecondsSinceEpoch(m['tradingAuthorityExpirationTime']),
        enableReading = m['enableReading'],
        enableSpotAndMarginTrading = m['enableSpotAndMarginTrading'],
        enableWithdrawals = m['enableWithdrawals'],
        enableInternalTransfer = m['enableInternalTransfer'],
        enableMargin = m['enableMargin'],
        enableFutures = m['enableFutures'],
        permitsUniversalTransfer = m['permitsUniversalTransfer'],
        enableVanillaOptions = m['enableVanillaOptions'];
}
