// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

public protocol CryptoAccount: SingleAccount {
    var asset: CryptoCurrency { get }
}

extension CryptoAccount {
    public var currencyType: CurrencyType {
        asset.currency
    }
}
