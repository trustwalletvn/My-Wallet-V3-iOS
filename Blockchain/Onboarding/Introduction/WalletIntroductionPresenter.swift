// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureSettingsDomain
import Foundation
import NetworkKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

// A `Presentation` event that is built from a `WalletIntroductionEventType`
// and consumed by a `UIViewController`
enum WalletIntroductionPresentationEvent {
    case showPulse(WalletIntroductionPulseViewModel)
    case presentSheet(IntroductionSheetViewModel)
    case introductionComplete
}

/// `WalletIntroductionPresenter` is used on the `TabViewController`.
@objc
final class WalletIntroductionPresenter: NSObject {

    /// Returns a `WalletIntroductionPresentationEvent` that the `UIViewController` can respond to.
    var introductionEvent: Driver<WalletIntroductionPresentationEvent> {
        introductionRelay
            .map {
                switch $0 {
                case .pulse(let model):
                    return .showPulse(model)
                case .sheet(let model):
                    return .presentSheet(model)
                case .none:
                    return .introductionComplete
                }
            }
            .asDriver(onErrorJustReturn: .introductionComplete)
    }

    // The current introduction sequence.
    private var introductionSequence = WalletIntroductionSequence()

    private let interactor: WalletIntroductionInteractor
    private let recorder: AnalyticsEventRecorderAPI
    private let screen: WalletIntroductionLocation.Screen
    private let onboardingSettings: OnboardingSettings
    private let tabControllerProvider: TabControllerManagerProvider
    private let drawerRouter: DrawerRouting
    private let introductionRelay = PublishRelay<WalletIntroductionEventType>()
    private let disposeBag = DisposeBag()

    init(
        onboardingSettings: OnboardingSettings = resolve(),
        screen: WalletIntroductionLocation.Screen,
        recorder: AnalyticsEventRecorderAPI = resolve(),
        tabControllerProvider: TabControllerManagerProvider = resolve(),
        drawerRouter: DrawerRouting = resolve()
    ) {
        self.onboardingSettings = onboardingSettings
        self.screen = screen
        interactor = WalletIntroductionInteractor(onboardingSettings: onboardingSettings, screen: screen)
        self.recorder = recorder
        self.tabControllerProvider = tabControllerProvider
        self.drawerRouter = drawerRouter
    }

    func start() {
        interactor.startingLocation
            .map { [weak self] location -> [WalletIntroductionEvent] in
                self?.startingWithLocation(location) ?? []
            }
            .subscribe(onSuccess: { [weak self] events in
                guard let self = self else { return }
                self.execute(events: events)
            }, onError: { [weak self] _ in
                guard let self = self else { return }
                self.introductionRelay.accept(.none)
            })
            .disposed(by: disposeBag)
    }

    private func triggerNextStep() {
        guard let next = introductionSequence.next() else { return }
        /// We track all introduction events that have an analyticsKey.
        /// This happens on presentation.
        if let trackable = next as? WalletIntroductionAnalyticsEvent {
            recorder.record(event: trackable.eventType)
        }
        introductionRelay.accept(next.type)
    }

    private func execute(events: [WalletIntroductionEvent]) {
        introductionSequence.reset(to: events)
        triggerNextStep()
    }

    private func startingWithLocation(_ location: WalletIntroductionLocation) -> [WalletIntroductionEvent] {
        let screen = location.screen
        let position = location.position
        guard screen == .dashboard else { return [] }
        switch position {
        case .home:
            return homeEvents() + sendEvents() + requestEvents() + swapEvents()
        case .send:
            return sendEvents() + requestEvents() + swapEvents()
        case .receive:
            return requestEvents() + swapEvents()
        case .swap:
            return swapEvents()
        }
    }

    // MARK: `[WalletIntroductionEvent]`

    private func homeEvents() -> [WalletIntroductionEvent] {
        [home, homeDescription]
    }

    private func sendEvents() -> [WalletIntroductionEvent] {
        [send, sendDescription]
    }

    private func requestEvents() -> [WalletIntroductionEvent] {
        [request, requestDescription]
    }

    private func swapEvents() -> [WalletIntroductionEvent] {
        [swap, swapDescription]
    }
}

extension WalletIntroductionPresenter {
    private var home: HomeWalletIntroductionEvent {
        HomeWalletIntroductionEvent(selection: { [weak self] in
            guard let self = self else { return }
            self.tabControllerProvider.tabControllerManager?.showDashboard()
            self.triggerNextStep()
        })
    }

    private var homeDescription: HomeDescriptionWalletIntroductionEvent {
        HomeDescriptionWalletIntroductionEvent(selection: triggerNextStep)
    }

    private var send: SendWalletIntroductionEvent {
        SendWalletIntroductionEvent(selection: { [weak self] in
            guard let self = self else { return }
            self.tabControllerProvider.tabControllerManager?.showSend()
            self.triggerNextStep()
        })
    }

    private var sendDescription: SendDescriptionIntroductionEvent {
        SendDescriptionIntroductionEvent(selection: triggerNextStep)
    }

    private var request: RequestWalletIntroductionEvent {
        RequestWalletIntroductionEvent(selection: { [weak self] in
            guard let self = self else { return }
            self.tabControllerProvider.tabControllerManager?.showReceive()
            self.triggerNextStep()
        })
    }

    private var requestDescription: RequestDescriptionIntroductionEvent {
        RequestDescriptionIntroductionEvent(selection: triggerNextStep)
    }

    private var swap: SwapWalletIntroductionEvent {
        SwapWalletIntroductionEvent(selection: { [weak self] in
            guard let self = self else { return }
            self.tabControllerProvider.tabControllerManager?.showSwap()
            self.triggerNextStep()
        })
    }

    private var swapDescription: SwapDescriptionIntroductionEvent {
        SwapDescriptionIntroductionEvent(selection: { [weak self] in
            guard let self = self else { return }
            self.triggerNextStep()
            self.drawerRouter.toggleSideMenu()
        })
    }
}
