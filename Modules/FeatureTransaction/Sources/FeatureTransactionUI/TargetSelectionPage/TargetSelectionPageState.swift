// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import ToolKit

enum TargetSelectionPageStep: Equatable {
    // TODO: QR Scanning Step
    case initial
    case complete
    case qrScanner
    case closed

    var addToBackStack: Bool {
        switch self {
        case .closed,
             .complete,
             .initial,
             .qrScanner:
            return false
        }
    }
}

struct TargetSelectionPageState: Equatable, StateType {

    static let empty = TargetSelectionPageState()

    var nextEnabled: Bool = false
    var isGoingBack: Bool = false
    var inputValidated: TargetSelectionInputValidation = .empty
    var sourceAccount: BlockchainAccount?
    var availableTargets: [TransactionTarget] = []
    var destination: TransactionTarget? {
        didSet {
            Logger.shared.debug("TransactionTarget: \(String(describing: destination))")
        }
    }

    var stepsBackStack: [TargetSelectionPageStep] = []
    var step: TargetSelectionPageStep = .initial {
        didSet {
            isGoingBack = false
        }
    }

    var inputRequiresAddressValidation: Bool {
        inputValidated.requiresValidation
    }

    // TODO: Handle alternate destination type
    // of an address

    static func == (lhs: TargetSelectionPageState, rhs: TargetSelectionPageState) -> Bool {
        lhs.nextEnabled == rhs.nextEnabled &&
            lhs.destination?.label == rhs.destination?.label &&
            lhs.sourceAccount?.identifier == rhs.sourceAccount?.identifier &&
            lhs.step == rhs.step &&
            lhs.stepsBackStack == rhs.stepsBackStack &&
            lhs.inputValidated == rhs.inputValidated &&
            lhs.isGoingBack == rhs.isGoingBack &&
            lhs.availableTargets.map(\.label) == rhs.availableTargets.map(\.label)
    }
}

extension TargetSelectionPageState {
    func withUpdatedBackstack(oldState: TargetSelectionPageState) -> TargetSelectionPageState {
        if oldState.step != step, oldState.step.addToBackStack {
            var newState = self
            var newStack = oldState.stepsBackStack
            newStack.append(oldState.step)
            newState.stepsBackStack = newStack
            return newState
        }
        return self
    }
}
