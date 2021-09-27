// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxRelay
import ToolKit

extension DependencyContainer {

    // MARK: - Today Extension Module

    static var today = module {

        factory { AnalyticsServiceMock() as AnalyticsEventRecorderAPI }

        factory { UIDevice.current as DeviceInfo }

        factory { FiatCurrencyService() as FiatCurrencyServiceAPI }

        factory { ErrorRecorderMock() as ErrorRecording }
    }
}

extension UIDevice: DeviceInfo {
    public var uuidString: String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
}
