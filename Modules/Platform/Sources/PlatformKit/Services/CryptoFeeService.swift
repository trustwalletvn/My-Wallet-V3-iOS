// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import NetworkKit
import RxSwift
import ToolKit

public final class CryptoFeeService<FeeType: TransactionFee & Decodable>: CryptoFeeServiceAPI {

    // MARK: - CryptoFeeServiceAPI

    public var fees: Single<FeeType> {
        client.fees
            .do(onError: { error in
                Logger.shared.error(error)
            })
            .catchErrorJustReturn(FeeType.default)
    }

    // MARK: - Private Properties

    private let client: CryptoFeeClient<FeeType>

    // MARK: - Init

    init(client: CryptoFeeClient<FeeType>) {
        self.client = client
    }

    public convenience init() {
        self.init(client: CryptoFeeClient<FeeType>())
    }
}
