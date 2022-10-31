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

  @override
  String toString() {
    return 'spot: $enableSpotAndMarginTrading margin: $enableMargin futures: $enableFutures';
  }
}

class AccBalance {
  final String asset;
  final double free;
  final double locked;

  AccBalance(Map m)
      : asset = m['asset'],
        free = double.parse(m['free']),
        locked = double.parse(m['locked']);

  @override
  String toString() {
    return '${free + locked} $asset';
  }
}

class AccInfo {
  final int makerCommission;
  final int takerCommission;
  final int buyerCommission;
  final int sellerCommission;
  final bool canTrade;
  final bool canWithdraw;
  final bool canDeposit;
  final bool brokered;
  final DateTime updateTime;
  final String accountType; // SPOT
  final List<AccBalance> balances;
  final List<String> permissions;

  AccInfo(Map m)
      : makerCommission = m['makerCommission'],
        takerCommission = m['takerCommission'],
        buyerCommission = m['buyerCommission'],
        sellerCommission = m['sellerCommission'],
        canTrade = m['canTrade'],
        canWithdraw = m['canWithdraw'],
        canDeposit = m['canDeposit'],
        brokered = m['brokered'],
        updateTime = DateTime.fromMillisecondsSinceEpoch(m['updateTime']),
        accountType = m['accountType'],
        balances = List<AccBalance>.from(m['balances'].map((e) => AccBalance(e))),
        permissions = List<String>.from(m['permissions'].map((e) => '$e'));

  @override
  String toString() {
    return '$accountType trade: $canTrade withdraw: $canWithdraw deposit: $canDeposit';
  }

  AccBalance balanceOf(String asset) => balances.firstWhere((e) => e.asset == asset.toUpperCase());
}
