// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RIBs
import RxCocoa
import RxSwift

enum LinkBankFlow {
    enum FailureReason: Error {
        case generic
    }

    enum Screen {
        case splash(data: BankLinkageData)
        case yodlee(data: BankLinkageData)
        case failure(FailureReason)
    }

    enum Action: Equatable {
        case load
        case retry
    }
}

protocol LinkBankFlowRootRouting: Routing {
    func route(to screen: LinkBankFlow.Screen)
    func closeFailureScreen()
    func closeFlow(isInteractive: Bool)
    func returnToSplashScreen()
}

final class LinkBankFlowRootInteractor: Interactor,
    LinkBankFlowRootInteractable
{

    // MARK: - Properties

    let linkBankFlowEffect: Observable<LinkBankFlowEffect>
    weak var router: LinkBankFlowRootRouting?

    // MARK: - Private Properties

    private let bankFlowEffectRelay = PublishRelay<LinkBankFlowEffect>()
    internal let retryAction = PublishRelay<LinkBankFlow.Action>()
    private let supportedParters: Set<BankLinkageData.Partner> = [.yodlee]

    // MARK: - Injected

    private let linkedBankService: LinkedBanksServiceAPI
    private let loadingViewPresenter: LoadingViewPresenting
    private let beneficiariesService: BeneficiariesServiceAPI

    init(
        linkedBankService: LinkedBanksServiceAPI = resolve(),
        loadingViewPresenter: LoadingViewPresenting = resolve(),
        beneficiariesService: BeneficiariesServiceAPI = resolve()
    ) {
        self.linkedBankService = linkedBankService
        self.loadingViewPresenter = loadingViewPresenter
        self.beneficiariesService = beneficiariesService
        linkBankFlowEffect = bankFlowEffectRelay
            .asObservable()
            .share(replay: 1, scope: .whileConnected)
        super.init()
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        let loadAction = Observable<LinkBankFlow.Action>.just(.load)
        let retryAction = self.retryAction
            .asObservable()
            .share(replay: 1, scope: .whileConnected)

        Observable.merge(loadAction, retryAction)
            .flatMapLatest { [linkedBankService, loadingViewPresenter] _ -> Single<Result<BankLinkageData?, BankLinkageError>> in
                linkedBankService.bankLinkageStartup
                    .handleLoaderForLifecycle(loader: loadingViewPresenter, style: .circle)
                    .catchErrorJustReturn(.failure(.generic))
            }
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: handleInitialRouting)
            .disposeOnDeactivate(interactor: self)

        // Refresh the underlying value of BeneficiariesService once we've linked a bank
        linkBankFlowEffect
            .filter { $0 == .bankLinked }
            .flatMap { [beneficiariesService] _ -> Single<LinkBankFlowEffect> in
                beneficiariesService.fetch()
                    .take(1)
                    .asSingle()
                    .map { _ in LinkBankFlowEffect.bankLinked }
            }
            .subscribe()
            .disposeOnDeactivate(interactor: self)

        retryAction
            .subscribe(onNext: { [weak router] _ in
                router?.closeFailureScreen()
            })
            .disposeOnDeactivate(interactor: self)
    }

    func route(to screen: LinkBankFlow.Screen) {
        router?.route(to: screen)
    }

    func closeFlow(isInteractive: Bool) {
        bankFlowEffectRelay.accept(.closeFlow(isInteractive))
    }

    func returnToSplashScreen() {
        router?.returnToSplashScreen()
    }

    func updateBankLinked() {
        bankFlowEffectRelay.accept(.bankLinked)
    }

    // MARK: - Private

    private func handleInitialRouting(with result: Result<BankLinkageData?, BankLinkageError>) {
        switch result {
        case .success(let data):
            guard let data = data else {
                router?.route(to: .failure(.generic))
                return
            }
            guard supportedParters.contains(data.partner) else {
                router?.route(to: .failure(.generic))
                return
            }
            router?.route(to: .splash(data: data))
        case .failure:
            router?.route(to: .failure(.generic))
        }
    }
}
