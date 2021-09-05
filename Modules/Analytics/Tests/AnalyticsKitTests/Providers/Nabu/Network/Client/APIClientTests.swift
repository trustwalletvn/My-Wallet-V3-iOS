// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import Mockingbird
import XCTest

@testable import AnalyticsKit

final class APIClientTests: XCTestCase {

    var apiClient: APIClient?

    var networkAdapterMock = mock(NetworkAdapterAPI.self)
    var requestBuilderMock = mock(RequestBuilderAPI.self)

    override func setUpWithError() throws {
        try super.setUpWithError()
        apiClient = APIClient(
            networkAdapter: networkAdapterMock,
            requestBuilder: requestBuilderMock
        )
    }

    override func tearDownWithError() throws {
        apiClient = nil
        try super.tearDownWithError()
    }

    func test_apiClient_callsRequestBuildierAndNetworkAdapter() throws {
        let request = Request(method: .post, url: URL(string: "https://api.blockchain.info/")!, body: nil, headers: [:])
        given(requestBuilderMock.post(path: any(), body: any(), headers: any())) ~> request
        given(networkAdapterMock.performRequest(request: any())) ~> Empty().eraseToAnyPublisher()

        _ = apiClient?.publish(events: 1, token: "token")

        verify(requestBuilderMock.post(path: any(), body: any(), headers: any())).wasCalled(exactly(1))
        verify(networkAdapterMock.performRequest(request: any())).wasCalled(exactly(1))
    }
}
