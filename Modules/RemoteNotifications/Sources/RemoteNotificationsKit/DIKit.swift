// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    // MARK: - RemoteNotificationsKit Module

    public static var remoteNotificationsKit = module {

        factory { RemoteNotificationAuthorizer() as RemoteNotificationAuthorizing }

        factory { RemoteNotificationNetworkService() as RemoteNotificationNetworkServicing }

        factory { RemoteNotificationService() as RemoteNotificationServicing }

        single { RemoteNotificationServiceContainer() as RemoteNotificationServiceContaining }
    }
}
