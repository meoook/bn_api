const statusMap = <int, String>{
  /// 10XX - General Server or Network issues
  -1000: 'UNKNOWN', // An unknown error occurred while processing the request.
  -1001: 'DISCONNECTED', // Internal error; unable to process your request. Please try again.
  -1002: 'UNAUTHORIZED', // You are not authorized to execute this request.
  -1003: 'TOO_MANY_REQUESTS', // Too many requests. Use websocket for live updates.
  -1004: 'DUPLICATE_IP', // This IP is already on the white list.
  -1005: 'NO_SUCH_IP', // No such IP has been white listed
  -1006: 'UNEXPECTED_RESP', // An unexpected response was received from the message bus.
  -1007: 'TIMEOUT', // Timeout waiting for response from backend server.
  -1010: 'ERROR_MSG_RECEIVED', // ERROR_MSG_RECEIVED
  -1011: 'NON_WHITE_LIST', // This IP cannot access this route.
  -1013: 'INVALID_MESSAGE', // INVALID_MESSAGE. Filter failure: PERCENT_PRICE
  -1014: 'UNKNOWN_ORDER_COMPOSITION', // Unsupported order combination.
  -1015: 'TOO_MANY_ORDERS', // Too many new orders
  -1016: 'SERVICE_SHUTTING_DOWN', // This service is no longer available.
  -1020: 'TOO_MANY_ORDERS', // This operation is not supported.
  -1021: 'INVALID_TIMESTAMP', // Timestamp for this request is outside recvWindow - 1000ms ahead of the server's time
  -1022: 'INVALID_SIGNATURE', // Signature for this request is not valid.
  -1023: 'START_TIME_GREATER_THAN_END_TIME', // Start time is greater than end time.
  /// 11XX - Request issues
  -1100: 'ILLEGAL_CHARS', // Illegal characters found in a parameter.
  -1101: 'TOO_MANY_PARAMETERS', // Too many parameters sent for endpoint. Duplicate values for a parameter detected.
  -1102: 'MANDATORY_PARAM_EMPTY_OR_MALFORMED', // A mandatory parameter was not sent, was empty/null, or malformed.
  -1103: 'UNKNOWN_PARAM', // An unknown parameter was sent.
  -1104: 'UNREAD_PARAMETERS', // Not all sent parameters were read.
  -1105: 'PARAM_EMPTY', // A parameter was empty.
  -1106: 'PARAM_NOT_REQUIRED', // A parameter was sent when not required.
  -1108: 'BAD_ASSET', // Invalid asset.
  -1109: 'BAD_ACCOUNT', // Invalid account.
  -1110: 'BAD_INSTRUMENT_TYPE', // Invalid symbolType.
  -1111: 'BAD_PRECISION', // Invalid symbolType.
  -1112: 'NO_DEPTH', // No orders on book for symbol.
  -1113: 'WITHDRAW_NOT_NEGATIVE', // Withdrawal amount must be negative.
  -1114: 'TIF_NOT_REQUIRED', // TimeInForce parameter sent when not required.
  -1115: 'INVALID_TIF', // Invalid timeInForce.
  -1116: 'INVALID_ORDER_TYPE', // Invalid orderType.
  -1117: 'INVALID_SIDE', // Invalid side.
  -1118: 'EMPTY_NEW_CL_ORD_ID', // New client order ID was empty.
  -1119: 'EMPTY_ORG_CL_ORD_ID', // Original client order ID was empty.
  -1120: 'BAD_INTERVAL', // Invalid interval.
  -1121: 'BAD_SYMBOL', // Invalid symbol.
  -1125: 'INVALID_LISTEN_KEY', // This listenKey does not exist.
  -1127: 'MORE_THAN_XX_HOURS', // Lookup interval is too big. More than %s hours between startTime and endTime.
  -1128: 'OPTIONAL_PARAMS_BAD_COMBO', // Combination of optional parameters invalid.
  -1130: 'INVALID_PARAMETER', // Invalid data sent for a parameter.
  -1136: 'INVALID_NEW_ORDER_RESP_TYPE', // Invalid newOrderRespType.
  /// 20XX - Processing Issues
  -2010: 'NEW_ORDER_REJECTED', // NEW_ORDER_REJECTED
  -2011: 'CANCEL_REJECTED', // CANCEL_REJECTED
  -2013: 'NO_SUCH_ORDER', // Order does not exist.
  -2014: 'BAD_API_KEY_FMT', // API-key format invalid.
  -2015: 'REJECTED_MBX_KEY', // Invalid API-key, IP, or permissions for action.
  -2016: 'NO_TRADING_WINDOW', // No trading window could be found for the symbol. Try ticker/24hrs instead.
  -2018: 'BALANCE_NOT_SUFFICIENT', // Balance is insufficient.
  -2019: 'MARGIN_NOT_SUFFICIENT', // Margin is insufficient.
  -2020: 'UNABLE_TO_FILL', // Unable to fill.
  -2021: 'ORDER_WOULD_IMMEDIATELY_TRIGGER', // Order would immediately trigger.
  -2022: 'REDUCE_ONLY_REJECT', // ReduceOnly Order is rejected.
  -2023: 'USER_IN_LIQUIDATION', // User in liquidation mode now.
  -2024: 'POSITION_NOT_SUFFICIENT', // Position is not sufficient.
  -2025: 'MAX_OPEN_ORDER_EXCEEDED', // Reach max open order limit.
  -2026: 'REDUCE_ONLY_ORDER_TYPE_NOT_SUPPORTED', // This OrderType is not supported when reduceOnly.
  -2027: 'MAX_LEVERAGE_RATIO', // Exceeded the maximum allowable position at current leverage.
  -2028: 'MIN_LEVERAGE_RATIO', // Leverage is smaller than permitted: insufficient margin balance.
  /// 3XXX-5XXX SAPI-specific issues
  -3000: 'INNER_FAILURE', // Internal server error.
  -3001: 'NEED_ENABLE_2FA', // Please enable 2FA first.
  -3002: 'ASSET_DEFICIENCY', // We don't have this asset.
  -3003: 'NO_OPENED_MARGIN_ACCOUNT', // Margin account does not exist.
  -3004: 'TRADE_NOT_ALLOWED', // Trade not allowed.
  -3005: 'TRANSFER_OUT_NOT_ALLOWED', // Transferring out not allowed.
  -3006: 'EXCEED_MAX_BORROWABLE', // Your borrow amount has exceed maximum borrow amount.
  -3007: 'HAS_PENDING_TRANSACTION', // You have pending transaction, please try again later.
  -3008: 'BORROW_NOT_ALLOWED', // Borrow not allowed.
  -3009: 'ASSET_NOT_MORTGAGEABLE', // This asset are not allowed to transfer into margin account currently.
  -3010: 'REPAY_NOT_ALLOWED', // Repay not allowed.
  -3011: 'BAD_DATE_RANGE', // Your input date is invalid.
  -3012: 'ASSET_ADMIN_BAN_BORROW', // Borrow is banned for this asset.
  -3013: 'LT_MIN_BORROWABLE', // Borrow amount less than minimum borrow amount.
  -3014: 'ACCOUNT_BAN_BORROW', // Borrow is banned for this account.
  -3015: 'REPAY_EXCEED_LIABILITY', // Repay amount exceeds borrow amount.
  -3016: 'LT_MIN_REPAY', // Repay amount less than minimum repay amount.
  -3017: 'ASSET_ADMIN_BAN_MORTGAGE', // This asset are not allowed to transfer into margin account currently.
  -3018: 'ACCOUNT_BAN_MORTGAGE', // Transferring in has been banned for this account.
  -3019: 'ACCOUNT_BAN_ROLLOUT', // Transferring out has been banned for this account.
  -3020: 'EXCEED_MAX_ROLLOUT', // Transfer out amount exceeds max amount.
  -3021: 'PAIR_ADMIN_BAN_TRADE', // Margin account are not allowed to trade this trading pair.
  -3022: 'ACCOUNT_BAN_TRADE', // You account's trading is banned.
  -3023: 'WARNING_MARGIN_LEVEL', // You can't transfer out/place order under current margin level.
  -3024: 'FEW_LIABILITY_LEFT', // The unpaid debt is too small after this repayment.
  -3025: 'INVALID_EFFECTIVE_TIME', // Your input date is invalid.
  -3026: 'VALIDATION_FAILED', // Your input param is invalid.
  -3027: 'NOT_VALID_MARGIN_ASSET', // Not a valid margin asset.
  -3028: 'NOT_VALID_MARGIN_PAIR', // Not a valid margin pair.
  -3029: 'TRANSFER_FAILED', // Transfer failed.
  -3036: 'ACCOUNT_BAN_REPAY', // This account is not allowed to repay.
  -3037: 'PNL_CLEARING', // PNL is clearing. Wait a second.
  -3038: 'LISTEN_KEY_NOT_FOUND', // Listen key not found.
  -3041: 'BALANCE_NOT_CLEARED', // Balance is not enough
  -3042: 'PRICE_INDEX_NOT_FOUND', // PriceIndex not available for this margin pair.
  -3043: 'TRANSFER_IN_NOT_ALLOWED', // Transferring in not allowed.
  -3044: 'SYSTEM_BUSY', // System busy.
  -3045: 'SYSTEM', //  The system doesn't have enough asset now.
  -3999: 'NOT_WHITELIST_USER', // This function is only available for invited users.
  /// 40XX - Filters and other Issues
  -4000: 'INVALID_ORDER_STATUS', // Invalid order status.
  -4001: 'PRICE_LESS_THAN_ZERO', // Price less than 0.
  -4002: 'PRICE_GREATER_THAN_MAX_PRICE', // Price greater than max price.
  -4003: 'QTY_LESS_THAN_ZERO', // Quantity less than zero.
  -4004: 'QTY_LESS_THAN_MIN_QTY', // Quantity less than min quantity.
  -4005: 'QTY_GREATER_THAN_MAX_QTY', // Quantity greater than max quantity.
  -4006: 'STOP_PRICE_LESS_THAN_ZERO', // Stop price less than zero.
  -4007: 'STOP_PRICE_GREATER_THAN_MAX_PRICE', // Stop price greater than max price.
  -4008: 'TICK_SIZE_LESS_THAN_ZERO', // Tick size less than zero.
  -4009: 'MAX_PRICE_LESS_THAN_MIN_PRICE', // Max price less than min price.
  -4010: 'MAX_QTY_LESS_THAN_MIN_QTY', // Max qty less than min qty.
  -4011: 'STEP_SIZE_LESS_THAN_ZERO', // Step size less than zero.
  -4012: 'MAX_NUM_ORDERS_LESS_THAN_ZERO', // Max mum orders less than zero.
  -4013: 'PRICE_LESS_THAN_MIN_PRICE', // Price less than min price.
  -4014: 'PRICE_NOT_INCREASED_BY_TICK_SIZE', // Price not increased by tick size.
  -4015: 'INVALID_CL_ORD_ID_LEN', // Client order id is not valid (should not be more than 36 chars).
  -4016: 'PRICE_HIGHTER_THAN_MULTIPLIER_UP', // Price is higher than mark price multiplier cap.
  -4017: 'MULTIPLIER_UP_LESS_THAN_ZERO', // Multiplier up less than zero.
  -4018: 'MULTIPLIER_DOWN_LESS_THAN_ZERO', // Multiplier down less than zero.
  -4019: 'COMPOSITE_SCALE_OVERFLOW', // Composite scale too large.
  -4020: 'TARGET_STRATEGY_INVALID', // Target strategy invalid for orderType '%s',reduceOnly '%b'.
  -4021: 'INVALID_DEPTH_LIMIT', // Invalid depth limit. '%s' is not valid depth limit.
  -4022: 'WRONG_MARKET_STATUS', // market status sent is not valid.
  -4023: 'QTY_NOT_INCREASED_BY_STEP_SIZE', // Qty not increased by step size.
  -4024: 'PRICE_LOWER_THAN_MULTIPLIER_DOWN', // Price is lower than mark price multiplier floor.
  -4025: 'MULTIPLIER_DECIMAL_LESS_THAN_ZERO', // Multiplier decimal less than zero.
  -4026: 'COMMISSION_INVALID', // Commission invalid. %s less than zero. %s absolute value greater than %s
  -4027: 'INVALID_ACCOUNT_TYPE', // Invalid account type.
  -4028: 'INVALID_LEVERAGE', // Invalid leverage. Leverage %s is not valid. Leverage %s already exist with %s
  -4029: 'INVALID_TICK_SIZE_PRECISION', // Tick size precision is invalid.
  -4030: 'INVALID_STEP_SIZE_PRECISION', // Step size precision is invalid.
  -4031: 'INVALID_WORKING_TYPE', // Invalid parameter working type. Invalid parameter working type: %s
  -4032: 'EXCEED_MAX_CANCEL_ORDER_SIZE', // Exceed maximum cancel order size. Invalid parameter working type: %s
  -4033: 'INSURANCE_ACCOUNT_NOT_FOUND', // Insurance account not found.
  -4044: 'INVALID_BALANCE_TYPE', // Balance Type is invalid.
  -4045: 'MAX_STOP_ORDER_EXCEEDED', // Reach max stop order limit.
  -4046: 'NO_NEED_TO_CHANGE_MARGIN_TYPE', // No need to change margin type.
  -4047: 'THERE_EXISTS_OPEN_ORDERS', // Margin type cannot be changed if there exists open orders.
  -4048: 'THERE_EXISTS_QUANTITY', // Margin type cannot be changed if there exists position.
  -4049: 'ADD_ISOLATED_MARGIN_REJECT', // Add margin only support for isolated position.
  -4050: 'CROSS_BALANCE_INSUFFICIENT', // Cross balance insufficient.
  -4051: 'ISOLATED_BALANCE_INSUFFICIENT', // Isolated balance insufficient.
  -4052: 'NO_NEED_TO_CHANGE_AUTO_ADD_MARGIN', // No need to change auto add margin.
  -4053: 'AUTO_ADD_CROSSED_MARGIN_REJECT', // Auto add margin only support for isolated position.
  -4054: 'ADD_ISOLATED_MARGIN_NO_POSITION_REJECT', // Cannot add position margin: position is 0.
  -4055: 'AMOUNT_MUST_BE_POSITIVE', // Amount must be positive.
  -4056: 'INVALID_API_KEY_TYPE', // Invalid api key type.
  -4057: 'INVALID_RSA_PUBLIC_KEY', // Invalid api public key
  -4058: 'MAX_PRICE_TOO_LARGE', // maxPrice and priceDecimal too large,please check.
  -4059: 'NO_NEED_TO_CHANGE_POSITION_SIDE', // No need to change position side.
  -4060: 'INVALID_POSITION_SIDE', // Invalid position side.
  -4061: 'POSITION_SIDE_NOT_MATCH', // Order's position side does not match user's setting.
  -4062: 'REDUCE_ONLY_CONFLICT', // Invalid or improper reduceOnly value.
  -4063: 'INVALID_OPTIONS_REQUEST_TYPE', // Invalid options request type
  -4064: 'INVALID_OPTIONS_TIME_FRAME', // Invalid options time frame
  -4065: 'INVALID_OPTIONS_AMOUNT', // Invalid options amount
  -4066: 'INVALID_OPTIONS_EVENT_TYPE', // Invalid options event type
  -4067: 'POSITION_SIDE_CHANGE_EXISTS_OPEN_ORDERS', // Position side cannot be changed if there exists open orders.
  -4068: 'POSITION_SIDE_CHANGE_EXISTS_QUANTITY', // Position side cannot be changed if there exists position.
  -4069: 'INVALID_OPTIONS_PREMIUM_FEE', // Invalid options premium fee
  -4070: 'INVALID_CL_OPTIONS_ID_LEN', // Client options id is not valid or should be less than 32 chars
  -4071: 'INVALID_OPTIONS_DIRECTION', // Invalid options direction
  -4072: 'OPTIONS_PREMIUM_NOT_UPDATE', // premium fee is not updated, reject order
  -4073: 'OPTIONS_PREMIUM_INPUT_LESS_THAN_ZERO', // input premium fee is less than 0, reject order
  -4074: 'OPTIONS_AMOUNT_BIGGER_THAN_UPPER', // Order amount is bigger than upper boundary or less than 0, reject order
  -4075: 'OPTIONS_PREMIUM_OUTPUT_ZERO', // output premium fee is less than 0, reject order
  -4076: 'OPTIONS_PREMIUM_TOO_DIFF', // original fee is too much higher than last fee
  -4077: 'OPTIONS_PREMIUM_REACH_LIMIT', // place order amount has reached to limit, reject order
  -4078: 'OPTIONS_COMMON_ERROR', // options internal error
  -4079: 'INVALID_OPTIONS_ID', // invalid options id. invalid options id: %s. duplicate options id %d for user %d
  -4080: 'OPTIONS_USER_NOT_FOUND', // user not found. user not found with id: %s
  -4081: 'OPTIONS_NOT_FOUND', // options not found. options not found with id: %s
  -4082: 'INVALID_BATCH_PLACE_ORDER_SIZE', // Invalid number of batch place orders.
  -4083: 'PLACE_BATCH_ORDERS_FAIL', // Fail to place batch orders.
  -4084: 'UPCOMING_METHOD', // Method is not allowed currently. Upcoming soon.
  -4085: 'INVALID_NOTIONAL_LIMIT_COEF', // Invalid notional limit coefficient
  -4086: 'INVALID_PRICE_SPREAD_THRESHOLD', // Invalid price spread threshold
  -4087: 'REDUCE_ONLY_ORDER_PERMISSION', // User can only place reduce only order
  -4088: 'NO_PLACE_ORDER_PERMISSION', // User can not place order currently
  -4104: 'INVALID_CONTRACT_TYPE', // Invalid contract type
  -4114: 'INVALID_CLIENT_TRAN_ID_LEN', // clientTranId is not valid. Client tran id length should be less than 64 chars
  -4115: 'DUPLICATED_CLIENT_TRAN_ID', // clientTranId is duplicated. Client tran id should be unique within 7 days
  -4118: 'REDUCE_ONLY_MARGIN_CHECK_FAILED', // ReduceOnly Order Failed. Please check your existing position and orders
  -4131: 'MARKET_ORDER_REJECT', // The counterparty's best price does not meet the PERCENT_PRICE filter limit
  -4135: 'INVALID_ACTIVATION_PRICE', // Invalid activation price
  -4137: 'QUANTITY_EXISTS_WITH_CLOSE_POSITION', // Quantity must be zero with closePosition equals true
  -4138: 'REDUCE_ONLY_MUST_BE_TRUE', // Reduce only must be true with closePosition equals true
  -4139: 'ORDER_TYPE_CANNOT_BE_MKT', // Order type can not be market if it's unable to cancel
  -4140: 'INVALID_OPENING_POSITION_STATUS', // Invalid symbol status for opening position
  -4141: 'SYMBOL_ALREADY_CLOSED', // Symbol is closed
  -4142: 'STRATEGY_INVALID_TRIGGER_PRICE', // REJECT: take profit or stop order will be triggered immediately
  -4144: 'INVALID_PAIR', // Invalid pair
  -4161: 'ISOLATED_LEVERAGE_REJECT_WITH_POSITION', // Leverage reduction is not supported with open positions
  -4164: 'MIN_NOTIONAL', // Order's notional must be no smaller than 5.0 (unless you choose reduce only).
  -4165: 'INVALID_TIME_INTERVAL', // Invalid time interval. Maximum time interval is %s days
  -4183: 'PRICE_HIGHTER_THAN_STOP_MULTIPLIER_UP', // Price is higher than stop price multiplier cap.
  -4184: 'PRICE_LOWER_THAN_STOP_MULTIPLIER_DOWN', // Price is lower than stop price multiplier floor.
  /// 5XXX -
  -5001: 'ASSET_DRIBBLET_CONVERT_SWITCH_OFF', // Don't allow transfer to micro assets.
  -5002: 'ASSET_ASSET_NOT_ENOUGH', // You have insufficient balance.
  -5003: 'ASSET_USER_HAVE_NO_ASSET', // You don't have this asset.
  -5004: 'USER_OUT_OF_TRANSFER_FLOAT', // The residual balances have exceeded 0.001BTC, Please re-choose.
  -5005: 'USER_ASSET_AMOUNT_IS_TOO_LOW', // The residual balances of the BTC is too low, Please re-choose.
  -5006: 'USER_CAN_NOT_REQUEST_IN_24_HOURS', // Only transfer once in 24 hours.
  -5007: 'AMOUNT_OVER_ZERO', // Quantity must be greater than zero.
  -5008: 'ASSET_WITHDRAW_WITHDRAWING_NOT_ENOUGH', // Insufficient amount of returnable assets.
  -5009: 'PRODUCT_NOT_EXIST', // Product does not exist.
  -5010: 'TRANSFER_FAIL', // Asset transfer fail.
  -5011: 'FUTURE_ACCT_NOT_EXIST', // future account not exists.
  -5012: 'TRANSFER_PENDING', // Asset transfer is in pending.
  -5021: 'PARENT_SUB_HAVE_NO_RELATION', // This parent sub have no relation
  -5022: 'FUTURE_ACCT_OR_SUBRELATION_NOT_EXIST', // future account or sub relation not exists.
  /// 6XXX - Savings Issues
  -6001: 'DAILY_PRODUCT_NOT_EXIST', // Daily product not exists.
  -6003: 'DAILY_PRODUCT_NOT_ACCESSIBLE', // Product not exist or you don't have permission
  -6004: 'DAILY_PRODUCT_NOT_PURCHASABLE', // Product not in purchase status
  -6005: 'DAILY_LOWER_THAN_MIN_PURCHASE_LIMIT', // Smaller than min purchase limit
  -6006: 'DAILY_REDEEM_AMOUNT_ERROR', // Redeem amount error
  -6007: 'DAILY_REDEEM_TIME_ERROR', // Not in redeem time
  -6008: 'DAILY_PRODUCT_NOT_REDEEMABLE', // Product not in redeem status
  -6009: 'REQUEST_FREQUENCY_TOO_HIGH', // Request frequency too high
  -6011: 'EXCEEDED_USER_PURCHASE_LIMIT', // Exceeding the maximum num allowed to purchase per user
  -6012: 'BALANCE_NOT_ENOUGH', // Balance not enough
  -6013: 'PURCHASING_FAILED', // Purchasing failed
  -6014: 'UPDATE_FAILED', // Exceed up-limit allowed to purchased
  -6015: 'EMPTY_REQUEST_BODY', // Empty request body
  -6016: 'PARAMS_ERR', // Parameter err
  -6017: 'NOT_IN_WHITELIST', // Not in whitelist
  -6018: 'ASSET_NOT_ENOUGH', // Asset not enough
  -6019: 'PENDING', // Need confirm
  -6020: 'PROJECT_NOT_EXISTS', // Project not exists
  /// 70XX - Futures
  -7001: 'FUTURES_BAD_DATE_RANGE', // Date range is not supported.
  -7002: 'FUTURES_BAD_TYPE', // Data request type is not supported.
};
