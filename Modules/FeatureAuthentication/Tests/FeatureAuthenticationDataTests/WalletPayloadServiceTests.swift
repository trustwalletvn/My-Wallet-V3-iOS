// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationData
@testable import FeatureAuthenticationDomain
@testable import FeatureAuthenticationMock
import RxBlocking
import XCTest

class WalletPayloadServiceTests: XCTestCase {

    // TODO: replace with the dedicated method implemented in IOS-4610 for combine related tests
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    /// Tests a valid response to payload fetching that requires 2FA code
    func testValid2FAResponse() throws {
        let expectedAuthType = WalletAuthenticatorType.sms // expect SMS
        let serverResponse = WalletPayloadClient.Response.fake(
            guid: "fake-guid", // expect this fake GUID value
            authenticatorType: expectedAuthType,
            payload: nil
        )
        let repository = MockWalletRepository()
        _ = try repository.set(sessionToken: "1234-abcd-5678-efgh").toBlocking().first()
        _ = try repository.set(guid: "fake-guid").toBlocking().first()
        let client = MockWalletPayloadClient(result: .success(serverResponse))
        let service = WalletPayloadService(
            client: client,
            repository: repository
        )
        do {
            // TODO: delete these once IOS-4610 is ready
            let serviceAuthTypePublisher = service.requestUsingSessionToken()
            var serviceAuthType: WalletAuthenticatorType = .standard
            var error: WalletPayloadServiceError?
            let expectation = self.expectation(description: "2FA Response")
            serviceAuthTypePublisher
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let serviceError):
                            error = serviceError
                        }
                        expectation.fulfill()
                    },
                    receiveValue: { value in
                        serviceAuthType = value
                    }
                )
                .store(in: &cancellables)
            waitForExpectations(timeout: 5)

            let repositoryAuthType = try repository.authenticatorType.toBlocking().first()
            XCTAssertNil(error)
            XCTAssertEqual(repositoryAuthType, serviceAuthType)
            XCTAssertEqual(serviceAuthType, expectedAuthType)
        } catch {
            XCTFail("expected payload fetching to require \(expectedAuthType), got error: \(error)")
        }
    }

    func testValidPayloadResponse() throws {
        let expectedAuthType = WalletAuthenticatorType.standard // expect no 2FA
        let serverResponse = WalletPayloadClient.Response.fake(
            guid: "fake-guid", // expect this fake GUID value
            authenticatorType: expectedAuthType,
            payload: "{\"pbkdf2_iterations\":1,\"version\":3,\"payload\":\"payload-for-wallet\"}"
        )
        let repository = MockWalletRepository()
        _ = try repository.set(sessionToken: "1234-abcd-5678-efgh").toBlocking().first()
        _ = try repository.set(guid: "fake-guid").toBlocking().first()
        let client = MockWalletPayloadClient(result: .success(serverResponse))
        let service = WalletPayloadService(
            client: client,
            repository: repository
        )
        do {
            // TODO: delete these once IOS-4610 is ready
            let serviceAuthTypePublisher = service.requestUsingSessionToken()
            var serviceAuthType: WalletAuthenticatorType = .standard
            var error: WalletPayloadServiceError?
            let expectation = self.expectation(description: "2FA Response")
            serviceAuthTypePublisher
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let serviceError):
                            error = serviceError
                        }
                        expectation.fulfill()
                    },
                    receiveValue: { value in
                        serviceAuthType = value
                    }
                )
                .store(in: &cancellables)
            waitForExpectations(timeout: 5)

            let repositoryAuthType = try repository.authenticatorType.toBlocking().first()
            XCTAssertNil(error)
            XCTAssertEqual(repositoryAuthType, serviceAuthType)
            XCTAssertEqual(serviceAuthType, expectedAuthType)
            XCTAssertNotNil(try repository.payload.toBlocking().first())
        } catch {
            XCTFail("expected payload fetching to require \(expectedAuthType), got error: \(error)")
        }
    }
}
