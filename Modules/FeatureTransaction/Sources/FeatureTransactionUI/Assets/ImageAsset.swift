// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

enum ImageAsset: String {
    case iconSend = "icon_send"
    case iconReceive = "icon_receive"
    case iconReceiveGray = "icon_receive_gray"
    case iconVerified = "icon_verified"

    var imageResource: ImageResource {
        .local(name: rawValue, bundle: .featureTransactionUI)
    }
}
