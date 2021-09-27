// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineExt
@testable import NetworkKit
@testable import PlatformKit
import ToolKit
import XCTest

@testable import NetworkKitMock
@testable import PlatformKitMock
@testable import ToolKitMock

// swiftlint:disable type_body_length

class NabuAuthenticationExecutorTests: XCTestCase {

    private var cancellables: Set<AnyCancellable>!
    private var userCreationClient: NabuUserCreationClientMock!
    private var sessionTokenClient: NabuSessionTokenClientMock!
    private var resetUserClient: NabuResetUserClientMock!
    private var store: NabuTokenStore!
    private var settingsService: SettingsServiceMock!
    private var siftService: SiftServiceMock!
    private var jwtService: JWTServiceMock!
    private var walletRepository: MockWalletRepository!
    private var deviceInfo: MockDeviceInfo!
    private var subject: NabuAuthenticationExecutor!

    override func setUpWithError() throws {
        try super.setUpWithError()

        cancellables = Set<AnyCancellable>([])
        sessionTokenClient = NabuSessionTokenClientMock()
        userCreationClient = NabuUserCreationClientMock()
        resetUserClient = NabuResetUserClientMock()
        store = NabuTokenStore()
        settingsService = SettingsServiceMock()
        siftService = SiftServiceMock()
        jwtService = JWTServiceMock()
        walletRepository = MockWalletRepository()
        deviceInfo = MockDeviceInfo(
            systemVersion: "1.2.3",
            model: "iPhone5S",
            uuidString: "uuid"
        )
        subject = NabuAuthenticationExecutor(
            userCreationClient: userCreationClient,
            store: store,
            settingsService: settingsService,
            siftService: siftService,
            jwtService: jwtService,
            sessionTokenClient: sessionTokenClient,
            resetUserClient: resetUserClient,
            credentialsRepository: walletRepository,
            deviceInfo: deviceInfo
        )
    }

    override func tearDownWithError() throws {
        cancellables = nil
        sessionTokenClient = nil
        userCreationClient = nil
        resetUserClient = nil
        store = nil
        settingsService = nil
        siftService = nil
        jwtService = nil
        walletRepository = nil
        deviceInfo = nil
        subject = nil

        try super.tearDownWithError()
    }

    func testSuccessfulAuthenticationWhenUserIsAlreadyCreated() throws {

        // Arrange
        let expectedSessionTokenValue = "session-token"

        let offlineTokenResponse = NabuOfflineTokenResponse(
            userId: "user-id",
            token: "offline-token"
        )

        jwtService.expectedResult = .success("jwt-token")

        settingsService.expectedResult = .success(
            .init(
                response: .init(
                    language: "en",
                    currency: "USD",
                    email: "abcd@abcd.com",
                    guid: "guid",
                    emailNotificationsEnabled: false,
                    smsNumber: nil,
                    smsVerified: false,
                    emailVerified: false,
                    authenticator: 0,
                    countryCode: "US",
                    invited: [:]
                )
            )
        )

        let offlineTokenResponseSetExpectation = expectation(
            description: "The offline token was set successfully"
        )
        walletRepository
            .setPublisher(
                offlineTokenResponse: offlineTokenResponse
            )
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    offlineTokenResponseSetExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed to set the offlineToken error: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        sessionTokenClient.expectedResult = .success(
            NabuSessionTokenResponse(
                identifier: "identifier",
                userId: "user-id",
                token: expectedSessionTokenValue,
                isActive: true,
                expiresAt: .distantFuture
            )
        )

        let guidSetExpectation = expectation(
            description: "The GUID was set successfully"
        )
        walletRepository
            .setPublisher(
                guid: "guid"
            )
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    guidSetExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed to set the guid error: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        let sharedKeySetExpectation = expectation(
            description: "The Shared Key was set successfully"
        )
        walletRepository
            .setPublisher(
                sharedKey: "shared-key"
            )
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    sharedKeySetExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed to set the sharedKey error: \(error)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(
            for: [
                offlineTokenResponseSetExpectation,
                guidSetExpectation,
                sharedKeySetExpectation
            ],
            timeout: 20,
            enforceOrder: false
        )

        let receivedValidTokenExpectation = expectation(
            description: "Received Valid token"
        )
        let authenticationSuccessfulExpectation = expectation(
            description: "The user was created and sucessfully authenticated"
        )

        // Act
        subject
            .authenticate { token -> AnyPublisher<ServerResponse, NetworkError> in
                AnyPublisher.just(
                    ServerResponse(
                        payload: token.data(using: .utf8),
                        response: HTTPURLResponse(
                            url: URL(string: "https://blockchain.com/")!,
                            statusCode: 200,
                            httpVersion: nil,
                            headerFields: nil
                        )!
                    )
                )
            }
            .map { response -> String in
                String(data: response.payload!, encoding: .utf8)!
            }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    authenticationSuccessfulExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Authentication failed with error: \(String(describing: error))")
                }
            }, receiveValue: { value in
                XCTAssertEqual(value, expectedSessionTokenValue)
                receivedValidTokenExpectation.fulfill()
            })
            .store(in: &cancellables)

        // Assert
        wait(
            for: [
                receivedValidTokenExpectation,
                authenticationSuccessfulExpectation
            ],
            timeout: 20,
            enforceOrder: false
        )
    }

    func testSuccessfulAuthenticationWhenUserIsNotCreated() throws {

        // Arrange
        let expectedSessionTokenValue = "session-token"

        let offlineTokenResponse = NabuOfflineTokenResponse(userId: "user-id", token: "offline-token")

        // Offline token is missing - user creation will be attempted
        walletRepository.expectedOfflineTokenResponse = .failure(.offlineToken)
        jwtService.expectedResult = .success("jwt-token")
        userCreationClient.expectedResult = .success(offlineTokenResponse)

        settingsService.expectedResult = .success(
            .init(
                response: .init(
                    language: "en",
                    currency: "USD",
                    email: "abcd@abcd.com",
                    guid: "guid",
                    emailNotificationsEnabled: false,
                    smsNumber: nil,
                    smsVerified: false,
                    emailVerified: false,
                    authenticator: 0,
                    countryCode: "US",
                    invited: [:]
                )
            )
        )

        sessionTokenClient.expectedResult = .success(
            NabuSessionTokenResponse(
                identifier: "identifier",
                userId: "user-id",
                token: expectedSessionTokenValue,
                isActive: true,
                expiresAt: .distantFuture
            )
        )

        let guidSetExpectation = expectation(
            description: "The GUID was set successfully"
        )
        walletRepository
            .setPublisher(
                guid: "guid"
            )
            .sink(receiveCompletion: { completion in
                guard case .finished = completion else {
                    XCTFail("failed to set the guid")
                    return
                }
                guidSetExpectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        let sharedKeySetExpectation = expectation(
            description: "The Shared Key was set successfully"
        )
        walletRepository
            .setPublisher(
                sharedKey: "shared-key"
            )
            .sink(receiveCompletion: { completion in
                guard case .finished = completion else {
                    XCTFail("failed to set the shared key")
                    return
                }
                sharedKeySetExpectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(for: [guidSetExpectation, sharedKeySetExpectation], timeout: 5, enforceOrder: false)

        let receivedValidTokenExpectation = expectation(
            description: "Received Valid token"
        )
        let authenticationSuccessfulExpectation = expectation(
            description: "The user was created and sucessfully authenticated"
        )

        // Act
        subject
            .authenticate { token -> AnyPublisher<ServerResponse, NetworkError> in
                AnyPublisher.just(
                    ServerResponse(
                        payload: token.data(using: .utf8),
                        response: HTTPURLResponse(
                            url: URL(string: "https://blockchain.com/")!,
                            statusCode: 200,
                            httpVersion: nil,
                            headerFields: nil
                        )!
                    )
                )
            }
            .map { response -> String in
                String(data: response.payload!, encoding: .utf8)!
            }
            .sink(receiveCompletion: { [unowned self] completion in
                switch completion {
                case .finished:
                    XCTAssertEqual(
                        // swiftlint:disable:next force_try
                        try! self.walletRepository.expectedOfflineTokenResponse.get(),
                        offlineTokenResponse
                    )
                    authenticationSuccessfulExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed with error: \(String(describing: error))")
                }
            }, receiveValue: { value in
                XCTAssertEqual(value, expectedSessionTokenValue)
                receivedValidTokenExpectation.fulfill()
            })
            .store(in: &cancellables)

        // Assert
        wait(
            for: [receivedValidTokenExpectation, authenticationSuccessfulExpectation],
            timeout: 20,
            enforceOrder: true
        )
    }

    func testExpiredTokenAndSecondSuccessfulAuthentication() throws {

        // Arrange
        let offlineTokenResponse = NabuOfflineTokenResponse(
            userId: "user-id",
            token: "offline-token"
        )

        let expiredSessionTokenResponse = NabuSessionTokenResponse(
            identifier: "identifier",
            userId: "user-id",
            token: "expired-session-token",
            isActive: true,
            expiresAt: Date.distantPast
        )

        let newSessionTokenResponse = NabuSessionTokenResponse(
            identifier: "identifier",
            userId: "user-id",
            token: "new-session-token",
            isActive: true,
            expiresAt: Date.distantFuture
        )

        let expiredAuthTokenStoredExpectation = expectation(
            description: "The expired auth token was successfully stored"
        )
        // Store expired session token
        store.store(expiredSessionTokenResponse)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        expiredAuthTokenStoredExpectation.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        jwtService.expectedResult = .success("jwt-token")
        settingsService.expectedResult = .success(
            .init(
                response: .init(
                    language: "en",
                    currency: "USD",
                    email: "abcd@abcd.com",
                    guid: "guid",
                    emailNotificationsEnabled: false,
                    smsNumber: nil,
                    smsVerified: false,
                    emailVerified: false,
                    authenticator: 0,
                    countryCode: "US",
                    invited: [:]
                )
            )
        )

        sessionTokenClient.expectedResult = .success(newSessionTokenResponse)

        wait(for: [expiredAuthTokenStoredExpectation], timeout: 5, enforceOrder: true)

        let offlineTokenResponseSetExpectation = expectation(
            description: "The offline token was set successfully"
        )
        walletRepository
            .setPublisher(
                offlineTokenResponse: offlineTokenResponse
            )
            .sink(receiveCompletion: { completion in
                guard case .finished = completion else {
                    XCTFail("failed to set the guid")
                    return
                }
                offlineTokenResponseSetExpectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        let guidSetExpectation = expectation(
            description: "The GUID was set successfully"
        )
        walletRepository
            .setPublisher(
                guid: "guid"
            )
            .sink(receiveCompletion: { completion in
                guard case .finished = completion else {
                    XCTFail("failed to set the guid")
                    return
                }
                guidSetExpectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        let sharedKeySetExpectation = expectation(
            description: "The Shared Key was set successfully"
        )
        walletRepository
            .setPublisher(
                sharedKey: "shared-key"
            )
            .sink(receiveCompletion: { completion in
                guard case .finished = completion else {
                    XCTFail("failed to set the shared key")
                    return
                }
                sharedKeySetExpectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(
            for: [
                offlineTokenResponseSetExpectation,
                guidSetExpectation,
                sharedKeySetExpectation
            ],
            timeout: 20,
            enforceOrder: true
        )

        // Act
        let receivedValidTokenExpectation = expectation(
            description: "Received Valid token"
        )
        let authenticationSuccessfulExpectation = expectation(
            description: "The user was created and sucessfully authenticated"
        )

        // Act
        subject
            .authenticate { token -> AnyPublisher<ServerResponse, NetworkError> in
                if token == newSessionTokenResponse.token {
                    return AnyPublisher.just(
                        ServerResponse(
                            payload: token.data(using: .utf8),
                            response: HTTPURLResponse(
                                url: URL(string: "https://blockchain.com/")!,
                                statusCode: 200,
                                httpVersion: nil,
                                headerFields: nil
                            )!
                        )
                    )
                } else {
                    let httpResponse = HTTPURLResponse(
                        url: URL(string: "https://www.blockchain.com")!,
                        statusCode: NabuAuthenticationError.tokenExpired.rawValue,
                        httpVersion: nil,
                        headerFields: nil
                    )!
                    let serverErrorResponse = ServerErrorResponse(
                        response: httpResponse,
                        payload: nil
                    )
                    return AnyPublisher.failure(
                        .rawServerError(
                            serverErrorResponse
                        )
                    )
                }
            }
            .map { response -> String in
                String(data: response.payload!, encoding: .utf8)!
            }
            .sink(receiveCompletion: { [unowned self] completion in
                switch completion {
                case .finished:
                    XCTAssertEqual(
                        // swiftlint:disable:next force_try
                        try! self.walletRepository.expectedOfflineTokenResponse.get(),
                        offlineTokenResponse
                    )
                    authenticationSuccessfulExpectation.fulfill()
                case .failure(let error):
                    XCTFail("Failed with error: \(String(describing: error))")
                }
            }, receiveValue: { value in
                XCTAssertEqual(value, newSessionTokenResponse.token)
                receivedValidTokenExpectation.fulfill()
            })
            .store(in: &cancellables)

        // Assert
        wait(
            for: [
                receivedValidTokenExpectation,
                authenticationSuccessfulExpectation
            ],
            timeout: 20,
            enforceOrder: true
        )
    }
}
