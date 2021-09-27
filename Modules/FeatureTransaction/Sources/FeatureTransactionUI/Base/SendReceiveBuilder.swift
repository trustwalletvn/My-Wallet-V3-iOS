// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import PlatformUIKit
import UIKit

public final class ReceiveBuilder {
    private typealias LocalizedReceive = LocalizationConstants.Receive

    private let receiveSelectionService: AccountSelectionServiceAPI

    init(receiveSelectionService: AccountSelectionServiceAPI) {
        self.receiveSelectionService = receiveSelectionService
    }

    var receiveAccountPickerRouter: AccountPickerRouting!

    public func receive() -> UIViewController {
        let header = AccountPickerHeaderModel(
            title: LocalizedReceive.Header.receiveCryptoNow,
            subtitle: LocalizedReceive.Header.chooseAWalletToReceiveTo,
            imageContent: .init(
                imageResource: ImageAsset.iconReceive.imageResource,
                accessibility: .none,
                renderingMode: .normal
            )
        )
        let navigationModel = ScreenNavigationModel(
            leadingButton: .drawer,
            trailingButton: .none,
            titleViewStyle: .text(value: LocalizedReceive.Text.request),
            barStyle: .lightContent()
        )
        let accountProvider = AccountPickerAccountProvider(
            singleAccountsOnly: true,
            action: .receive,
            failSequence: false
        )
        let builder = AccountPickerBuilder(
            accountProvider: accountProvider,
            action: .receive
        )
        let didSelect: AccountPickerDidSelect = { [weak self] account in
            self?.receiveSelectionService.record(selection: account)
        }
        receiveAccountPickerRouter = builder.build(
            listener: .simple(didSelect),
            navigationModel: navigationModel,
            headerModel: .default(header)
        )
        receiveAccountPickerRouter.interactable.activate()
        receiveAccountPickerRouter.load()
        return receiveAccountPickerRouter.viewControllable.uiviewController
    }
}
