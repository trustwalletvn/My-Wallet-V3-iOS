// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformUIKit

protocol BuyFlowListening: AnyObject {
    func buyFlowDidComplete(with result: TransactionFlowResult)
    func presentKYCFlow(from viewController: UIViewController, completion: @escaping (Bool) -> Void)
}

final class BuyFlowListener: BuyFlowListening {

    var publisher: AnyPublisher<TransactionFlowResult, Never> {
        subject.eraseToAnyPublisher()
    }

    private let subject = PassthroughSubject<TransactionFlowResult, Never>()
    private var cancellables = Set<AnyCancellable>()

    private let kycRouter: PlatformUIKit.KYCRouting
    private let alertViewPresenter: PlatformUIKit.AlertViewPresenterAPI
    private let loadingViewPresenter: PlatformUIKit.LoadingViewPresenter

    init(
        kycRouter: PlatformUIKit.KYCRouting = resolve(),
        alertViewPresenter: PlatformUIKit.AlertViewPresenterAPI = resolve(),
        loadingViewPresenter: PlatformUIKit.LoadingViewPresenter = resolve()
    ) {
        self.kycRouter = kycRouter
        self.alertViewPresenter = alertViewPresenter
        self.loadingViewPresenter = loadingViewPresenter
    }

    deinit {
        subject.send(completion: .finished)
    }

    func buyFlowDidComplete(with result: TransactionFlowResult) {
        subject.send(result)
    }

    func presentKYCFlow(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        loadingViewPresenter.show(with: .circle)
        // Buy requires Tier 1 for SDD users, Tier 2 for everyone else. Requiring Tier 1 will ensure the SDD check is done.
        kycRouter.presentEmailVerificationAndKYCIfNeeded(from: viewController, requiredTier: .tier1)
            .receive(on: DispatchQueue.main)
            .sink { [alertViewPresenter, loadingViewPresenter] completionResult in
                loadingViewPresenter.hide()
                guard case .failure(let error) = completionResult else {
                    return
                }
                alertViewPresenter.error(
                    in: viewController,
                    message: String(describing: error),
                    action: nil
                )
            } receiveValue: { result in
                completion(result == .completed)
            }
            .store(in: &cancellables)
    }
}
