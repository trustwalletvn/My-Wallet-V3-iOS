// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

protocol MviAction {
    associatedtype State

    func reduce(oldState: State) -> State
    func isValid(for oldState: State) -> Bool
}

extension MviAction {
    func isValid(for oldState: State) -> Bool { true }
}
