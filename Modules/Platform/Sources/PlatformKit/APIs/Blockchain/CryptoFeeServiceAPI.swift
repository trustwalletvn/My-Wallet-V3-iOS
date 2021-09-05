// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift

public protocol CryptoFeeServiceAPI {
    associatedtype FeeType: TransactionFee & Decodable

    /// This pulls from a Blockchain.info endpoint that serves up
    /// current <Crypto> transaction fees. We use this in order to inject a `fee` value
    /// into the JS. Only `Swap` uses priority fees.
    var fees: Single<FeeType> { get }
}

public struct AnyCryptoFeeService<FeeType: TransactionFee & Decodable>: CryptoFeeServiceAPI {

    private let _fees: () -> Single<FeeType>
    public var fees: Single<FeeType> {
        _fees()
    }

    public init<API: CryptoFeeServiceAPI>(service: API) where API.FeeType == FeeType {
        _fees = { service.fees }
    }
}
