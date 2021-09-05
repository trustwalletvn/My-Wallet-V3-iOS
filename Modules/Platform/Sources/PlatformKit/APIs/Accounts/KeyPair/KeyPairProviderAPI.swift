// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxSwift

public protocol KeyPairProviderAPI {
    associatedtype Pair: KeyPair

    var keyPair: Single<Pair> { get }

    func keyPair(with secondPassword: String?) -> Single<Pair>
}

public final class AnyKeyPairProvider<Pair: KeyPair>: KeyPairProviderAPI {

    // MARK: - KeyPairProviderAPI

    public var keyPair: Single<Pair> {
        keyPairProvider
    }

    public func keyPair(with secondPassword: String?) -> Single<Pair> {
        keyPairWithSecondPasswordProvider(secondPassword)
    }

    // MARK: - Private methods

    private let keyPairProvider: Single<Pair>
    private let keyPairWithSecondPasswordProvider: (String?) -> Single<Pair>
    /// Strong opaque reference to Provider.
    /// We do this because `keyPairProvider` and `keyPairWithSecondPasswordProvider` may depend on a reference of `self: KeyPairProviderAPI`
    private let provider: Any

    // MARK: - Init

    public init<P: KeyPairProviderAPI>(provider: P) where P.Pair == Pair {
        self.provider = provider
        keyPairProvider = provider.keyPair
        keyPairWithSecondPasswordProvider = provider.keyPair
    }
}
