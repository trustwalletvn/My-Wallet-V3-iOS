// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
import RxSwift

class WalletServiceMock: WalletOptionsAPI {

    var underlyingServerUnderMaintenanceMessage: String?
    var serverUnderMaintenanceMessage: Single<String?> {
        .just(underlyingServerUnderMaintenanceMessage)
    }

    var underlyingWalletOptions: WalletOptions = .empty
    var walletOptions: Single<WalletOptions> {
        .just(underlyingWalletOptions)
    }

    var serverStatus: Single<ServerIncidents> {
        .just(ServerIncidents(page: .init(id: "", name: "", url: ""), incidents: []))
    }
}

extension WalletOptions {
    static var empty: WalletOptions {
        WalletOptions(json: ["maintenance": false])
    }
}
