// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RxSwift

public enum BadgeAsset {

    public enum State {

        /// The state of the `BadgeItem` interactor and presenter
        public enum BadgeItem {
            public typealias Interaction = LoadingState<Value.Interaction.BadgeItem>
            public typealias Presentation = LoadingState<Value.Presentation.BadgeItem>
        }
    }

    public enum Value {
        public enum Interaction {
            public struct BadgeItem: Equatable {

                public enum BadgeType: Equatable {
                    case `default`(accessibilitySuffix: String)
                    case verified
                    case warning
                    case destructive
                    case progress(BadgeCircleViewModel)

                    public static func == (
                        lhs: BadgeAsset.Value.Interaction.BadgeItem.BadgeType,
                        rhs: BadgeAsset.Value.Interaction.BadgeItem.BadgeType
                    ) -> Bool {
                        switch (lhs, rhs) {
                        case (.default, .default),
                             (.verified, .verified),
                             (.destructive, .destructive),
                             (.progress, .progress),
                             (.warning, .warning):
                            return true
                        default:
                            return false
                        }
                    }
                }

                public let type: BadgeType

                // TODO-Settings: Should not be in the interaction layer
                public let description: String

                public init(type: BadgeType, description: String) {
                    self.type = type
                    self.description = description
                }
            }
        }

        public enum Presentation {
            public struct BadgeItem {

                public let viewModel: BadgeViewModel

                public init(with value: Interaction.BadgeItem) {
                    switch value.type {
                    case .default(accessibilitySuffix: let suffix):
                        viewModel = .default(with: value.description, accessibilityId: suffix)
                    case .destructive:
                        viewModel = .destructive(with: value.description)
                    case .verified:
                        viewModel = .affirmative(with: value.description)
                    case .progress(let model):
                        viewModel = .progress(with: value.description, model: model)
                    case .warning:
                        viewModel = .warning(with: value.description)
                    }
                }
            }
        }
    }
}

extension BadgeAsset.Value.Interaction.BadgeItem {
    public static let verified: BadgeAsset.Value.Interaction.BadgeItem = .init(
        type: .verified,
        description: LocalizationConstants.verified
    )

    public static let unverified: BadgeAsset.Value.Interaction.BadgeItem = .init(
        type: .destructive,
        description: LocalizationConstants.unverified
    )

    public static let connect: BadgeAsset.Value.Interaction.BadgeItem = .init(
        type: .default(accessibilitySuffix: "Connect"),
        description: LocalizationConstants.Exchange.connect
    )

    public static let confirmed: BadgeAsset.Value.Interaction.BadgeItem = .init(
        type: .default(accessibilitySuffix: "Confirmed"),
        description: LocalizationConstants.Settings.Badge.confirmed
    )

    public static let unconfirmed: BadgeAsset.Value.Interaction.BadgeItem = .init(
        type: .destructive,
        description: LocalizationConstants.Settings.Badge.unconfirmed
    )

    public static let connected: BadgeAsset.Value.Interaction.BadgeItem = .init(
        type: .default(accessibilitySuffix: "Connected"),
        description: LocalizationConstants.Exchange.connected
    )
}

extension LoadingState where Content == BadgeAsset.Value.Presentation.BadgeItem {
    public init(with state: LoadingState<BadgeAsset.Value.Interaction.BadgeItem>) {
        switch state {
        case .loading:
            self = .loading
        case .loaded(next: let content):
            self = .loaded(next: .init(with: content))
        }
    }
}
