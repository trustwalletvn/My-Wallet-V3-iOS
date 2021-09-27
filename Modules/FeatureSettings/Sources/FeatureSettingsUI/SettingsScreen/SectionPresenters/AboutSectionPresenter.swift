// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

final class AboutSectionPresenter: SettingsSectionPresenting {
    let sectionType: SettingsSectionType = .about
    var state: Observable<SettingsSectionLoadingState> {
        .just(
            .loaded(next:
                .some(
                    .init(
                        sectionType: sectionType,
                        items: [
                            .init(cellType: .plain(.rateUs)),
                            .init(cellType: .plain(.termsOfService)),
                            .init(cellType: .plain(.privacyPolicy)),
                            .init(cellType: .plain(.cookiesPolicy))
                        ]
                    )
                )
            )
        )
    }
}
