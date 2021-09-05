// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationData
import Foundation

final class MockWalletPayloadClient: WalletPayloadClientAPI {

    private let result: Result<WalletPayloadClient.Response, WalletPayloadClient.ErrorResponse>

    init(result: Result<WalletPayloadClient.Response, WalletPayloadClient.ErrorResponse>) {
        self.result = result
    }

    func payload(
        guid: String,
        identifier: WalletPayloadClient.Identifier
    ) -> AnyPublisher<WalletPayloadClient.ClientResponse, WalletPayloadClient.ClientError> {
        switch result {
        case .success(let response):
            do {
                return .just(try WalletPayloadClient.ClientResponse(response: response))
            } catch {
                return .failure(.message(error.localizedDescription))
            }
        case .failure(let response):
            return .failure(.message(response.localizedDescription))
        }
    }
}
