// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit
import PlatformKit
import RxSwift
import ToolKit

final class KYCClientMock: KYCClientAPI {

    struct StubbedResults {
        var fetchUser: AnyPublisher<NabuUser, NabuNetworkError> = {
            .failure(NabuNetworkError.mockError)
        }()

        var checkSimplifiedDueDiligenceEligibility: AnyPublisher<SimplifiedDueDiligenceResponse, NabuNetworkError> = {
            .failure(NabuNetworkError.mockError)
        }()

        var checkSimplifiedDueDiligenceVerification: AnyPublisher<SimplifiedDueDiligenceVerificationResponse, NabuNetworkError> = {
            .failure(NabuNetworkError.mockError)
        }()
    }

    var stubbedResults = StubbedResults()

    var expectedTiers: Result<KYC.UserTiers, Error>!

    func tiers() -> Single<KYC.UserTiers> {
        expectedTiers.single
    }

    var expectedSupportedDocuments: Result<KYCSupportedDocumentsResponse, Error>!

    func supportedDocuments(for country: String) -> Single<KYCSupportedDocumentsResponse> {
        expectedSupportedDocuments.single
    }

    var expectedUser: Result<NabuUser, Error>!

    func user() -> Single<NabuUser> {
        expectedUser.single
    }

    var expectedListOfStates: Result<[KYCState], Error>!

    func listOfStates(in country: String) -> Single<[KYCState]> {
        expectedListOfStates.single
    }

    var expectedSelectCountry: Completable!

    func selectCountry(country: String, state: String?, notifyWhenAvailable: Bool, jwtToken: String) -> Completable {
        expectedSelectCountry
    }

    var expectedPersonalDetails: Completable!

    func updatePersonalDetails(firstName: String?, lastName: String?, birthday: Date?) -> Completable {
        expectedPersonalDetails
    }

    var expectedUpdateAddressCompletable: Completable!

    func updateAddress(userAddress: UserAddress) -> Completable {
        expectedUpdateAddressCompletable
    }

    var expectedCredentials: Result<VeriffCredentials, Error>!

    func credentialsForVeriff() -> Single<VeriffCredentials> {
        expectedCredentials.single
    }

    var expectedSubmitToVeriffForVerification: Completable!

    func submitToVeriffForVerification(applicantId: String) -> Completable {
        expectedSubmitToVeriffForVerification
    }

    var jwtToken: Result<String, Error>!

    func requestJWT(guid: String, sharedKey: String) -> Single<String> {
        jwtToken.single
    }

    func fetchUser() -> AnyPublisher<NabuUser, NabuNetworkError> {
        stubbedResults.fetchUser
    }

    func checkSimplifiedDueDiligenceEligibility() -> AnyPublisher<SimplifiedDueDiligenceResponse, NabuNetworkError> {
        stubbedResults.checkSimplifiedDueDiligenceEligibility
    }

    func checkSimplifiedDueDiligenceVerification() -> AnyPublisher<SimplifiedDueDiligenceVerificationResponse, NabuNetworkError> {
        stubbedResults.checkSimplifiedDueDiligenceVerification
    }
}
