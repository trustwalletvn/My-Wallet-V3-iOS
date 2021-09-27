// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import NetworkKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

enum WithdrawalError: LocalizedError {
    private typealias LocalizationFailureIDs = LocalizationConstants.SimpleBuy.Withdrawal.SummaryFailure

    case unknown
    case withdrawalLocked

    var localizedTitle: String {
        switch self {
        case .unknown:
            return LocalizationFailureIDs.Unknown.title
        case .withdrawalLocked:
            return LocalizationFailureIDs.WithdrawLocked.title
        }
    }

    var localizedDescription: String {
        switch self {
        case .unknown:
            return LocalizationFailureIDs.Unknown.description
        case .withdrawalLocked:
            return LocalizationFailureIDs.WithdrawLocked.description
        }
    }
}

/// The status of the withdrawal after submission
enum CustodyWithdrawalStatus: Equatable {
    /// Default state
    case unknown

    /// The withdrawal was successful
    case successful

    /// The withdrawal failed
    case failed(WithdrawalError)
}

protocol CustodyWithdrawalStateReceiverServiceAPI: AnyObject {

    /// The action that should be executed, the `next` action
    /// is coupled with the current state
    var action: Observable<CustodyWithdrawalStateService.Action> { get }
}

protocol CustodyWithdrawalStateEmitterServiceAPI: AnyObject {

    /// A relay for submitting the withdrawal status after submittal.
    /// This allows the `nextRelay` to be free of nested types and
    /// forwarding of withdrawal submission status to the summary screen.
    var completionRelay: BehaviorRelay<CustodyWithdrawalStatus> { get }

    /// Move to the next state
    var nextRelay: PublishRelay<Void> { get }

    /// Move to the previous state
    var previousRelay: PublishRelay<Void> { get }
}

typealias CustodyWithdrawalStateServiceAPI = CustodyWithdrawalStateReceiverServiceAPI &
    CustodyWithdrawalStateEmitterServiceAPI

final class CustodyWithdrawalStateService: CustodyWithdrawalStateServiceAPI {

    // MARK: - Types

    struct States {

        /// The actual state of the flow
        let current: State

        /// The previous states sorted chronologically
        let previous: [State]

        /// The starting state
        static var start: States {
            States(current: .start, previous: [])
        }

        /// Maps the instance of `States` into a new instance where the appended
        /// state is the current
        func states(byAppending state: State) -> States {
            States(
                current: state,
                previous: previous + [current]
            )
        }

        /// Maps the instance of `States` into a new instance where the last
        /// state is trimmed off.
        func statesByRemovingLast() -> States {
            States(
                current: previous.last ?? .end,
                previous: previous.dropLast()
            )
        }
    }

    // MARK: - Types

    enum State {

        /// The start of the custody-send flow
        case start

        /// Custody withdrawal screen
        case withdrawal

        /// ~Fin~
        case end
    }

    enum Action {
        case next(State)
        case previous
        case dismiss
    }

    // MARK: - Properties

    var states: Observable<States> {
        statesRelay.asObservable()
    }

    var currentState: Observable<CustodyWithdrawalStateService.State> {
        states.map(\.current)
    }

    var action: Observable<Action> {
        actionRelay
            .observeOn(MainScheduler.instance)
    }

    let nextRelay = PublishRelay<Void>()
    let previousRelay = PublishRelay<Void>()
    let completionRelay = BehaviorRelay<CustodyWithdrawalStatus>(value: .unknown)

    private let statesRelay = BehaviorRelay<States>(value: .start)
    private let actionRelay = PublishRelay<Action>()
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init() {
        completionRelay
            .observeOn(MainScheduler.instance)
            .filter { $0 != .unknown }
            .bindAndCatch(weak: self) { (self) in self.next() }
            .disposed(by: disposeBag)

        nextRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in self.next() }
            .disposed(by: disposeBag)

        previousRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in self.previous() }
            .disposed(by: disposeBag)
    }

    private func next() {
        let action: Action
        var state: State
        let states = statesRelay.value
        switch states.current {
        case .start:
            state = .withdrawal
            action = .next(state)
        case .withdrawal:
            state = .end
            action = .dismiss
        case .end:
            state = .end
            action = .dismiss
        }
        let nextStates = states.states(byAppending: state)
        apply(action: action, states: nextStates)
    }

    private func previous() {
        let states = statesRelay.value.statesByRemovingLast()
        let action: Action
        switch states.current {
        case .end, .start:
            action = .dismiss
        default:
            action = .previous
        }
        apply(action: action, states: states)
    }

    private func apply(action: Action, states: States) {
        actionRelay.accept(action)
        statesRelay.accept(states)
    }
}
