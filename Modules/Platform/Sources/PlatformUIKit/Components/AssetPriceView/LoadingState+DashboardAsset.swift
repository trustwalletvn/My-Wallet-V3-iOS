// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension LoadingState where Content == DashboardAsset.Value.Presentation.AssetPrice {
    init(
        with state: LoadingState<DashboardAsset.Value.Interaction.AssetPrice>,
        descriptors: DashboardAsset.Value.Presentation.AssetPrice.Descriptors
    ) {
        switch state {
        case .loading:
            self = .loading
        case .loaded(next: let content):
            self = .loaded(
                next: .init(
                    with: content,
                    descriptors: descriptors
                )
            )
        }
    }
}

extension LoadingState where Content == AssetBalanceViewModel.Value.Presentation {
    init(
        with state: LoadingState<AssetBalanceViewModel.Value.Interaction>,
        alignment: UIStackView.Alignment,
        descriptors: AssetBalanceViewModel.Value.Presentation.Descriptors
    ) {
        switch state {
        case .loading:
            self = .loading
        case .loaded(next: let content):
            self = .loaded(
                next: .init(
                    with: content,
                    alignment: alignment,
                    descriptors: descriptors
                )
            )
        }
    }
}
