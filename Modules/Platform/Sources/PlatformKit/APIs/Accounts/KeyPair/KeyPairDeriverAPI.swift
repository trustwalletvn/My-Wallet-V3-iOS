// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol KeyPairDeriverAPI {
    associatedtype Pair: KeyPair
    associatedtype Input: KeyDerivationInput
    associatedtype Error: Swift.Error

    /// Derives a `KeyPair` given specific inputs (e.g. mnemonic + password)
    /// This action is deterministic (i.e. the same mnemonic + password combination will create the
    /// same key pair).
    ///
    /// - Parameter input: The specific inputs used to derive the key pair
    /// - Returns: A `Result` for the created `KeyPair`
    func derive(input: Input) -> Result<Pair, Error>
}

public struct AnyKeyPairDeriver<P: KeyPair, I: KeyDerivationInput, E: Error>: KeyPairDeriverAPI {

    public typealias Deriver = (I) -> Result<P, E>

    private let derivingClosure: Deriver

    public init<D: KeyPairDeriverAPI>(deriver: D) where D.Pair == P, D.Input == I, D.Error == E {
        derivingClosure = deriver.derive
    }

    public func derive(input: I) -> Result<P, E> {
        derivingClosure(input)
    }
}
