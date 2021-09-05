// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

protocol Session {
    func dataTaskPublisher(for request: Request) -> URLSession.DataTaskPublisher
}

extension URLSession: Session {
    func dataTaskPublisher(for request: Request) -> DataTaskPublisher {
        dataTaskPublisher(for: request.asURLRequest())
    }
}
