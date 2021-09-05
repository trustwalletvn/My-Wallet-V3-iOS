// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxSwift

/// The interface for the interactors behind all `AmountViewable` views
/// in the `Enter Amount` screen.
public protocol AmountViewInteracting {

    /// Current amount entered.
    var amount: Observable<MoneyValue> { get }

    /// The current input type (fiat or crypto)
    var activeInput: Observable<ActiveAmountInput> { get }

    /// If there's an error, an effect is returned. Currently
    /// only used to show an alert.
    var effect: Observable<AmountInteractorEffect> { get }

    /// The state of the interactor
    var stateRelay: BehaviorRelay<AmountInteractorState> { get }

    /// API for connecting user inputs and deriving a state of the interactor
    /// - Parameter input: Can be inserting or removing a character
    func connect(input: Driver<AmountInteractorInput>) -> Driver<AmountInteractorState>

    /// Setting the amount entered. Used for sending the `Max`
    /// - Parameter amount: `MoneyValue`
    func set(amount: MoneyValue)

    /// Setting the amount entered. Used for sending the `Max`
    /// - Parameter amount: `String`
    func set(amount: String)
}
