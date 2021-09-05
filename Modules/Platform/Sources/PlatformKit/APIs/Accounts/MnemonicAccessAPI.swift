// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public typealias Mnemonic = String

public enum MnemonicAccessError: Error {
    case generic
}

/// Users can double encrypt their wallet. If this is the case, sometimes users will
/// need to enter in their secondary password before performing certain actions. This is
/// **not** currency or asset specific
public protocol MnemonicAccessAPI {

    /// Returns a Maybe emitting a Mnemonic if and only if the mnemonic is not double encrypted
    var mnemonic: Maybe<Mnemonic> { get }

    func mnemonic(with secondPassword: String?) -> Single<Mnemonic>

    /// Returns a Maybe emitting a Mnemonic. This will prompt the user to enter the second password if needed.
    var mnemonicPromptingIfNeeded: Maybe<Mnemonic> { get }
}
