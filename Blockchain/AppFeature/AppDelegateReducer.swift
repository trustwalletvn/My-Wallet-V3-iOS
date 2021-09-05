// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
import DebugUIKit
import DIKit
import NetworkKit
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import SettingsKit
import ToolKit
import UIKit

typealias AppDelegateEffect = Effect<AppDelegateAction, Never>

/// Used to cancel the background task if needed
struct BackgroundTaskId: Hashable {}

/// The actions to be performed by the AppDelegate
public enum AppDelegateAction: Equatable {
    case didFinishLaunching(window: UIWindow)
    case willResignActive
    case willEnterForeground(_ application: UIApplication)
    case didEnterBackground(_ application: UIApplication)
    case handleDelayedEnterBackground
    case didBecomeActive
    case open(_ url: URL)
    case userActivity(_ userActivity: NSUserActivity)
    case didRegisterForRemoteNotifications(Result<Data, NSError>)
    case didReceiveRemoteNotification(
        _ application: UIApplication,
        userInfo: [AnyHashable: Any],
        completionHandler: (UIBackgroundFetchResult) -> Void
    )
}

extension AppDelegateAction {
    public static func == (lhs: AppDelegateAction, rhs: AppDelegateAction) -> Bool {
        switch (lhs, rhs) {
        case (.didReceiveRemoteNotification, .didReceiveRemoteNotification):
            // since we can't compare the userInfo
            // we'll always assume the notifications are different
            return false
        default:
            return lhs == rhs
        }
    }
}

/// Holds the dependencies
struct AppDelegateEnvironment {
    var appSettings: BlockchainSettings.App
    var onboardingSettings: OnboardingSettings
    var cacheSuite: CacheSuite
    var remoteNotificationBackgroundReceiver: RemoteNotificationBackgroundReceiving
    var remoteNotificationAuthorizer: RemoteNotificationRegistering
    var remoteNotificationTokenReceiver: RemoteNotificationDeviceTokenReceiving
    var certificatePinner: CertificatePinnerAPI
    var siftService: SiftServiceAPI
    var blurEffectHandler: BlurVisualEffectHandler
    var backgroundAppHandler: BackgroundAppHandlerAPI
    var supportedAssetsRemoteService: SupportedAssetsRemoteServiceAPI
}

/// The state of the app delegate
struct AppDelegateState: Equatable {
    var window: UIWindow?
    /// `true` if a user activity was handled, such as universal links, otherwise `false`
    var userActivityHandled: Bool = false
    /// `true` if a deep link was handled, otherwise `false`
    var urlHandled: Bool = false
}

/// The reducer of the app delegate that describes the effects for each action.
let appDelegateReducer = Reducer<
    AppDelegateState, AppDelegateAction, AppDelegateEnvironment
> { state, action, environment in
    switch action {
    case .didFinishLaunching(let window):
        state.window = window
        return .merge(
            environment.supportedAssetsRemoteService
                .refreshCustodialAssetsCache()
                .eraseToEffect()
                .fireAndForget(),

            environment.remoteNotificationAuthorizer
                .registerForRemoteNotificationsIfAuthorized()
                .asPublisher()
                .eraseToEffect()
                .fireAndForget(),

            applyGlobalNavigationAppearance(using: .lightContent()),

            applyCertificatePinning(using: environment.certificatePinner),

            enableSift(using: environment.siftService)
        )
    case .willResignActive:
        return applyBlurFilter(
            handler: environment.blurEffectHandler,
            on: state.window
        )
    case .willEnterForeground(let application):
        return .merge(
            .cancel(id: BackgroundTaskId()),
            environment.backgroundAppHandler
                .appEnteredForeground(application)
                .eraseToEffect()
                .fireAndForget()
        )
    case .didEnterBackground(let application):
        return environment.backgroundAppHandler
            .appEnteredBackground(application)
            .eraseToEffect()
            .cancellable(id: BackgroundTaskId(), cancelInFlight: true)
            .map { _ in .handleDelayedEnterBackground }
    case .handleDelayedEnterBackground:
        return .cancel(id: BackgroundTaskId())
    case .didBecomeActive:
        return .merge(
            removeBlurFilter(
                handler: environment.blurEffectHandler,
                from: state.window
            ),
            Effect.fireAndForget {
                Logger.shared.debug("applicationDidBecomeActive")
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        )
    case .open(let url):
        return .none
    case .didRegisterForRemoteNotifications(let result):
        return Effect.fireAndForget {
            switch result {
            case .success(let data):
                environment.remoteNotificationTokenReceiver
                    .appDidRegisterForRemoteNotifications(with: data)
            case .failure(let error):
                environment.remoteNotificationTokenReceiver
                    .appDidFailToRegisterForRemoteNotifications(with: error)
            }
        }
    case .didReceiveRemoteNotification(let application, let userInfo, let completionHandler):
        return .fireAndForget {
            environment.remoteNotificationBackgroundReceiver
                .didReceiveRemoteNotification(
                    userInfo,
                    onApplicationState: application.applicationState,
                    fetchCompletionHandler: completionHandler
                )
        }
    case .userActivity(let userActivity):
        return .none
    }
}

// MARK: - Effect Methods

private func applyBlurFilter(handler: BlurVisualEffectHandler, on window: UIWindow?) -> AppDelegateEffect {
    guard let view = window else {
        return .none
    }
    return Effect.fireAndForget {
        handler.applyEffect(on: view)
    }
}

private func removeBlurFilter(handler: BlurVisualEffectHandler, from window: UIWindow?) -> AppDelegateEffect {
    guard let view = window else {
        return .none
    }
    return Effect.fireAndForget {
        handler.removeEffect(from: view)
    }
}

private func applyCertificatePinning(using service: CertificatePinnerAPI) -> AppDelegateEffect {
    Effect.fireAndForget {
        service.pinCertificateIfNeeded()
    }
}

private func enableSift(using service: SiftServiceAPI) -> AppDelegateEffect {
    Effect.fireAndForget {
        service.enable()
    }
}

private func applyGlobalNavigationAppearance(using barStyle: Screen.Style.Bar) -> AppDelegateEffect {
    Effect.fireAndForget {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.isTranslucent = barStyle.isTranslucent
        navigationBarAppearance.titleTextAttributes = barStyle.titleTextAttributes
        navigationBarAppearance.barTintColor = barStyle.backgroundColor
        navigationBarAppearance.tintColor = barStyle.tintColor
    }
}
