// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureAuthenticationDomain

extension DependencyContainer {

    // MARK: - FeatureAuthenticationData Module

    public static var featureAuthenticationData = module {

        // MARK: - NetworkClients

        factory { AutoWalletPairingClient() as AutoWalletPairingClientAPI }

        factory { GuidClient() as GuidClientAPI }

        factory { SMSClient() as SMSClientAPI }

        factory { SessionTokenClient() as SessionTokenClientAPI }

        factory { TwoFAWalletClient() as TwoFAWalletClientAPI }

        factory { DeviceVerificationClient() as DeviceVerificationClientAPI }

        factory { WalletPayloadClient() as WalletPayloadClientAPI }

        // MARK: - Repositories

        factory { DeviceVerificationRepository() as DeviceVerificationRepositoryAPI }

        factory { RemoteSessionTokenRepository() as RemoteSessionTokenRepositoryAPI }
    }
}
