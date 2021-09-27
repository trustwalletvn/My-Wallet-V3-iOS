// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import UIKit

@available(*, deprecated, message: "Use PrimaryButtonContainer instead, it has the necessary activityIndicator")
class PrimaryButton: UIButton {

    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
            super.alpha = alpha
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layer.cornerRadius = 4.0
        titleLabel?.font = UIFont(name: Constants.FontNames.montserratMedium, size: 20.0)
        backgroundColor = UIColor.brandSecondary
    }

    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        titleLabel?.text = title
    }
}
