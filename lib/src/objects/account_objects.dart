// =================================================================================================================

class BnApiSnapshotSpotBalance {
  final String asset;
  final double free;
  final double locked;

  BnApiSnapshotSpotBalance(Map m)
      : asset = m['asset'],
        free = double.parse(m['free']),
        locked = double.parse(m['locked']);

  @override
  String toString() {
    return '$asset free: $free locked: $locked';
  }
}

class BnApiAccountSnapshotSpot {
  final DateTime updateTime;
  final double totalAssetOfBtc;
  final List<BnApiSnapshotSpotBalance> balances;

  BnApiAccountSnapshotSpot(Map m)
      : updateTime = DateTime.fromMillisecondsSinceEpoch(m['updateTime']),
        totalAssetOfBtc = double.parse(m['data']['totalAssetOfBtc']),
        balances = List<BnApiSnapshotSpotBalance>.from(m['data']['balances']
            .where((f) => f['free'] != '0' || f['locked'] != '0')
            .map((e) => BnApiSnapshotSpotBalance(e)));

  @override
  String toString() {
    return 'Total of BTC: $totalAssetOfBtc balances: $balances';
  }
}

// =================================================================================================================

class BnApiSnapshotMarginBalance {
  final String asset;
  final double borrowed;
  final double interest;
  final double netAsset;
  final double free;
  final double locked;

  BnApiSnapshotMarginBalance(Map m)
      : asset = m['asset'],
        borrowed = double.parse(m['borrowed']),
        interest = double.parse(m['interest']),
        netAsset = double.parse(m['netAsset']),
        free = double.parse(m['free']),
        locked = double.parse(m['locked']);

  @override
  String toString() {
    return '$asset free: $free locked: $locked';
  }
}

class BnApiAccountSnapshotMargin {
  /// Snapshot for cross margin

  final DateTime updateTime;
  final double totalAssetOfBtc;
  // final double marginLevel;
  final double totalLiabilityOfBtc;
  final double totalNetAssetOfBtc;
  final List<BnApiSnapshotMarginBalance> balances;

  BnApiAccountSnapshotMargin(Map m)
      : updateTime = DateTime.fromMillisecondsSinceEpoch(m['updateTime']),
        totalAssetOfBtc = double.parse(m['data']['totalAssetOfBtc']),
        // marginLevel = double.parse(m['data']['marginLevel']),
        totalLiabilityOfBtc = double.parse(m['data']['totalLiabilityOfBtc']),
        totalNetAssetOfBtc = double.parse(m['data']['totalNetAssetOfBtc']),
        balances = List<BnApiSnapshotMarginBalance>.from(m['data']['userAssets']
            .where((f) => f['free'] != '0' || f['locked'] != '0')
            .map((e) => BnApiSnapshotMarginBalance(e)));

  @override
  String toString() {
    return 'Total of BTC: $totalAssetOfBtc balances: $balances';
  }
}

// =================================================================================================================

class BnApiSnapshotFuturesBalance {
  final String asset;
  final double marginBalance;
  final double walletBalance;

  BnApiSnapshotFuturesBalance(Map m)
      : asset = m['asset'],
        marginBalance = double.parse(m['marginBalance']),
        walletBalance = double.parse(m['walletBalance']);

  @override
  String toString() {
    return '$asset margin: $marginBalance wallet: $walletBalance';
  }
}

class BnApiSnapshotFuturesPosition {
  final String symbol;
  final double entryPrice;
  final double markPrice;
  final double positionAmt;
  final double unRealizedProfit;

  BnApiSnapshotFuturesPosition(Map m)
      : symbol = m['symbol'],
        entryPrice = double.parse(m['entryPrice']),
        markPrice = double.parse(m['markPrice']),
        positionAmt = double.parse(m['positionAmt']),
        unRealizedProfit = double.parse(m['unRealizedProfit']);

  @override
  String toString() {
    return '$symbol entryPrice: $entryPrice markPrice: $markPrice';
  }
}

class BnApiAccountSnapshotFutures {
  final DateTime updateTime;
  final List<BnApiSnapshotFuturesBalance> assets;
  final List<BnApiSnapshotFuturesPosition> position;

  BnApiAccountSnapshotFutures(Map m)
      : updateTime = DateTime.fromMillisecondsSinceEpoch(m['updateTime']),
        assets = List<BnApiSnapshotFuturesBalance>.from(m['data']['assets']
            .where((f) => f['marginBalance'] != '0' || f['walletBalance'] != '0')
            .map((e) => BnApiSnapshotFuturesBalance(e))),
        position = List<BnApiSnapshotFuturesPosition>.from(
            m['data']['position'].where((f) => f['entryPrice'] != '0').map((e) => BnApiSnapshotFuturesPosition(e)));

  @override
  String toString() {
    return 'assets: $assets position: $position';
  }
}

// =================================================================================================================

class BnApiAccountDepositHistoryItem {
  final String id;
  final double amount;
  final String coin;
  final String network;
  final int status;
  final String address;
  final String addressTag;
  final String txId;
  final DateTime insertTime;
  final int transferType;
  final String confirmTimes;
  final int unlockConfirm;
  final int walletType;

  BnApiAccountDepositHistoryItem(Map m)
      : id = m['id'],
        amount = double.parse(m['amount']),
        coin = m['coin'],
        network = m['network'],
        status = m['status'],
        address = m['address'],
        addressTag = m['addressTag'],
        txId = m['txId'],
        insertTime = DateTime.fromMillisecondsSinceEpoch(m['insertTime']),
        transferType = m['transferType'],
        confirmTimes = m['confirmTimes'],
        unlockConfirm = m['unlockConfirm'],
        walletType = m['walletType'];

  @override
  String toString() {
    return '$coin confirms: $confirmTimes amount: $amount';
  }
}

// =================================================================================================================

class BnApiAccountWithdrawHistoryItem {
  final String id;
  final double amount;
  final double transactionFee;
  final String coin;
  final int status;
  final String address;
  final String txId; // withdrawal transaction id
  final String applyTime; // UTC time: 2019-10-12 11:12:02
  final String network;
  final int transferType; // 1 for internal transfer, 0 for external transfer
  final String? withdrawOrderId; // will not be returned if there's no withdrawOrderId for this withdraw
  final String? info; // reason for withdrawal failure
  final int? confirmNo; // confirm times for withdraw
  final int walletType; // 1: Funding Wallet, 0:Spot Wallet
  final String? txKey;

  BnApiAccountWithdrawHistoryItem(Map m)
      : id = m['id'],
        amount = double.parse(m['amount']),
        transactionFee = double.parse(m['transactionFee']),
        coin = m['coin'],
        status = m['status'],
        address = m['address'],
        txId = m['txId'],
        applyTime = m['applyTime'],
        network = m['network'],
        transferType = m['transferType'],
        withdrawOrderId = m['withdrawOrderId'],
        info = m['info'],
        confirmNo = m['confirmNo'],
        walletType = m['walletType'],
        txKey = m['txKey'];

  @override
  String toString() {
    return '$coin amount: $amount fee: $transactionFee';
  }
}

// =================================================================================================================

class BnApiAccountDepositAddress {
  final String address;
  final String coin;
  final String tag;
  final String url;

  BnApiAccountDepositAddress(Map m)
      : address = m['address'],
        coin = m['coin'],
        tag = m['tag'],
        url = m['url'];

  @override
  String toString() {
    return '$coin $address';
  }
}

// =================================================================================================================
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
