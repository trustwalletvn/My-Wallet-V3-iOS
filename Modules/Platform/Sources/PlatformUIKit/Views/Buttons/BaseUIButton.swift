// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

@IBDesignable
public class BaseUIButton: UIButton {

    @IBInspectable public var showShadow: Bool = false {
        didSet {
            setup()
        }
    }

    @IBInspectable public var cornerRadius: CGFloat = 0.0 {
        didSet {
            setupLayout()
        }
    }

    public var shadowColor: UIColor = .black {
        didSet {
            setup()
        }
    }

    public var shadowOpacity: CGFloat = 0.20 {
        didSet {
            setup()
        }
    }

    func setup() {
        titleLabel?.font = Font(.branded(.montserratSemiBold), size: .custom(20.0)).result

        if showShadow {
            layer.shadowColor = shadowColor.cgColor
            layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
            layer.shadowRadius = 8.0
            layer.shadowOpacity = Float(shadowOpacity)
            clipsToBounds = false
            layer.masksToBounds = false
        }
    }

    func setupLayout() {
        layer.cornerRadius = cornerRadius
    }

    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupLayout()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: Overrides

    override public func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }
}

@IBDesignable
public class BaseUIButtonFill: BaseUIButton {

    @IBInspectable var fillColor: UIColor = .brandSecondary {
        didSet {
            setup()
        }
    }

    @IBInspectable var textColor: UIColor = .white {
        didSet {
            self.setup()
        }
    }

    override func setup() {
        super.setup()
        setTitleColor(textColor, for: .normal)
        backgroundColor = fillColor
    }
}
