// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct BadgeNumberedItemViewModel {
    let badgeViewModel: BadgeViewModel
    let titleLabelContent: LabelContent
    let descriptionLabelContent: LabelContent

    public struct Descriptors {
        let titleFont: UIFont
        let titleTextColor: UIColor
        let titleAccessibility: Accessibility
        let descriptionFont: UIFont
        let descriptionTextColor: UIColor
        let descriptionAccessibility: Accessibility
        let badgeAccessibilitySuffix: String
    }

    public init(
        number: Int,
        title: String,
        description: String,
        descriptors: Descriptors
    ) {
        badgeViewModel = .default(
            with: "\(number)",
            font: .main(.semibold, 20.0),
            cornerRadius: Sizing.badge / 2.0,
            accessibilityId: descriptors.badgeAccessibilitySuffix
        )
        titleLabelContent = .init(
            text: title,
            font: descriptors.titleFont,
            color: descriptors.titleTextColor,
            alignment: .left,
            accessibility: descriptors.titleAccessibility
        )
        descriptionLabelContent = .init(
            text: description,
            font: descriptors.descriptionFont,
            color: .textFieldText,
            alignment: .left,
            accessibility: descriptors.descriptionAccessibility
        )
    }
}

extension BadgeNumberedItemViewModel.Descriptors {
    public typealias Descriptors = BadgeNumberedItemViewModel.Descriptors

    public static func dashboard(badgeAccessibilitySuffix: String) -> Descriptors {
        Descriptors(
            titleFont: .main(.semibold, 16.0),
            titleTextColor: .textFieldText,
            titleAccessibility: .none,
            descriptionFont: .main(.medium, 12.0),
            descriptionTextColor: .descriptionText,
            descriptionAccessibility: .none,
            badgeAccessibilitySuffix: badgeAccessibilitySuffix
        )
    }
}
