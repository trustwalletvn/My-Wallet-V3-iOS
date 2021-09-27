// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureKYCDomain
import FeatureKYCUI
import RIBs
import RxSwift

protocol SwapBootstrapRouting: ViewableRouting {}

protocol SwapBootstrapPresentable: Presentable {
    func showLoading()
}

protocol SwapBootstrapListener: AnyObject {
    func userMustKYCForSwap()
    func userMustCompleteKYC(model: KYCTiersPageModel)
    func userReadyForSwap()
}

final class SwapBootstrapInteractor: PresentableInteractor<SwapBootstrapPresentable>, SwapBootstrapInteractable {

    // MARK: - Types

    private enum Action {
        case userMustKYCForSwap
        case userMustCompleteKYC(model: KYCTiersPageModel)
        case userReadyForSwap
        case kycCheckError
    }

    // MARK: - Internal Properties

    weak var router: SwapBootstrapRouting?
    weak var listener: SwapBootstrapListener?

    // MARK: - Private Properties

    private let kycStatusChecker: KYCStatusChecking
    private let kycTiersPageModelFactory: KYCTiersPageModelFactoryAPI

    // MARK: - Initializer

    init(
        presenter: SwapBootstrapPresentable,
        kycStatusChecker: KYCStatusChecking = resolve(),
        kycTiersPageModelFactory: KYCTiersPageModelFactoryAPI = resolve()
    ) {
        self.kycStatusChecker = kycStatusChecker
        self.kycTiersPageModelFactory = kycTiersPageModelFactory
        super.init(presenter: presenter)
    }

    // MARK: - Internal Methods

    override func didBecomeActive() {
        super.didBecomeActive()
        checkStatus()
    }

    // MARK: - Private Methods

    private func checkStatus() {
        kycStatusChecker.checkStatus(whileLoading: { [weak presenter] in
            presenter?.showLoading()
        })
            .flatMap(weak: self) { (self, status) -> Single<Action> in
                switch status {
                case .unverified:
                    return .just(.userMustKYCForSwap)
                case .verifying:
                    return self.kycTiersPageModelFactory
                        .tiersPageModel(suppressCTA: true)
                        .map { model -> Action in
                            .userMustCompleteKYC(model: model)
                        }
                        .observeOn(MainScheduler.asyncInstance)
                case .verified:
                    return .just(.userReadyForSwap)
                case .failed:
                    return .just(.kycCheckError)
                }
            }
            .subscribe(onSuccess: { [weak self] action in
                switch action {
                case .userMustKYCForSwap:
                    self?.listener?.userMustKYCForSwap()
                case .userMustCompleteKYC(let model):
                    self?.listener?.userMustCompleteKYC(model: model)
                case .userReadyForSwap:
                    self?.listener?.userReadyForSwap()
                case .kycCheckError:
                    break
                }
            })
            .disposeOnDeactivate(interactor: self)
    }
}
