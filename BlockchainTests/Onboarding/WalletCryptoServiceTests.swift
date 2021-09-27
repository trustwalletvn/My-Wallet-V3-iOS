// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import DIKit
import PlatformKit
import RxBlocking
import RxSwift
import ToolKit
import WalletPayloadKit
import XCTest

class MockRecorder: Recording {
    func record(_ message: String) {}
    func record() {}

    func error(_ error: Error) {}
    func error(_ errorMessage: String) {}
    func error() {}

    func recordIllegalUIOperationIfNeeded() {}
}

class WalletCryptoServiceTests: XCTestCase {

    var walletManager: WalletManager!
    var service: WalletCryptoServiceAPI!

    override func setUp() {
        super.setUp()
        // Force JS initialization before hand
        let container = modules {
            DependencyContainer.platformKit
            DependencyContainer.walletPayloadKit
            DependencyContainer.blockchain
        }
        let walletManager: WalletManager = container.resolve()
        _ = walletManager.fetchJSContext()
        let service: WalletCryptoServiceAPI = container.resolve()
        self.walletManager = walletManager
        self.service = service
    }

    func testDecryption() {
        let key = "keykeykeykeykey"
        let data = "datadatadatadatadata"
        let pbkdf2Iterations: Int = 100
        do {
            let encrypted = try service
                .encrypt(pair: KeyDataPair(key: key, data: data), pbkdf2Iterations: pbkdf2Iterations)
                .toBlocking()
                .first()
            guard let encryptedData = encrypted else {
                XCTFail("encryptedData is nil")
                return
            }
            let decryptedData = try service
                .decrypt(pair: KeyDataPair(key: key, data: encryptedData), pbkdf2Iterations: pbkdf2Iterations)
                .toBlocking()
                .first()
            XCTAssertEqual(data, decryptedData)
        } catch {
            XCTFail("Decryption failed with error: \(String(describing: error))")
        }
    }
}
