// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

final class KYCTiersCoordinator {

    private weak var interface: KYCTiersInterface?
    private let pageModelFactory: KYCTiersPageModelFactoryAPI
    private var disposable: Disposable?

    init(
        interface: KYCTiersInterface?,
        pageModelFactory: KYCTiersPageModelFactoryAPI = resolve()
    ) {
        self.interface = interface
        self.pageModelFactory = pageModelFactory
    }

    func refreshViewModel(suppressCTA: Bool) {
        interface?.collectionViewVisibility(.hidden)
        interface?.loadingIndicator(.visible)

        disposable = pageModelFactory.tiersPageModel(suppressCTA: suppressCTA)
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(
                onSuccess: { [weak self] page in
                    guard let self = self else { return }
                    self.interface?.apply(page)
                    self.interface?.loadingIndicator(.hidden)
                    self.interface?.collectionViewVisibility(.visible)
                },
                onError: { [weak self] _ in
                    guard let self = self else { return }
                    self.interface?.loadingIndicator(.hidden)
                    self.interface?.collectionViewVisibility(.visible)
                }
            )
    }
}
