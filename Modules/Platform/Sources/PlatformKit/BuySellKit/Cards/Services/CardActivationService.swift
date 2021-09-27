// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxCombine
import RxRelay
import RxSwift
import ToolKit

public enum CardActivationState {
    case active(CardData)
    case pending
    case inactive(CardData?)

    var isPending: Bool {
        switch self {
        case .pending:
            return true
        case .active, .inactive:
            return false
        }
    }

    init(_ cardPayload: CardPayload) {
        guard let cardData = CardData(response: cardPayload) else {
            self = .inactive(nil)
            return
        }
        switch cardPayload.state {
        case .active:
            self = .active(cardData)
        case .pending:
            self = .pending
        case .blocked, .expired, .created, .none, .fraudReview, .manualReview:
            self = .inactive(cardData)
        }
    }
}

public protocol CardActivationServiceAPI: AnyObject {

    /// Cancel polling
    var cancel: Completable { get }

    /// Poll for activation
    func waitForActivation(of cardId: String) -> Single<PollResult<CardActivationState>>
}

final class CardActivationService: CardActivationServiceAPI {

    // MARK: - Types

    private enum Constant {
        /// Duration in seconds
        static let pollingDuration: TimeInterval = 60
    }

    // MARK: - Properties

    var cancel: Completable {
        pollService.cancel
    }

    // MARK: - Injected

    private let pollService: PollService<CardActivationState>
    private let client: CardDetailClientAPI

    // MARK: - Setup

    init(client: CardDetailClientAPI = resolve()) {
        self.client = client
        pollService = .init(matcher: { !$0.isPending })
    }

    func waitForActivation(of cardId: String) -> Single<PollResult<CardActivationState>> {
        pollService.setFetch(weak: self) { (self) in
            self.client.getCard(by: cardId)
                .asObservable()
                .asSingle()
                .map { payload in
                    guard payload.state != .pending else {
                        return .pending
                    }
                    return CardActivationState(payload)
                }
        }

        return pollService.poll(timeoutAfter: Constant.pollingDuration)
    }
}
