// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import RxSwift

public protocol OrderCreationServiceAPI: AnyObject {
    func create(using candidateOrderDetails: CandidateOrderDetails) -> Single<CheckoutData>
}

final class OrderCreationService: OrderCreationServiceAPI {

    // MARK: - Service Error

    enum ServiceError: Error {
        case mappingError
    }

    // MARK: - Properties

    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let client: OrderCreationClientAPI
    private let pendingOrderDetailsService: PendingOrderDetailsServiceAPI

    // MARK: - Setup

    init(
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        client: OrderCreationClientAPI = resolve(),
        pendingOrderDetailsService: PendingOrderDetailsServiceAPI = resolve()
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.client = client
        self.pendingOrderDetailsService = pendingOrderDetailsService
    }

    // MARK: - API

    func create(using candidateOrderDetails: CandidateOrderDetails) -> Single<CheckoutData> {
        let data = OrderPayload.Request(
            action: candidateOrderDetails.action,
            fiatValue: candidateOrderDetails.fiatValue,
            fiatCurrency: candidateOrderDetails.fiatCurrency,
            cryptoValue: candidateOrderDetails.cryptoValue,
            paymentType: candidateOrderDetails.paymentMethod?.method,
            paymentMethodId: candidateOrderDetails.paymentMethodId
        )
        let creation = client
            .create(
                order: data,
                createPendingOrder: true
            )
            .map(weak: self) { (self, response) in
                OrderDetails(recorder: self.analyticsRecorder, response: response)
            }
            .map { details -> OrderDetails in
                guard let details = details else {
                    throw ServiceError.mappingError
                }
                return details
            }
            .map { CheckoutData(order: $0) }

        return pendingOrderDetailsService
            .cancel()
            .andThen(creation)
    }
}
