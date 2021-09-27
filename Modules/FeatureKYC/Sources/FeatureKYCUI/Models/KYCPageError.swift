// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

enum KYCPageError {
    case countryNotSupported(CountryData)
    case stateNotSupported(KYCState)
}
