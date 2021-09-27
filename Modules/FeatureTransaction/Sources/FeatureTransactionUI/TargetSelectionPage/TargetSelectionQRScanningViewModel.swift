// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformUIKit

struct TargetSelectionQRScanningViewModel: QRCodeScannerTextViewModel {
    let loadingText: String? = nil
    let headerText: String = LocalizationConstants.scanQRCode
}
