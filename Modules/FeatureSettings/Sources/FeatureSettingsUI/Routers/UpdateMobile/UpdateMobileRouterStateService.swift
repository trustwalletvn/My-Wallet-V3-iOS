// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxRelay
import RxSwift

final class UpdateMobileRouterStateService: UpdateMobileStateServiceAPI {

    // MARK: - States

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
        case start

        /// The Mobile Number Entry Screen
        case mobileNumber

        /// The 4 Digit Code Entry Screen
        case codeEntry

        /// ~Fin~
        case end
    }

    enum Action {

        /// Procede to the next `State`
        case next(State)

        /// Return to the prior screen
        case previous
    }

    let nextRelay = PublishRelay<Void>()
    let previousRelay = PublishRelay<Void>()

    var action: Observable<Action> {
        actionRelay
            .observeOn(MainScheduler.instance)
    }

    private let actionRelay = PublishRelay<Action>()
    private let statesRelay = BehaviorRelay<States>(value: .start)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init() {
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
            state = .mobileNumber
            action = .next(state)
        case .mobileNumber:
            state = .codeEntry
            action = .next(state)
        case .codeEntry:
            state = .end
            action = .next(state)
        case .end:
            state = .end
            action = .previous
        }
        let nextStates = states.states(byAppending: state)
        apply(action: action, states: nextStates)
    }

    private func previous() {
        let states = statesRelay.value.statesByRemovingLast()
        apply(action: .previous, states: states)
    }

    private func apply(action: Action, states: States) {
        actionRelay.accept(action)
        statesRelay.accept(states)
    }
}
