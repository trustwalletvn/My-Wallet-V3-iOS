// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RIBs
import RxRelay
import RxSwift
import ToolKit

final class KYCPendingInteractor: Interactor {

    // MARK: - Properties

    var verificationState: Observable<KYCPendingVerificationState> {
        verificationStateRelay.asObservable()
    }

    private let eligibilityService: EligibilityServiceAPI
    private let kycTiersService: KYCTierUpdatePollingServiceAPI
    private let eligiblePaymentMethodsService: PaymentMethodsServiceAPI
    private let disposeBag = DisposeBag()

    private let verificationStateRelay = BehaviorRelay<KYCPendingVerificationState>(value: .loading)

    // MARK: - Setup

    init(
        kycTiersService: KYCTierUpdatePollingServiceAPI = resolve(),
        eligibilityService: EligibilityServiceAPI = resolve(),
        eligiblePaymentMethodsService: PaymentMethodsServiceAPI = resolve()
    ) {
        self.kycTiersService = kycTiersService
        self.eligibilityService = eligibilityService
        self.eligiblePaymentMethodsService = eligiblePaymentMethodsService
    }

    func startPollingForGoldTier() {
        kycTiersService
            .poll(untilTier: .tier2, is: .approved, timeoutAfter: 30)
            .map(\.verificationState)
            .flatMap(weak: self) { (self, state) -> Single<KYCPendingVerificationState> in
                guard state == .completed else {
                    return .just(state)
                }
                return self.eligibilityService.fetch()
                    .map { $0 ? .completed : .ineligible }
            }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(
                onSuccess: { [weak self] newState in
                    self?.verificationStateRelay.accept(newState)
                    // ugly, I know, but we need to refresh the eligible payment methods
                    // once we have a verification state other than loading
                    if newState != .loading {
                        self?.eligiblePaymentMethodsService.refresh()
                    }
                },
                onError: { [weak verificationStateRelay] _ in
                    verificationStateRelay?.accept(.pending)
                }
            )
            .disposed(by: disposeBag)
    }
}

extension KYC.AccountStatus {
    fileprivate var verificationState: KYCPendingVerificationState {
        switch self {
        case .approved:
            return .completed
        case .failed:
            return .manualReview
        case .pending, .underReview:
            return .pending
        case .expired, .none:
            return .pending
        }
    }
}
