// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct ServerResponse {
    let payload: Data?
    let response: HTTPURLResponse
}

public struct ServerErrorResponse: Error {
    public let response: HTTPURLResponse
    public let payload: Data?
}
