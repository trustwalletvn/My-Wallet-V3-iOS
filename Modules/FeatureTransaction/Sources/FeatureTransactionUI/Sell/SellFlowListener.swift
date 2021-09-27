// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

protocol SellFlowListening: AnyObject {
    func sellFlowDidComplete(with result: TransactionFlowResult)
}

final class SellFlowListener: SellFlowListening {

    private let subject = PassthroughSubject<TransactionFlowResult, Never>()

    var publisher: AnyPublisher<TransactionFlowResult, Never> {
        subject.eraseToAnyPublisher()
    }

    deinit {
        subject.send(completion: .finished)
    }

    func sellFlowDidComplete(with result: TransactionFlowResult) {
        subject.send(result)
    }
}
