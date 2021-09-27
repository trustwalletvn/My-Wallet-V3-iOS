// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

final class AccountAuxiliaryView: UIView {

    // MARK: - Public Properties

    var presenter: AccountAuxiliaryViewPresenter! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            presenter
                .titleLabel
                .drive(titleLabel.rx.content)
                .disposed(by: disposeBag)

            presenter
                .subtitleLabel
                .drive(subtitleLabel.rx.content)
                .disposed(by: disposeBag)

            presenter
                .badgeImageViewModel
                .drive(badgeImageView.rx.viewModel)
                .disposed(by: disposeBag)

            presenter
                .buttonEnabled
                .drive(button.rx.isEnabled)
                .disposed(by: disposeBag)

            button.rx
                .controlEvent(.touchUpInside)
                .bindAndCatch(to: presenter.tapRelay)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private Properties

    private let button = UIButton()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stackView = UIStackView()
    private let separatorView = UIView()
    private let disclosureImageView = UIImageView()
    private let tapGestureRecognizer = UITapGestureRecognizer()
    private let badgeImageView = BadgeImageView()
    private var disposeBag = DisposeBag()

    init() {
        super.init(frame: UIScreen.main.bounds)

        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        addSubview(badgeImageView)
        addSubview(separatorView)
        addSubview(disclosureImageView)
        addSubview(button)

        button.fillSuperview()
        badgeImageView.layoutToSuperview(.centerY)
        badgeImageView.layoutToSuperview(.leading, offset: Spacing.outer)

        disclosureImageView.layoutToSuperview(.trailing, offset: -24)
        disclosureImageView.layoutToSuperview(.centerY)

        disclosureImageView.set(
            ImageViewContent(
                imageResource: .local(name: "icon-disclosure-small", bundle: .platformUIKit)
            )
        )

        stackView.layoutToSuperview(.centerY)
        stackView.layout(edge: .leading, to: .trailing, of: badgeImageView, offset: Spacing.inner)

        stackView.axis = .vertical
        stackView.spacing = 4.0

        separatorView.backgroundColor = .lightBorder
        separatorView.layoutToSuperview(.leading, .trailing, .top)
        separatorView.layout(dimension: .height, to: 1)

        button.addTargetForTouchDown(self, selector: #selector(touchDown))
        button.addTargetForTouchUp(self, selector: #selector(touchUp))
    }

    required init?(coder: NSCoder) { unimplemented() }

    // MARK: - Private Functions

    @objc
    private func touchDown() {
        backgroundColor = .hightlightedBackground
    }

    @objc
    private func touchUp() {
        backgroundColor = .white
    }
}
