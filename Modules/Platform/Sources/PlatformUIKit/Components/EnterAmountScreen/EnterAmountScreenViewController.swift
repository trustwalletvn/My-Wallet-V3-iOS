// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

/// A screen that allows the end-user to specify an amount for an asset or account
/// Designed to be used in Buy, Sell, Swap & Send.
public final class EnterAmountScreenViewController: BaseScreenViewController {

    // MARK: - Types

    private enum Constant {
        enum SuperCompact {
            static let digitPadHeight: CGFloat = 216
            static let continueButtonViewBottomOffset: CGFloat = 16
            static let topSelectionViewHeight: CGFloat = 48
            static let bottomAuxiliaryViewOffset: CGFloat = 8
        }

        enum Standard {
            static let topSelectionViewHeight: CGFloat = 78
        }
    }

    // MARK: - Properties

    private let topSelectionButtonView = SelectionButtonView()
    private var amountTranslationView: AmountTranslationView!
    private let bottomAuxiliaryItemSeparatorView = TitledSeparatorView()
    private let bottomAuxiliaryView = UIView()
    private let continueButtonView = ButtonView()
    private let digitPadView = DigitPadView()

    private var topSelectionViewHeightConstraint: NSLayoutConstraint!
    private var bottomAuxiliaryButtonViewHeightConstraint: NSLayoutConstraint!
    private var digitPadHeightConstraint: NSLayoutConstraint!
    private var continueButtonTopConstraint: NSLayoutConstraint!
    private var digitPadSeparatorTopConstraint: NSLayoutConstraint!

    // MARK: - Injected

    private let presenter: EnterAmountScreenPresenter
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    public init(presenter: EnterAmountScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override public func loadView() {
        view = UIView()
        view.backgroundColor = .white

        let digitPadTopSeparatorView = UIView()

        amountTranslationView = AmountTranslationView(presenter: presenter.amountTranslationPresenter)

        view.addSubview(topSelectionButtonView)
        view.addSubview(amountTranslationView)
        view.addSubview(bottomAuxiliaryItemSeparatorView)
        view.addSubview(bottomAuxiliaryView)
        view.addSubview(continueButtonView)
        view.addSubview(digitPadTopSeparatorView)
        view.addSubview(digitPadView)

        topSelectionButtonView.layoutToSuperview(.top, usesSafeAreaLayoutGuide: true)
        topSelectionButtonView.layoutToSuperview(axis: .horizontal)
        topSelectionViewHeightConstraint = topSelectionButtonView.layout(dimension: .height, to: 78)

        amountTranslationView.layoutToSuperview(axis: .horizontal)
        amountTranslationView.layout(edge: .top, to: .bottom, of: topSelectionButtonView)

        bottomAuxiliaryItemSeparatorView.layout(edge: .top, to: .bottom, of: amountTranslationView)
        bottomAuxiliaryItemSeparatorView.layoutToSuperview(.leading, offset: 24, priority: .defaultHigh)
        bottomAuxiliaryItemSeparatorView.layoutToSuperview(.trailing)

        bottomAuxiliaryView.layoutToSuperview(.leading, .trailing)
        bottomAuxiliaryView.layout(
            edge: .top,
            to: .bottom,
            of: bottomAuxiliaryItemSeparatorView,
            priority: .defaultLow
        )
        bottomAuxiliaryButtonViewHeightConstraint = bottomAuxiliaryView.layout(
            dimension: .height,
            to: 1
        )

        continueButtonView.layoutToSuperview(axis: .horizontal, offset: 24, priority: .penultimateHigh)
        continueButtonTopConstraint = continueButtonView.layout(
            edge: .top,
            to: .bottom,
            of: bottomAuxiliaryView,
            offset: 16
        )
        continueButtonView.layout(dimension: .height, to: 48)

        digitPadTopSeparatorView.layoutToSuperview(.leading, .trailing)
        digitPadSeparatorTopConstraint = digitPadTopSeparatorView.layout(
            edge: .top,
            to: .bottom,
            of: continueButtonView,
            offset: 24
        )
        digitPadTopSeparatorView.layout(dimension: .height, to: 1)

        digitPadView.layoutToSuperview(axis: .horizontal, priority: .penultimateHigh)
        digitPadView.layout(edge: .top, to: .bottom, of: digitPadTopSeparatorView)
        digitPadView.layoutToSuperview(.bottom, usesSafeAreaLayoutGuide: true)
        digitPadHeightConstraint = digitPadView.layout(dimension: .height, to: 260, priority: .penultimateHigh)

        digitPadTopSeparatorView.backgroundColor = presenter.displayBundle.colors.digitPadTopSeparator
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        digitPadView.viewModel = presenter.digitPadViewModel
        continueButtonView.viewModel = presenter.continueButtonViewModel
        topSelectionButtonView.viewModel = presenter.topSelectionButtonViewModel
        bottomAuxiliaryItemSeparatorView.viewModel = presenter.bottomAuxiliaryItemSeparatorViewModel
        setupBottomAuxiliaryView()
        presenter.viewDidLoad()

        let digitInput = digitPadView.viewModel
            .valueObservable
            .asDriverCatchError()

        let deleteInput = digitPadView.viewModel
            .backspaceButtonTapObservable
            .asDriverCatchError()

        let amountViewInputs = [
            digitInput
                .compactMap(\.first)
                .map { AmountPresenterInput.input($0) },
            deleteInput.map { AmountPresenterInput.delete }
        ]

        amountTranslationView.connect(input: Driver.merge(amountViewInputs))
            .drive()
            .disposed(by: disposeBag)
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
        setupNavigationBar()
    }

    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDidDisappear()
    }

    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        /// NOTE: This must be in `viewWillLayoutSubviews`
        /// This is a special treatment due to the manner view controllers
        /// are modally displayed on iOS 13 (with additional gap on the top that enable
        /// dismissal of the screen.
        if view.bounds.height <= UIDevice.PhoneHeight.eight.rawValue {
            digitPadHeightConstraint.constant = Constant.SuperCompact.digitPadHeight
            digitPadSeparatorTopConstraint.constant = Constant.SuperCompact.continueButtonViewBottomOffset
            if view.bounds.height <= UIDevice.PhoneHeight.se.rawValue {
                continueButtonTopConstraint.constant = Constant.SuperCompact.bottomAuxiliaryViewOffset
                topSelectionViewHeightConstraint.constant = Constant.SuperCompact.topSelectionViewHeight
            }
        }
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        titleViewStyle = .text(value: presenter.title)
        setStandardDarkContentStyle()
    }

    private func setupBottomAuxiliaryView() {
        presenter.bottomAuxiliaryViewModelState
            .drive(
                onNext: { [weak self] state in
                    self?.bottomAuxiliaryViewModelStateDidChange(to: state)
                }
            )
            .disposed(by: disposeBag)
    }

    private func bottomAuxiliaryViewModelStateDidChange(to state: EnterAmountScreenPresenter.BottomAuxiliaryViewModelState) {
        let height: CGFloat
        let visibility: Visibility
        var subviewsToRemove: [UIView]
        switch state {
        case .hidden:
            height = 0.5
            visibility = .hidden
            subviewsToRemove = bottomAuxiliaryView.subviews
        case .selection(let viewModel):
            let selectionButtonView = SelectionButtonView()
            bottomAuxiliaryView.addSubview(selectionButtonView)
            selectionButtonView.fillSuperview()
            selectionButtonView.viewModel = viewModel
            visibility = .visible
            if presenter.deviceType == .superCompact {
                height = Constant.SuperCompact.topSelectionViewHeight
            } else {
                height = Constant.Standard.topSelectionViewHeight
            }
            subviewsToRemove = []
        case .maxAvailable(let presenter):
            let sendAuxiliaryView = SendAuxiliaryView()
            sendAuxiliaryView.presenter = presenter
            bottomAuxiliaryView.addSubview(sendAuxiliaryView)
            sendAuxiliaryView.fillSuperview()
            visibility = .visible
            height = Constant.Standard.topSelectionViewHeight
            subviewsToRemove = []
        }
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: [.beginFromCurrentState, .curveEaseOut],
            animations: {
                self.bottomAuxiliaryItemSeparatorView.alpha = visibility.defaultAlpha
                self.bottomAuxiliaryView.alpha = visibility.defaultAlpha
                self.bottomAuxiliaryButtonViewHeightConstraint.constant = height
            },
            completion: { _ in
                subviewsToRemove.forEach { $0.removeFromSuperview() }
            }
        )
    }

    // MARK: - Navigation

    override public func navigationBarLeadingButtonPressed() {
        presenter.previous()
    }

    override public func navigationBarTrailingButtonPressed() {
        presenter.previous()
    }
}
