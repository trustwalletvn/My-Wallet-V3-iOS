// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit

public struct SimplifiedDueDiligenceResponse: Codable {
    let eligible: Bool
    let tier: Int
}

// swiftlint:disable:next type_name
public struct SimplifiedDueDiligenceVerificationResponse: Codable {
    let verified: Bool
    let taskComplete: Bool
}

public protocol KYCClientAPI: AnyObject {

    func tiers() -> AnyPublisher<KYC.UserTiers, NabuNetworkError>

    func supportedDocuments(
        for country: String
    ) -> AnyPublisher<KYCSupportedDocumentsResponse, NabuNetworkError>

    func user() -> AnyPublisher<NabuUser, NabuNetworkError>

    func listOfStates(
        in country: String
    ) -> AnyPublisher<[KYCState], NabuNetworkError>

    func selectCountry(
        country: String,
        state: String?,
        notifyWhenAvailable: Bool,
        jwtToken: String
    ) -> AnyPublisher<Void, NabuNetworkError>

    func updatePersonalDetails(
        firstName: String?,
        lastName: String?,
        birthday: Date?
    ) -> AnyPublisher<Void, NabuNetworkError>

    func updateAddress(
        userAddress: UserAddress
    ) -> AnyPublisher<Void, NabuNetworkError>

    func credentialsForVeriff() -> AnyPublisher<VeriffCredentials, NabuNetworkError>

    func submitToVeriffForVerification(
        applicantId: String
    ) -> AnyPublisher<Void, NabuNetworkError>

    // MARK: Combine Interface

    func fetchUser() -> AnyPublisher<NabuUser, NabuNetworkError>

    func checkSimplifiedDueDiligenceEligibility() -> AnyPublisher<SimplifiedDueDiligenceResponse, NabuNetworkError>

    func checkSimplifiedDueDiligenceVerification() -> AnyPublisher<SimplifiedDueDiligenceVerificationResponse, NabuNetworkError>
}

public final class KYCClient: KYCClientAPI {

    // MARK: - Types

    private enum Path {

        // GET

        static let tiers = ["kyc", "tiers"]
        static let credentials = ["kyc", "credentials"]
        static let credentiasForVeriff = ["kyc", "credentials", "veriff"]
        static let currentUser = ["users", "current"]
        static let simplifiedDueDiligenceEligibility = ["sdd", "eligible"]
        static let simplifiedDueDiligenceVerification = ["sdd", "verified"]

        static func supportedDocuments(for country: String) -> [String] {
            ["kyc", "supported-documents", country]
        }

        static func listOfStates(in country: String) -> [String] {
            ["countries", country, "states"]
        }

        // POST

        static let country = ["users", "current", "country"]
        static let verifications = ["verifications"]
        static let submitVerification = ["kyc", "verifications"]

        // PUT

        static let updateAddress = ["users", "current", "address"]
        static let updateUserDetails = ["users", "current"]
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    public func tiers() -> AnyPublisher<KYC.UserTiers, NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.tiers,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    public func supportedDocuments(
        for country: String
    ) -> AnyPublisher<KYCSupportedDocumentsResponse, NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.supportedDocuments(for: country),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    public func credentialsForVeriff() -> AnyPublisher<VeriffCredentials, NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.credentiasForVeriff,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    public func user() -> AnyPublisher<NabuUser, NabuNetworkError> {
        fetchUser()
    }

    public func listOfStates(
        in country: String
    ) -> AnyPublisher<[KYCState], NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.listOfStates(in: country)
        )!
        return networkAdapter
            .perform(request: request)
            .map { (states: [KYCState]) in
                states.sorted { $0.name.uppercased() < $1.name.uppercased() }
            }
            .eraseToAnyPublisher()
    }

    public func submitToVeriffForVerification(
        applicantId: String
    ) -> AnyPublisher<Void, NabuNetworkError> {
        struct Payload: Encodable {

            private enum CodingKeys: String, CodingKey {
                case applicantId
                case clientType = "X-CLIENT-TYPE"
            }

            let applicantId: String
            let clientType: String

            init(applicantId: String) {
                self.applicantId = applicantId
                clientType = HttpHeaderValue.clientTypeApp
            }
        }

        let payload = Payload(applicantId: applicantId)

        let request = requestBuilder.post(
            path: Path.submitVerification,
            body: try? payload.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    public func selectCountry(
        country: String,
        state: String?,
        notifyWhenAvailable: Bool,
        jwtToken: String
    ) -> AnyPublisher<Void, NabuNetworkError> {
        struct Payload: Encodable {
            let jwt: String
            let countryCode: String
            let state: String?
            let notifyWhenAvailable: String

            init(jwt: String, country: String, state: String?, notifyWhenAvailable: Bool) {
                self.jwt = jwt
                countryCode = country
                self.state = state
                self.notifyWhenAvailable = "\(notifyWhenAvailable)"
            }
        }

        let payload = Payload(
            jwt: jwtToken,
            country: country,
            state: state,
            notifyWhenAvailable: notifyWhenAvailable
        )

        let request = requestBuilder.post(
            path: Path.country,
            body: try? payload.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    public func updatePersonalDetails(
        firstName: String?,
        lastName: String?,
        birthday: Date?
    ) -> AnyPublisher<Void, NabuNetworkError> {
        let payload = KYCUpdatePersonalDetailsRequest(
            firstName: firstName,
            lastName: lastName,
            birthday: birthday
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(DateFormatter.birthday)

        let request = requestBuilder.put(
            path: Path.updateUserDetails,
            body: try? encoder.encode(payload),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    public func updateAddress(
        userAddress: UserAddress
    ) -> AnyPublisher<Void, NabuNetworkError> {
        let payload = KYCUpdateAddressRequest(address: userAddress)
        let request = requestBuilder.put(
            path: Path.updateAddress,
            body: try? payload.encode(),
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: Combine Interface

    public func fetchUser() -> AnyPublisher<NabuUser, NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.currentUser,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    public func checkSimplifiedDueDiligenceEligibility() -> AnyPublisher<SimplifiedDueDiligenceResponse, NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.simplifiedDueDiligenceEligibility,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }

    public func checkSimplifiedDueDiligenceVerification() -> AnyPublisher<SimplifiedDueDiligenceVerificationResponse, NabuNetworkError> {
        let request = requestBuilder.get(
            path: Path.simplifiedDueDiligenceVerification,
            authenticated: true
        )!
        return networkAdapter.perform(request: request)
    }
}
