// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

enum TermsUrlLink {
    static let gbp = "https://exchange.blockchain.com/legal#modulr"
}

final class BankTransferDetailScreenInteractor {

    // MARK: - Exposed Properties

    let checkoutData: CheckoutData

    // MARK: - Private Properties

    private let cancellationService: OrderCancellationServiceAPI

    // MARK: - Setup

    init(
        checkoutData: CheckoutData,
        cancellationService: OrderCancellationServiceAPI = resolve()
    ) {
        self.checkoutData = checkoutData
        self.cancellationService = cancellationService
    }

    // MARK: - Exposed Methods

    func cancel() -> Observable<Void> {
        cancellationService
            .cancel(order: checkoutData.order.identifier)
            .andThen(.just(()))
    }
}
