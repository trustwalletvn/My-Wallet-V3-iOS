// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension SellRouterInteractor.State: CustomDebugStringConvertible {

    var debugDescription: String {
        switch self {
        case .inactive:
            return "inactive"
        case .ineligible:
            return "ineligible"
        case .verificationFailed:
            return "verificationFailed"
        case .ineligibilityURL:
            return "ineligibilityURL"
        case .contactSupportURL:
            return "contactSupportURL"
        case .introduction:
            return "introduction"
        case .kyc:
            return "kyc"
        case .accountSelector:
            return "accountSelector"
        case .fiatAccountSelector:
            return "fiatAccountSelector"
        case .enterAmount(let data):
            return "enter-amount | data: \(data)"
        case .checkout(let data):
            return "checkout | data: \(data)"
        case .cancel(let data):
            return "cancel | data: \(data)"
        case .pendingOrderCompleted(orderDetails: let orderDetails):
            return "pendingOrderCompleted | orderID: \(orderDetails)"
        case .completed:
            return "completed"
        }
    }
}

extension SellRouterInteractor.States: CustomDebugStringConvertible {
    var debugDescription: String {
        all
            .map(\.debugDescription)
            .joined(separator: ",")
    }
}

extension SellRouterInteractor.Action: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .next(to: let state):
            return "next-to: \(state.debugDescription)"
        case .previous(from: let state):
            return "previous-from: \(state.debugDescription)"
        case .dismiss:
            return "dismiss"
        }
    }
}
