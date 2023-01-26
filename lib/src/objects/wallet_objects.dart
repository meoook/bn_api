class BnApiSystemStatus {
  final int status;
  final String msg;

  BnApiSystemStatus(Map m)
      : status = m['status'],
        msg = m['msg'];

  @override
  String toString() {
    return '$msg';
  }
}

// ============================================================================

class BnApiNetwork {
  final String network;
  final String coin;
  final String name;
  final double withdrawIntegerMultiple;
  final bool isDefault;
  final bool depositEnable;
  final bool withdrawEnable;
  final String? depositDesc;
  final String? withdrawDesc;
  final String? specialTips;
  final String? specialWithdrawTips;
  final String? addressRule;
  final String? memoRegex;
  final bool resetAddressStatus;
  final bool busy;
  final String addressRegex;
  final String? country;
  final double withdrawFee;
  final double withdrawMin;
  final double withdrawMax;
  final int minConfirm; // min number for balance confirmation
  final int unLockConfirm; // confirmation number for balance unlock
  final int estimatedArrivalTime;
  final bool sameAddress;

  BnApiNetwork(Map m)
      : network = m['network'],
        coin = m['coin'],
        name = m['name'],
        withdrawIntegerMultiple = double.parse(m['withdrawIntegerMultiple']),
        isDefault = m['isDefault'],
        depositEnable = m['depositEnable'],
        withdrawEnable = m['withdrawEnable'],
        depositDesc = m['depositDesc'],
        withdrawDesc = m['withdrawDesc'],
        specialTips = m['specialTips'],
        specialWithdrawTips = m['specialWithdrawTips'],
        addressRule = m['addressRule'],
        memoRegex = m['memoRegex'],
        resetAddressStatus = m['resetAddressStatus'],
        busy = m['busy'],
        addressRegex = m['addressRegex'],
        country = m['country'],
        withdrawFee = double.parse(m['withdrawFee']),
        withdrawMin = double.parse(m['withdrawMin']),
        withdrawMax = double.parse(m['withdrawMax']),
        minConfirm = m['minConfirm'],
        unLockConfirm = m['unLockConfirm'],
        estimatedArrivalTime = m['estimatedArrivalTime'],
        sameAddress = m['sameAddress'];

  @override
  String toString() {
    return '$coin $network';
  }
}

class BnApiCoinInfo {
  final String coin;
  final String name;
  final bool depositAllEnable;
  final bool withdrawAllEnable;
  final bool isLegalMoney;
  final bool trading;
  final double free;
  final double locked;
  final double freeze;
  final double withdrawing;
  final double ipoing;
  final double ipoable;
  final double storage;
  final List<BnApiNetwork> networkList;

  BnApiCoinInfo(Map m)
      : coin = m['coin'],
        name = m['name'],
        depositAllEnable = m['depositAllEnable'],
        withdrawAllEnable = m['withdrawAllEnable'],
        isLegalMoney = m['isLegalMoney'],
        trading = m['trading'],
        free = double.parse(m['free']),
        locked = double.parse(m['locked']),
        freeze = double.parse(m['freeze']),
        withdrawing = double.parse(m['withdrawing']),
        ipoing = double.parse(m['ipoing']),
        ipoable = double.parse(m['ipoable']),
        storage = double.parse(m['storage']),
        networkList = List<BnApiNetwork>.from(m['networkList'].map((e) => BnApiNetwork(e)));

  @override
  String toString() {
    return '$coin name: $name';
  }
}

// ============================================================================

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

// ============================================================================

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
            // .where((f) => f['free'] != '0' || f['locked'] != '0')
            .map((e) => BnApiSnapshotMarginBalance(e)));

  @override
  String toString() {
    return 'Total of BTC: $totalAssetOfBtc balances: $balances';
  }
}

// ============================================================================

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

// ============================================================================

// ============================================================================
