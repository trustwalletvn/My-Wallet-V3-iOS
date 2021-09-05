// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RxCocoa
import RxDataSources

public final class LinkedBankViewModel: LinkedBankViewModelAPI {

    // MARK: - Types

    private typealias AccessibilityId = Accessibility.Identifier.LinkedBankView

    // MARK: - Properties

    public let data: LinkedBankData

    public let nameLabelContent: LabelContent
    public let limitLabelContent: LabelContent
    public let accountLabelContent: LabelContent
    public let badgeImageViewModel: BadgeImageViewModel

    public let isCustomButtonEnabled: Bool = true

    public let tapRelay = PublishRelay<Void>()
    public var tap: Signal<Void> {
        tapRelay.asSignal()
    }

    // MARK: - Setup

    public init(data: LinkedBankData) {
        self.data = data

        badgeImageViewModel = .primary(
            image: .local(name: "icon-bank", bundle: .platformUIKit),
            cornerRadius: .round,
            accessibilityIdSuffix: data.identifier
        )
        badgeImageViewModel.marginOffsetRelay.accept(6)

        nameLabelContent = LabelContent(
            text: data.account?.bankName ?? "",
            font: .main(.semibold, 16),
            color: .titleText,
            accessibility: .id("\(AccessibilityId.name)\(data.identifier)")
        )

        let bankName = data.account?.bankName ?? ""
        let accountType = data.account?.type.title ?? ""
        let accountNumber = data.account?.number ?? ""
        let detailsTitle = "\(bankName) \(accountType) \(accountNumber)"
        limitLabelContent = LabelContent(
            text: detailsTitle,
            font: .main(.medium, 14),
            color: .descriptionText,
            accessibility: .id("\(AccessibilityId.limits)\(data.identifier)")
        )

        accountLabelContent = LabelContent(
            text: "",
            font: .main(.semibold, 16),
            color: .titleText,
            accessibility: .id("\(AccessibilityId.account)\(data.identifier)")
        )
    }
}

extension LinkedBankViewModel: IdentifiableType {
    public var identity: String {
        data.identifier
    }
}

extension LinkedBankViewModel: Equatable {
    public static func == (lhs: LinkedBankViewModel, rhs: LinkedBankViewModel) -> Bool {
        lhs.data == rhs.data
    }
}

extension Accessibility.Identifier {
    fileprivate enum LinkedBankView {
        private static let prefix = "LinkedBankView."
        static let image = "\(prefix)image"
        static let name = "\(prefix)name."
        static let limits = "\(prefix)limits."
        static let account = "\(prefix)account."
    }
}
