// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public protocol OnChainTransactionEngineFactory {
    func build(requiresSecondPassword: Bool) -> OnChainTransactionEngine
}
