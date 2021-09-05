// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum SourceState {
    case canTransact
    case noFunds
    case fundsLocked
    case notEnoughGas
    case sendInFlight
    case notSupported
}
