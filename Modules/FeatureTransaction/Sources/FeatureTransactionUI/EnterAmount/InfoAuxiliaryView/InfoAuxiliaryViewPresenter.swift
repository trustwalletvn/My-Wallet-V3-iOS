// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import UIKit

final class InfoAuxiliaryViewPresenter: AuxiliaryViewPresenting {

    private let transactionState: TransactionState

    init(transactionState: TransactionState) {
        self.transactionState = transactionState
    }

    func makeViewController() -> UIViewController {
        let viewController = UIViewController()
        let topInfoView = makeTopInfoView()
        viewController.view.addSubview(topInfoView)
        topInfoView.constraint(edgesTo: viewController.view)
        return viewController
    }

    private func makeTopInfoView() -> UIView {
        let topInfoView = SelectionButtonView()
        topInfoView.viewModel = SelectionButtonViewModel(showSeparator: false)

        let topSelectionTitle = TransactionFlowDescriptor.EnterAmountScreen
            .headerTitle(state: transactionState)
        let topSelectionSubtitle = TransactionFlowDescriptor.EnterAmountScreen
            .headerSubtitle(state: transactionState)
        topInfoView.viewModel.titleRelay.accept(topSelectionTitle)
        topInfoView.viewModel.titleAccessibilityRelay.accept(
            .id(Accessibility.Identifier.ContentLabelView.title)
                .copy(label: topSelectionTitle)
        )
        topInfoView.viewModel.subtitleRelay.accept(topSelectionSubtitle)
        topInfoView.viewModel.subtitleAccessibilityRelay.accept(
            .id(Accessibility.Identifier.ContentLabelView.description)
                .copy(label: topSelectionSubtitle)
        )
        topInfoView.viewModel.isButtonEnabledRelay.accept(transactionState.nextEnabled)
        topInfoView.viewModel.leadingContentTypeRelay.accept(.none)

        let transactionImageViewModel = TransactionDescriptorViewModel(
            sourceAccount: transactionState.source as? SingleAccount,
            destinationAccount: transactionState.action == .swap ? transactionState.destination as? SingleAccount : nil,
            assetAction: transactionState.action,
            adjustActionIconColor: transactionState.action != .swap
        )
        topInfoView.viewModel.trailingContentRelay.accept(.transaction(transactionImageViewModel))

        let titleDescriptor: (font: UIFont, textColor: UIColor) = (
            font: .main(.medium, 12.0),
            textColor: .descriptionText
        )
        topInfoView.viewModel.titleFontRelay.accept(titleDescriptor.font)
        topInfoView.viewModel.titleFontColor.accept(titleDescriptor.textColor)

        let subtitleDescriptor: (font: UIFont, textColor: UIColor) = (
            font: .main(.semibold, 14.0),
            textColor: .titleText
        )
        topInfoView.viewModel.subtitleFontRelay.accept(subtitleDescriptor.font)
        topInfoView.viewModel.subtitleFontColor.accept(subtitleDescriptor.textColor)

        return topInfoView
    }
}
