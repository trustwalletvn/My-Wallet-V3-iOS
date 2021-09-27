// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

protocol SettingsSectionPresenting: AnyObject {
    var sectionType: SettingsSectionType { get }
    var state: Observable<SettingsSectionLoadingState> { get }
}
