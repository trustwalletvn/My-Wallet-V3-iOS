// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RIBs
import RxCocoa
import RxSwift

final class PendingCardStatusPresenter: RibBridgePresenter, PendingStatePresenterAPI {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.PendingCardStatusScreen

    // MARK: - Properties

    var tap: Observable<URL> {
        viewModelRelay
            .asObservable()
            .compactMap { $0 }
            .flatMap(\.tap)
    }

    var viewModel: Driver<PendingStateViewModel> {
        viewModelRelay
            .asDriver()
            .compactMap { $0 }
    }

    private let viewModelRelay = BehaviorRelay<PendingStateViewModel?>(value: nil)
    private let interactor: PendingCardStatusInteractor
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(interactor: PendingCardStatusInteractor) {
        self.interactor = interactor
        super.init(interactable: interactor)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModelRelay.accept(
            PendingStateViewModel(
                compositeStatusViewType: .loader,
                title: LocalizedString.LoadingScreen.title,
                subtitle: LocalizedString.LoadingScreen.subtitle
            )
        )

        interactor.startPolling()
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] state in
                    self?.handle(state: state)
                },
                onError: { [weak self] _ in
                    self?.handle(state: .inactive)
                }
            )
            .disposed(by: disposeBag)
    }

    private func handle(state: PendingCardStatusInteractor.State) {
        switch state {
        case .active(let cardData):
            interactor.endWithConfirmation(with: cardData)
        case .inactive:
            let button = ButtonViewModel.primary(with: LocalizationConstants.ErrorScreen.button)
            button.tapRelay
                .bindAndCatch(weak: self) { (self) in
                    self.interactor.endWithoutConfirmation()
                }
                .disposed(by: disposeBag)
            let viewModel = PendingStateViewModel(
                compositeStatusViewType: .image(PendingStateViewModel.Image.circleError.imageResource),
                title: LocalizationConstants.ErrorScreen.title,
                subtitle: LocalizationConstants.ErrorScreen.subtitle,
                button: button
            )
            viewModelRelay.accept(viewModel)
        case .timeout:
            let button = ButtonViewModel.primary(with: LocalizationConstants.ErrorScreen.button)
            button.tapRelay
                .bindAndCatch(weak: self) { (self) in
                    self.interactor.endWithoutConfirmation()
                }
                .disposed(by: disposeBag)
            let viewModel = PendingStateViewModel(
                compositeStatusViewType: .image(PendingStateViewModel.Image.circleError.imageResource),
                title: LocalizationConstants.ErrorScreen.title,
                subtitle: LocalizationConstants.ErrorScreen.subtitle,
                button: button
            )
            viewModelRelay.accept(viewModel)
        }
    }
}
