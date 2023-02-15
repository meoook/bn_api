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

class BnApiAccountTradingStatus {
  final bool isLocked; // API trading function is locked or not
  final DateTime? plannedRecoverTime; // If API trading function is locked, this is the planned recover time
  // Trigger condition
  final int gcr; // Number of GTC orders
  final int ifer; // Number of FOK/IOC orders
  final int ufr; // Number of orders
  final DateTime updateTime;

  BnApiAccountTradingStatus(Map m)
      : isLocked = m['isLocked'],
        plannedRecoverTime =
            m['plannedRecoverTime'] == 0 ? DateTime.fromMillisecondsSinceEpoch(m['plannedRecoverTime']) : null,
        gcr = m['triggerCondition']['GCR'],
        ifer = m['triggerCondition']['IFER'],
        ufr = m['triggerCondition']['UFR'],
        updateTime = DateTime.fromMillisecondsSinceEpoch(m['updateTime']);

  @override
  String toString() {
    return 'locked: $isLocked';
  }
}

// =================================================================================================================

class BnApiAccountBnbExchangeDetails {
  final int transId;
  final double serviceChargeAmount;
  final double amount;
  final DateTime operateTime;
  final double transferedAmount;
  final String fromAsset;

  BnApiAccountBnbExchangeDetails(Map m)
      : transId = m['transId'],
        serviceChargeAmount = double.parse(m['serviceChargeAmount']),
        amount = double.parse(m['amount']),
        operateTime = DateTime.fromMillisecondsSinceEpoch(m['operateTime']),
        transferedAmount = double.parse(m['transferedAmount']),
        fromAsset = m['fromAsset'];

  @override
  String toString() {
    return '$fromAsset $amount';
  }
}

class BnApiAccountBnbExchange {
  final DateTime operateTime;
  final double totalTransferedAmount; // Total transfered BNB amount for this exchange
  final double totalServiceChargeAmount; //Total service charge amount for this exchange
  final int transId;
  final List<BnApiAccountBnbExchangeDetails> userAssetDribbletDetails; // Details of  this exchange

  BnApiAccountBnbExchange(Map m)
      : operateTime = DateTime.fromMillisecondsSinceEpoch(m['operateTime']),
        totalTransferedAmount = double.parse(m['totalTransferedAmount']),
        totalServiceChargeAmount = double.parse(m['totalServiceChargeAmount']),
        transId = m['transId'],
        userAssetDribbletDetails = List<BnApiAccountBnbExchangeDetails>.from(
            m['userAssetDribbletDetails'].map((e) => BnApiAccountBnbExchangeDetails(e)));

  @override
  String toString() {
    return 'total amount $totalTransferedAmount BNB detail: $userAssetDribbletDetails';
  }
}

// =================================================================================================================

class BnApiAccountAssetAvailableToConvert {
  final String asset;
  final String assetFullName;
  final double amountFree; // Convertible amount
  final double toBTC; // BTC amount
  final double toBNB; // BNB amount（Not deducted commission fee
  final double toBNBOffExchange; // BNB amount（Deducted commission fee)
  final double exchange; // Commission fee

  BnApiAccountAssetAvailableToConvert(Map m)
      : asset = m['asset'],
        assetFullName = m['assetFullName'],
        amountFree = double.parse(m['amountFree']),
        toBTC = double.parse(m['toBTC']),
        toBNB = double.parse(m['toBNB']),
        toBNBOffExchange = double.parse(m['toBNBOffExchange']),
        exchange = double.parse(m['exchange']);

  @override
  String toString() {
    return '$asset $amountFree to BNB: $toBNB';
  }
}

class BnApiAccountAssetsAvailableToConvert {
  final double totalTransferBtc;
  final double totalTransferBNB;
  final double dribbletPercentage; // Commission fee
  final List<BnApiAccountAssetAvailableToConvert> details;

  BnApiAccountAssetsAvailableToConvert(Map m)
      : totalTransferBtc = double.parse(m['totalTransferBtc']),
        totalTransferBNB = double.parse(m['totalTransferBNB']),
        dribbletPercentage = double.parse(m['dribbletPercentage']),
        details = List<BnApiAccountAssetAvailableToConvert>.from(
            m['details'].map((e) => BnApiAccountAssetAvailableToConvert(e)));

  @override
  String toString() {
    return 'total to BNB: $totalTransferBNB details: $details';
  }
}

// =================================================================================================================

class BnApiAccountAssetConverted {
  final String fromAsset;
  final double amount;
  final DateTime operateTime;
  final double serviceChargeAmount;
  final int tranId;
  final double transferedAmount;

  BnApiAccountAssetConverted(Map m)
      : fromAsset = m['fromAsset'],
        amount = double.parse(m['amount']),
        operateTime = DateTime.fromMillisecondsSinceEpoch(m['operateTime']),
        serviceChargeAmount = double.parse(m['serviceChargeAmount']),
        tranId = m['tranId'],
        transferedAmount = double.parse(m['transferedAmount']);

  @override
  String toString() {
    return '$fromAsset amount: $amount';
  }
}

class BnApiAccountAssetsConverted {
  final double totalServiceCharge;
  final double totalTransfered;
  final List<BnApiAccountAssetConverted> transferResult;

  BnApiAccountAssetsConverted(Map m)
      : totalServiceCharge = double.parse(m['totalServiceCharge']),
        totalTransfered = double.parse(m['totalTransfered']),
        transferResult =
            List<BnApiAccountAssetConverted>.from(m['transferResult'].map((e) => BnApiAccountAssetConverted(e)));

  @override
  String toString() {
    return 'converted $totalTransfered result: $transferResult';
  }
}

// =================================================================================================================

class BnApiAccountAssetDividend {
  final int id;
  final String asset;
  final double amount;
  final DateTime divTime;
  final String enInfo;
  final int tranId;

  BnApiAccountAssetDividend(Map m)
      : id = m['id'],
        asset = m['asset'],
        amount = double.parse(m['amount']),
        divTime = DateTime.fromMillisecondsSinceEpoch(m['divTime']),
        enInfo = m['enInfo'],
        tranId = m['tranId'];

  @override
  String toString() {
    return '$asset $amount';
  }
}

// =================================================================================================================

class BnApiAccountTransferItem {
  final String asset;
  final double amount;
  final String type; // BnApiUniversalTransfer
  final String status; // status: CONFIRMED / FAILED / PENDING
  final int tranId;
  final DateTime timestamp;

  BnApiAccountTransferItem(Map m)
      : asset = m['asset'],
        amount = double.parse(m['amount']),
        type = m['type'],
        status = m['status'],
        tranId = m['tranId'],
        timestamp = DateTime.fromMillisecondsSinceEpoch(m['timestamp']);

  @override
  String toString() {
    return '$asset $amount $type';
  }
}

// =================================================================================================================

class BnApiAccountFundingWallet {
  final String asset;
  final double free; // available balance
  final double locked; // locked asset
  final double freeze; // freeze asset
  final double withdrawing;
  final int? updateId;
  final double? btcValuation;

  BnApiAccountFundingWallet(Map m)
      : asset = m['asset'],
        free = double.parse(m['free']),
        locked = double.parse(m['locked']),
        freeze = double.parse(m['freeze']),
        withdrawing = double.parse(m['withdrawing']),
        btcValuation = m['btcValuation'] == null ? null : double.parse(m['btcValuation']),
        updateId = m['updateId'];

  @override
  String toString() {
    return '$asset free: $free locked: $locked freeze: $freeze';
  }
}

// =================================================================================================================

class BnApiAccountBusdConvert {
  final String asset;
  final int tranId;

  BnApiAccountBusdConvert(Map m)
      : asset = m['asset'],
        tranId = m['tranId'];

  @override
  String toString() {
    return '$asset';
  }
}

// =================================================================================================================

class BnApiAccountBusdConvertItem {
  final int tranId;
  final int type;
  final DateTime time;
  final String deductedAsset;
  final double deductedAmount;
  final String targetAsset;
  final double targetAmount;
  final String status;
  final String accountType;

  BnApiAccountBusdConvertItem(Map m)
      : tranId = m['tranId'],
        type = m['type'],
        time = DateTime.fromMillisecondsSinceEpoch(m['time']),
        deductedAsset = m['deductedAsset'],
        deductedAmount = double.parse(m['deductedAmount']),
        targetAsset = m['targetAsset'],
        targetAmount = double.parse(m['targetAmount']),
        status = m['status'],
        accountType = m['accountType'];

  @override
  String toString() {
    return '$deductedAmount $deductedAsset';
  }
}

// =================================================================================================================

class BnApiAccountCloudMining {
  final DateTime createTime;
  final int tranId;
  final int type; // 248 - payment, 249 - refund
  final String asset;
  final double amount;
  final String status; // S - SUCCESS

  BnApiAccountCloudMining(Map m)
      : createTime = DateTime.fromMillisecondsSinceEpoch(m['createTime']),
        tranId = m['tranId'],
        type = m['type'],
        asset = m['asset'],
        amount = double.parse(m['amount']),
        status = m['status'];

  @override
  String toString() {
    return '$asset $amount';
  }
}

// =================================================================================================================

class BnApiAccountPermissions {
  final bool ipRestrict;
  final DateTime createTime;
  final DateTime? tradingAuthorityExpirationTime; // Expiration time for spot and margin trading permission
  final bool enableReading;
  final bool enableSpotAndMarginTrading; // Spot and margin trading
  final bool enableWithdrawals; // Enable withdraw via API
  final bool enableInternalTransfer; // Enable transfer funds between your master account and your sub account instantly
  final bool enableMargin; //  This option can be adjusted after the Cross Margin account transfer is completed
  final bool enableFutures; //  API Key created before your futures account opened does not support futures API service
  final bool permitsUniversalTransfer; // Enable dedicated universal transfer API to transfer multiple currencies
  final bool enableVanillaOptions; //  Authorizes this key to Vanilla options trading

  BnApiAccountPermissions(Map m)
      : ipRestrict = m['ipRestrict'],
        createTime = DateTime.fromMillisecondsSinceEpoch(m['createTime']),
        tradingAuthorityExpirationTime = m['tradingAuthorityExpirationTime'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['tradingAuthorityExpirationTime']),
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

// =================================================================================================================

class BnApiConvertingStableCoins {
  final bool convertEnabled;
  final List<String> coins;
  final Map<String, int> exchangeRates;

  BnApiConvertingStableCoins(Map m)
      : convertEnabled = m['convertEnabled'],
        coins = List<String>.from(m['coins'].map((e) => '$e')),
        exchangeRates =
            Map.fromIterable(m['exchangeRates'].entries, key: (e) => e.key, value: (e) => int.parse(e.value));

  @override
  String toString() {
    return '${convertEnabled ? 'enabled' : 'disabled'} rates: $exchangeRates';
  }
}

// =================================================================================================================

class BnApiBnbBurnSpotMargin {
  final bool spotBNBBurn;
  final bool interestBNBBurn;

  BnApiBnbBurnSpotMargin(Map m)
      : spotBNBBurn = m['spotBNBBurn'],
        interestBNBBurn = m['interestBNBBurn'];

  @override
  String toString() {
    return 'spot: $spotBNBBurn margin: $interestBNBBurn';
  }
}

// =================================================================================================================
// =================================================================================================================

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
