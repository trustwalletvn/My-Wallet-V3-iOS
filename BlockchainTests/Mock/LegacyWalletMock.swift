// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import PlatformKit
import RxSwift

class LegacyWalletMock: LegacyWalletAPI {

    var password: String?

    func createOrderPayment(
        orderTransaction: OrderTransactionLegacy,
        completion: @escaping (Result<[AnyHashable : Any], Wallet.CreateOrderError>) -> Void
    ) {
        completion(.success([:]))
    }

    func sendOrderTransaction(
        _ legacyAssetType: LegacyAssetType,
        secondPassword: String?,
        completion: @escaping (Result<String, Wallet.SendOrderError>) -> Void
    ) {
        completion(.success(""))
    }

    func needsSecondPassword() -> Bool {
        false
    }

    func getReceiveAddress(forAccount account: Int32, assetType: LegacyAssetType) -> String! {
        ""
    }

    func updateAccountLabel(_ cryptoCurrency: CryptoCurrency, index: Int, label: String) -> Completable {
        .empty()
    }

    func signPayment(secondPassword: String?, success: @escaping (String, Int) -> Void, error: @escaping (String) -> Void) {
    }
}
