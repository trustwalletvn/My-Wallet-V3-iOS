// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

public protocol CardDeletionClientAPI: AnyObject {

    func deleteCard(by id: String) -> AnyPublisher<Void, NabuNetworkError>
}
