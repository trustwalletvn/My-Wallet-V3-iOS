// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NetworkKit
import PhoneNumberKit
import PlatformKit
import RxSwift
import ToolKit

class KYCVerifyPhoneNumberInteractor {

    private let phoneNumberKit = PhoneNumberKit()
    private let mobileService: MobileSettingsServiceAPI
    private let walletSync: WalletNabuSynchronizerServiceAPI

    init(
        mobileService: MobileSettingsServiceAPI = resolve(),
        walletSync: WalletNabuSynchronizerServiceAPI = resolve()
    ) {
        self.mobileService = mobileService
        self.walletSync = walletSync
    }

    /// Starts the mobile verification process. This should be called when the
    /// user wishes to update their mobile phone number during the KYC flow.
    ///
    /// - Parameter number: the phone number
    /// - Returns: a Completable which completes if the phone number is success
    ///            was successfully updated, otherwise, it will emit an error.
    func startVerification(number: String) -> Completable {
        do {
            let phoneNumber = try phoneNumberKit.parse(number)
            let formattedPhoneNumber = phoneNumberKit.format(phoneNumber, toType: .e164)
            return mobileService.update(mobileNumber: formattedPhoneNumber)
        } catch {
            return .error(error)
        }
    }

    /// Verifies the mobile number entered by the user during the KYC flow.
    ///
    /// Upon successfully validating a user's mobile number, which is saved on the wallet
    /// settings, this function will then obtain a JWT for the user's wallet which is
    /// then sent to Nabu.
    ///
    /// - Parameters:
    ///   - code: the code sent to the mobile number
    /// - Returns: a Completable which completes if the verification process succeeds
    ///            otherwise, it will emit an error.
    func verifyNumber(with code: String) -> Completable {
        mobileService.verify(with: code)
            .andThen(updateWalletInfo())
    }

    private func updateWalletInfo() -> Completable {
        walletSync.sync().asSingle().asCompletable()
    }
}
