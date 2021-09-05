// Copyright © Blockchain Luxembourg S.A. All rights reserved.
import Combine
import RxCocoa
import RxSwift
import WalletPayloadKit

class MockWalletUpgradeService: WalletUpgradeServicing {
    var needsWalletUpgradeRelay = BehaviorSubject<Bool>(value: false)

    var needsWalletUpgrade: Single<Bool> {
        needsWalletUpgradeRelay.asSingle()
    }

    var needsWalletUpgradePublisher: AnyPublisher<Bool, Error> {
        needsWalletUpgradeRelay.asPublisher()
    }

    init() {}

    func upgradeWallet() -> Observable<String> {
        .just("")
    }
}
