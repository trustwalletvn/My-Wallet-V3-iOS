// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import UIKit

final class WithdrawAmountViewController: BaseScreenViewController,
    WithdrawAmountViewControllable,
    WithdrawAmountPagePresentable
{

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
    private let amountViewable: AmountViewable
    private let bottomAuxiliaryItemSeparatorView = TitledSeparatorView()
    private let bottomAuxiliaryView = UIView()
    private let continueButtonView = ButtonView()
    private let digitPadView = DigitPadView()

    private var topSelectionViewHeightConstraint: NSLayoutConstraint!
    private var bottomAuxiliaryButtonViewHeightConstraint: NSLayoutConstraint!
    private var digitPadHeightConstraint: NSLayoutConstraint!
    private var continueButtonTopConstraint: NSLayoutConstraint!
    private var digitPadSeparatorTopConstraint: NSLayoutConstraint!

    private let closeTriggerred = PublishSubject<Void>()
    private let backTriggered = PublishSubject<Void>()

    internal let continueButtonTapped: Signal<Void>

    // MARK: - WithdrawAmountPagePresentable

    // MARK: - Injected

    private let displayBundle: DisplayBundle
    private let devicePresenterType: DevicePresenter.DeviceType
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init(
        displayBundle: DisplayBundle,
        devicePresenterType: DevicePresenter.DeviceType = DevicePresenter.type,
        digitPadViewModel: DigitPadViewModel,
        continueButtonViewModel: ButtonViewModel,
        topSelectionButtonViewModel: SelectionButtonViewModel,
        amountViewProvider: AmountViewable
    ) {
        self.displayBundle = displayBundle
        self.devicePresenterType = devicePresenterType
        amountViewable = amountViewProvider
        continueButtonTapped = continueButtonViewModel.tap
        super.init(nibName: nil, bundle: nil)

        digitPadView.viewModel = digitPadViewModel
        continueButtonView.viewModel = continueButtonViewModel
        topSelectionButtonView.viewModel = topSelectionButtonViewModel
        bottomAuxiliaryItemSeparatorView.viewModel = TitledSeparatorViewModel(
            title: displayBundle.strings.bottomAuxiliaryItemSeparatorTitle,
            separatorColor: displayBundle.colors.bottomAuxiliaryItemSeparator,
            accessibilityId: displayBundle.accessibilityIdentifiers.bottomAuxiliaryItemSeparatorTitle
        )

        bottomAuxiliaryButtonViewHeightConstraint = bottomAuxiliaryView.layout(
            dimension: .height,
            to: 1
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white

        let digitPadTopSeparatorView = UIView()

        let amountView = amountViewable.view
        view.addSubview(topSelectionButtonView)
        view.addSubview(amountView)
        view.addSubview(bottomAuxiliaryItemSeparatorView)
        view.addSubview(bottomAuxiliaryView)
        view.addSubview(continueButtonView)
        view.addSubview(digitPadTopSeparatorView)
        view.addSubview(digitPadView)

        topSelectionButtonView.layoutToSuperview(.top, usesSafeAreaLayoutGuide: true)
        topSelectionButtonView.layoutToSuperview(axis: .horizontal)
        topSelectionViewHeightConstraint = topSelectionButtonView.layout(dimension: .height, to: 78)

        amountView.layoutToSuperview(axis: .horizontal)
        amountView.layout(edge: .top, to: .bottom, of: topSelectionButtonView)

        bottomAuxiliaryItemSeparatorView.layout(edge: .top, to: .bottom, of: amountView)
        bottomAuxiliaryItemSeparatorView.layoutToSuperview(.leading, offset: 24, priority: .defaultHigh)
        bottomAuxiliaryItemSeparatorView.layoutToSuperview(.trailing)

        bottomAuxiliaryView.layoutToSuperview(.leading, .trailing)
        bottomAuxiliaryView.layout(
            edge: .top,
            to: .bottom,
            of: bottomAuxiliaryItemSeparatorView,
            priority: .defaultLow
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

        digitPadTopSeparatorView.backgroundColor = displayBundle.colors.digitPadTopSeparator
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // NOTE: This must be in `viewWillLayoutSubviews`
        // This is a special treatment due to the manner view controllers
        // are modally displayed on iOS 13 (with additional gap on the top that enable
        // dismissal of the screen.
        if view.bounds.height <= UIDevice.PhoneHeight.eight.rawValue {
            digitPadHeightConstraint.constant = Constant.SuperCompact.digitPadHeight
            digitPadSeparatorTopConstraint.constant = Constant.SuperCompact.continueButtonViewBottomOffset
            if view.bounds.height <= UIDevice.PhoneHeight.se.rawValue {
                continueButtonTopConstraint.constant = Constant.SuperCompact.bottomAuxiliaryViewOffset
                topSelectionViewHeightConstraint.constant = Constant.SuperCompact.topSelectionViewHeight
            }
        }
    }

    func connect(state: Driver<WithdrawAmountPageInteractor.State>) -> Driver<WithdrawAmountPageInteractor.Effects> {

        let topSelection = state.map(\.topSelection)

        topSelection.map(\.title)
            .drive(topSelectionButtonView.viewModel.titleRelay)
            .disposed(by: disposeBag)
        topSelection.map(\.subtitle)
            .drive(topSelectionButtonView.viewModel.subtitleRelay)
            .disposed(by: disposeBag)
        topSelection.map(\.isEnabled)
            .drive(topSelectionButtonView.viewModel.isButtonEnabledRelay)
            .disposed(by: disposeBag)
        topSelection.map(\.leadingContent)
            .drive(topSelectionButtonView.viewModel.leadingContentTypeRelay)
            .disposed(by: disposeBag)
        topSelection.compactMap(\.trailingContent)
            .drive(topSelectionButtonView.viewModel.trailingContentRelay)
            .disposed(by: disposeBag)
        topSelection.map(\.horizontalOffset)
            .drive(topSelectionButtonView.viewModel.horizontalOffsetRelay)
            .disposed(by: disposeBag)

        state.map(\.bottomAuxiliaryState)
            .distinctUntilChanged()
            .drive(weak: self) { (self, state) in
                self.bottomAuxiliaryViewModelStateDidChange(to: state)
            }
            .disposed(by: disposeBag)

        let digitInput = digitPadView.viewModel
            .valueObservable
            .filter { !$0.isEmpty }
            .map { Character($0) }
            .asDriverCatchError()

        let deleteInput = digitPadView.viewModel
            .backspaceButtonTapObservable
            .asDriverCatchError()

        let amountViewInputs = [
            digitInput.map(AmountPresenterInput.input),
            deleteInput.map { AmountPresenterInput.delete }
        ]

        amountViewable.connect(input: Driver.merge(amountViewInputs))
            .drive()
            .disposed(by: disposeBag)

        state.map(\.canContinue)
            .drive(continueButtonView.viewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        let backTapped = backTriggered
            .map { WithdrawAmountPageInteractor.Effects.back }

        let closeTapped = closeTriggerred
            .map { WithdrawAmountPageInteractor.Effects.close }

        return Observable.merge(backTapped, closeTapped)
            .asDriver(onErrorJustReturn: .none)
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        titleViewStyle = .text(value: displayBundle.strings.title)
        set(
            barStyle: .darkContent(),
            leadingButtonStyle: .back,
            trailingButtonStyle: .close
        )
    }

    private func bottomAuxiliaryViewModelStateDidChange(to state: WithdrawAmountPageInteractor.BottomAuxiliaryViewModelState) {
        let height: CGFloat
        let visibility: Visibility
        var subviewsToRemove: [UIView]
        switch state {
        case .hidden:
            height = 0.5
            visibility = .hidden
            subviewsToRemove = bottomAuxiliaryView.subviews
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

    override func navigationBarLeadingButtonPressed() {
        backTriggered.onNext(())
    }

    override func navigationBarTrailingButtonPressed() {
        closeTriggerred.onNext(())
    }
}
