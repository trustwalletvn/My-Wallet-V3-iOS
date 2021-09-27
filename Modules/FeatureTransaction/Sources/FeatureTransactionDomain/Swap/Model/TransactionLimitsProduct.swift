// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public enum TransactionLimitsProduct {
    // TICKET: IOS-4657: Add a Simple Buy case 'case simpleBuy(BUY|SELL)'
    case swap(OrderDirection)
}
