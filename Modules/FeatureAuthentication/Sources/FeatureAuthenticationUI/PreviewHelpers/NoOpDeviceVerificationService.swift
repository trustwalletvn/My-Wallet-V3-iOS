// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import Foundation
import ToolKit

/// Intend for SwiftUI Previews and only available in DEBUG
final class NoOpDeviceVerificationService: DeviceVerificationServiceAPI {

    func authorizeLogin(emailCode: String) -> AnyPublisher<Void, DeviceVerificationServiceError> {
        Deferred {
            Future { _ in
                // no-op
            }
        }
        .eraseToAnyPublisher()
    }

    func sendDeviceVerificationEmail(
        to emailAddress: String
    ) -> AnyPublisher<Void, DeviceVerificationServiceError> {
        Deferred {
            Future { _ in
                // no-op
            }
        }
        .eraseToAnyPublisher()
    }

    func extractWalletInfoFromDeeplink(url deeplink: URL) -> AnyPublisher<WalletInfo, WalletInfoError> {
        Deferred {
            Future { _ in
                // no-op
            }
        }
        .eraseToAnyPublisher()
    }
}

final class NoOpInternalFeatureFlagService: InternalFeatureFlagServiceAPI {
    func isEnabled(_ feature: InternalFeature) -> Bool {
        true
    }

    func enable(_ feature: InternalFeature) {}

    func enable(_ features: [InternalFeature]) {}

    func disable(_ feature: InternalFeature) {}
}
