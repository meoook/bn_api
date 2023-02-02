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

// =================================================================================================================

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

// =================================================================================================================

class BnApiAssetWithdrawDetail {
  final String asset;
  final double minWithdrawAmount;
  final bool depositStatus; // deposit status (false if ALL of networks' are false)
  final double withdrawFee;
  final bool withdrawStatus; // withdraw status (false if ALL of networks' are false)
  final String? depositTip; // reason

  BnApiAssetWithdrawDetail(this.asset, Map m)
      : minWithdrawAmount = double.parse(m['minWithdrawAmount']),
        depositStatus = m['depositStatus'],
        withdrawFee = double.parse(m['withdrawFee']),
        withdrawStatus = m['withdrawStatus'],
        depositTip = m['depositTip'];

  @override
  String toString() {
    return '$asset min: $minWithdrawAmount fee: $withdrawFee';
  }
}

// =================================================================================================================

class BnApiSymbolTradeFee {
  final String symbol;
  final double makerCommission;
  final double takerCommission;

  BnApiSymbolTradeFee(Map m)
      : symbol = m['symbol'],
        makerCommission = double.parse(m['makerCommission']),
        takerCommission = double.parse(m['takerCommission']);

  @override
  String toString() {
    return '$symbol maker-fee: $makerCommission taker-fee: $takerCommission';
  }
}

// =================================================================================================================
// =================================================================================================================
