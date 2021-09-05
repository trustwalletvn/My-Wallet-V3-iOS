// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class FormPresentationStateReducer {

    // MARK: - Types

    public enum ReducingError: Error {

        /// Imput sent to reducer is an empty collection
        case forbiddenEmptyInput

        /// Unexpectedly, could not reduce the input into `FormPresentationState`
        case unreduceableInput
    }

    // MARK: - Setup

    public init() {}

    // MARK: - API

    public func reduce(states: [TextFieldViewModel.State]) throws -> FormPresentationState {
        guard !states.isEmpty else { throw ReducingError.forbiddenEmptyInput }
        if states.count > 1, states.areAllElements(equal: .valid(value: "")) {
            return .valid
        }
        if states.contains(.empty) {
            return .invalid(.emptyTextField)
        }
        if (states.contains { $0.isInvalid }) {
            return .invalid(.invalidTextField)
        }
        if (states.contains { $0.isMismatch }) {
            return .invalid(.invalidTextField)
        }
        return .valid
    }
}
