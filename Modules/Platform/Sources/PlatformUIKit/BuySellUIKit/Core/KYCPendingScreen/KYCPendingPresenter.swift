// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class KYCPendingPresenter: RibBridgePresenter, PendingStatePresenterAPI {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.SimpleBuy.KYCScreen
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.KYCScreen
    private typealias AnalyticsEvent = AnalyticsEvents.SimpleBuy

    // MARK: - Properties

    let title = LocalizedString.title

    var tap: Observable<URL> {
        .empty()
    }

    var viewModel: Driver<PendingStateViewModel> {
        modelRelay.asDriver()
    }

    private let disposeBag = DisposeBag()
    private let interactor: KYCPendingInteractor
    private unowned let stateService: RoutingStateEmitterAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private var modelRelay: BehaviorRelay<PendingStateViewModel>!
    private var dismissControllerOnSuccess: () -> Void

    // MARK: - Setup

    init(
        stateService: RoutingStateEmitterAPI,
        interactor: KYCPendingInteractor,
        dismissControllerOnSuccess: @escaping () -> Void,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.stateService = stateService
        self.interactor = interactor
        self.dismissControllerOnSuccess = dismissControllerOnSuccess
        super.init(interactable: interactor)
        modelRelay = BehaviorRelay(value: model(verificationState: .loading))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        interactor
            .verificationState
            .takeWhile { $0 != .completed }
            .map(weak: self) { (self, state) in
                self.model(verificationState: state)
            }
            .bindAndCatch(to: modelRelay)
            .disposed(by: disposeBag)

        interactor.verificationState
            .map(\.analyticsEvent)
            .subscribe(onNext: analyticsRecorder.record(event:))
            .disposed(by: disposeBag)

        interactor
            .verificationState
            .filter { $0 == .completed }
            .mapToVoid()
            // in case the user gets approved we need to dismiss/pop the view controller
            .observeOn(MainScheduler.asyncInstance)
            .do(onNext: { [weak self] in self?.dismissControllerOnSuccess() })
            .bindAndCatch(to: stateService.nextRelay)
            .disposed(by: disposeBag)

        interactor.startPollingForGoldTier()
    }

    private func model(verificationState: KYCPendingVerificationState) -> PendingStateViewModel {
        func actionButton(title: String) -> ButtonViewModel {
            let button = ButtonViewModel.primary(with: title)
            button.tapRelay
                .bindAndCatch(to: stateService.previousRelay)
                .disposed(by: disposeBag)
            return button
        }

        switch verificationState {
        case .ineligible:
            return PendingStateViewModel(
                compositeStatusViewType: .image(PendingStateViewModel.Image.region.imageResource),
                title: LocalizedString.Ineligible.title,
                subtitle: LocalizedString.Ineligible.subtitle,
                button: actionButton(title: LocalizedString.Ineligible.button)
            )
        case .completed,
             .loading:
            return PendingStateViewModel(
                compositeStatusViewType: .loader,
                title: LocalizedString.Verifying.title,
                subtitle: LocalizedString.Verifying.subtitle,
                button: actionButton(title: LocalizedString.button)
            )
        case .manualReview:
            return PendingStateViewModel(
                compositeStatusViewType: .image(PendingStateViewModel.Image.triangleError.imageResource),
                title: LocalizedString.ManualReview.title,
                subtitle: LocalizedString.ManualReview.subtitle,
                button: actionButton(title: LocalizedString.button)
            )
        case .pending:
            return PendingStateViewModel(
                compositeStatusViewType: .image(PendingStateViewModel.Image.clock.imageResource),
                title: LocalizedString.PendingReview.title,
                subtitle: LocalizedString.PendingReview.subtitle,
                button: actionButton(title: LocalizedString.button)
            )
        }
    }
}
