// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A calculation state for value. Typically used to reflect an ongoing
/// calculation of values
public enum ValueCalculationState<Value> {

    public enum CalculationError: Error {
        case valueCouldNotBeCalculated
        case empty
    }

    /// Value is available
    case value(Value)

    /// Value is being calculated
    case calculating

    case invalid(CalculationError)

    /// Returns the value when available
    public var value: Value? {
        switch self {
        case .value(let value):
            return value
        case .calculating, .invalid:
            return nil
        }
    }

    /// Returns `true` if has a value
    public var isValue: Bool {
        switch self {
        case .value:
            return true
        case .calculating, .invalid:
            return false
        }
    }

    /// Returns `true` if is invalid
    public var isInvalid: Bool {
        switch self {
        case .invalid:
            return true
        case .calculating, .value:
            return false
        }
    }

    public var isCalculating: Bool {
        switch self {
        case .calculating:
            return true
        case .invalid, .value:
            return false
        }
    }
}

extension ValueCalculationState: Equatable where Value: Equatable {}
