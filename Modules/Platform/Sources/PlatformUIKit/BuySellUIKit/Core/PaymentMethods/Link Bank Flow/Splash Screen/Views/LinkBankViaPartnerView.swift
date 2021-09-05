// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import UIKit

class LinkBankViaPartnerView: UIView {

    private let blockchainLogo = UIImageView()
    fileprivate let partnerImageView = UIImageView()
    private let partnerBackgroundImageView = UIImageView()
    private let bankIcon = UIImageView()
    private let line = UIView()

    init() {
        super.init(frame: .zero)

        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {

        // Static content
        blockchainLogo.translatesAutoresizingMaskIntoConstraints = false
        blockchainLogo.contentMode = .center
        blockchainLogo.image = UIImage(named: "link-bank-splash-bc-icon", in: .module, compatibleWith: nil)
        bankIcon.translatesAutoresizingMaskIntoConstraints = false
        bankIcon.contentMode = .center
        bankIcon.image = UIImage(named: "link-bank-splash-bank-icon", in: .module, compatibleWith: nil)
        line.backgroundColor = Color.darkBlueBackground

        partnerBackgroundImageView.contentMode = .center
        partnerBackgroundImageView.image = UIImage(named: "splash-screen-partner-bg", in: .module, compatibleWith: nil)
        partnerBackgroundImageView.translatesAutoresizingMaskIntoConstraints = false

        partnerImageView.contentMode = .center
        partnerImageView.translatesAutoresizingMaskIntoConstraints = false
        partnerBackgroundImageView.addSubview(partnerImageView)

        let stackView = UIStackView(arrangedSubviews: [blockchainLogo, partnerBackgroundImageView, bankIcon])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill

        stackView.insertSubview(line, at: 0)
        addSubview(stackView)

        stackView.layoutToSuperview(.top, .bottom)
        stackView.layoutToSuperview(.leading, offset: Spacing.outer)
        stackView.layoutToSuperview(.trailing, offset: -Spacing.outer)
        partnerImageView.layout(size: .edge(72))

        partnerImageView.layoutToSuperview(.centerX)
        partnerImageView.layoutToSuperview(.centerY)

        line.layout(dimension: .height, to: 2)
        line.layoutToSuperview(.centerY)
        line.layout(edge: .leading, to: .centerX, of: blockchainLogo, relation: .equal)
        line.layout(edge: .trailing, to: .centerX, of: bankIcon, relation: .equal)
    }
}

extension Reactive where Base: LinkBankViaPartnerView {
    var partnerImageViewContent: Binder<ImageViewContent> {
        base.partnerImageView.rx.content
    }
}
