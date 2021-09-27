// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit
import UserNotifications

final class RemoteNotificationAuthorizer {

    // MARK: - Types

    /// Any potential error that may be risen during authrorization request
    enum ServiceError: Error {

        /// Any system error
        case system(Error)

        /// End-user has not granted
        case permissionDenied

        /// Thrown if the authorization status should be `.authorized` but it's not
        case unauthorizedStatus

        /// Authrization was already granted / refused
        case statusWasAlreadyDetermined
    }

    // MARK: - Private Properties

    private let application: UIApplicationRemoteNotificationsAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let userNotificationCenter: UNUserNotificationCenterAPI
    private let options: UNAuthorizationOptions

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        application: UIApplicationRemoteNotificationsAPI = UIApplication.shared,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        userNotificationCenter: UNUserNotificationCenterAPI = UNUserNotificationCenter.current(),
        options: UNAuthorizationOptions = [.alert, .badge, .sound]
    ) {
        self.application = application
        self.analyticsRecorder = analyticsRecorder
        self.userNotificationCenter = userNotificationCenter
        self.options = options
    }

    // MARK: - Private Accessors

    private func requestAuthorization() -> Single<Void> {
        Single
            .create(weak: self) { (self, observer) -> Disposable in
                self.analyticsRecorder.record(event: AnalyticsEvents.Permission.permissionSysNotifRequest)
                self.userNotificationCenter.requestAuthorization(options: self.options) { [weak self] isGranted, error in
                    guard let self = self else { return }
                    guard error == nil else {
                        observer(.error(ServiceError.system(error!)))
                        return
                    }
                    guard isGranted else {
                        self.analyticsRecorder.record(event: AnalyticsEvents.Permission.permissionSysNotifDecline)
                        observer(.error(ServiceError.permissionDenied))
                        return
                    }
                    self.analyticsRecorder.record(event: AnalyticsEvents.Permission.permissionSysNotifApprove)
                    observer(.success(()))
                }
                return Disposables.create()
            }
    }

    private var isNotDetermined: Single<Bool> {
        status.map { $0 == .notDetermined }
    }
}

// MARK: - RemoteNotificationAuthorizationStatusProviding

extension RemoteNotificationAuthorizer: RemoteNotificationAuthorizationStatusProviding {
    var status: Single<UNAuthorizationStatus> {
        Single<UNAuthorizationStatus>
            .create(weak: self) { (self, observer) -> Disposable in
                self.userNotificationCenter.getAuthorizationStatus(completionHandler: { status in
                    observer(.success(status))
                })
                return Disposables.create()
            }
    }
}

// MARK: - RemoteNotificationRegistering

extension RemoteNotificationAuthorizer: RemoteNotificationRegistering {
    func registerForRemoteNotificationsIfAuthorized() -> Single<Void> {
        isAuthorized
            .map { isAuthorized -> Void in
                guard isAuthorized else {
                    throw ServiceError.unauthorizedStatus
                }
                return ()
            }
            .observeOn(MainScheduler.instance)
            .do(
                onSuccess: { [unowned application] _ in
                    application.registerForRemoteNotifications()
                },
                onError: { error in
                    Logger.shared.error("Token registration failed with error: \(String(describing: error))")
                }
            )
    }
}

// MARK: - RemoteNotificationAuthorizing

extension RemoteNotificationAuthorizer: RemoteNotificationAuthorizationRequesting {
    // TODO: Handle a `.denied` case
    func requestAuthorizationIfNeeded() -> Single<Void> {
        isNotDetermined
            .map { isNotDetermined -> Void in
                guard isNotDetermined else {
                    throw ServiceError.statusWasAlreadyDetermined
                }
                return ()
            }
            .observeOn(MainScheduler.instance)
            .flatMap(weak: self) { (self, _) -> Single<Void> in
                self.requestAuthorization()
            }
            .observeOn(MainScheduler.instance)
            .do(
                onSuccess: { [unowned application] _ in
                    application.registerForRemoteNotifications()
                },
                onError: { error in
                    Logger.shared.error("Remote notification authorization failed with error: \(error)")
                }
            )
    }

    func requestAuthorizationIfNeededPublisher() -> AnyPublisher<Never, Error> {
        requestAuthorizationIfNeeded()
            .asCompletable()
            .asPublisher()
    }
}
