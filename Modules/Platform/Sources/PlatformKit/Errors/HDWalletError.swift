// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct HDWalletError: CodeLocationError {

    public var message: String
    public var location: CodeLocation

    public init(message: String, location: CodeLocation) {
        self.message = message
        self.location = location
    }
}

extension HDWalletError {

    public static func walletFailedToInitialise(
        _ function: String = #function,
        _ file: String = #file,
        _ line: Int = #line
    ) -> HDWalletError {
        .init("HDWallet failed to initialise", function, file, line)
    }
}
