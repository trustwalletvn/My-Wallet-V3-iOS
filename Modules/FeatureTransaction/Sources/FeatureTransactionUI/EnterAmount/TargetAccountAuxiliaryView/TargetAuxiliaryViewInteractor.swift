// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// This class only serves the purpose of avoiding a leak due to how we're using `RIBs`.
/// Refactoring that to solve the issue would be too much work. Given the choice, I'd rather rewrite the whole module so it doesn't use `RIBs` in the first place.
final class TargetAuxiliaryViewInteractor {

    weak var enterAmountInteractor: EnterAmountPageInteractor?

    init(enterAmountInteractor: EnterAmountPageInteractor) {
        self.enterAmountInteractor = enterAmountInteractor
    }

    func handleTopAuxiliaryViewTapped(state: TransactionState) {
        enterAmountInteractor?.handleTopAuxiliaryViewTapped(state: state)
    }
}

extension TargetAuxiliaryViewInteractor: Equatable {

    static func == (lhs: TargetAuxiliaryViewInteractor, rhs: TargetAuxiliaryViewInteractor) -> Bool {
        lhs === rhs
    }
}
