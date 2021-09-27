// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift

final class PendingTransactionViewController: BaseScreenViewController, PendingTransactionPagePresentable {

    // MARK: - Private Properties

    private let closeTriggered = PublishSubject<Void>()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let button = ButtonView()
    private let disposeBag = DisposeBag()
    private let compositeStatusView = CompositeStatusView(edge: 72.0)

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Lifecycle

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white

        titleLabel.numberOfLines = 0
        subtitleLabel.numberOfLines = 0

        view.addSubview(stackView)
        view.addSubview(button)
        view.addSubview(compositeStatusView)

        stackView.axis = .vertical
        stackView.layoutToSuperviewCenter()
        stackView.layout(to: .leading, of: view, offset: 16.0)
        stackView.layout(to: .trailing, of: view, offset: -16.0)
        compositeStatusView.layout(edge: .centerX, to: .centerX, of: stackView)
        compositeStatusView.layout(edge: .bottom, to: .top, of: stackView, offset: -24)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.spacing = 16.0

        button.layout(to: .bottomMargin, of: view, offset: -16.0)
        button.layout(dimension: .height, to: 48.0)
        button.layout(to: .leading, of: view, offset: 16.0)
        button.layout(to: .trailing, of: view, offset: -16)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        titleViewStyle = .none
        set(
            barStyle: .darkContent(),
            leadingButtonStyle: .none,
            trailingButtonStyle: .close
        )
    }

    // MARK: - PendingTransactionPagePresentable

    func connect(state: Driver<PendingTransactionPageState>) -> Driver<PendingTransactionPageState.Effect> {
        state
            .map(\.title)
            .drive(titleLabel.rx.content)
            .disposed(by: disposeBag)

        state
            .map(\.subtitle)
            .drive(subtitleLabel.rx.content)
            .disposed(by: disposeBag)

        state
            .map(\.compositeViewType)
            .drive(compositeStatusView.currentTypeRelay)
            .disposed(by: disposeBag)

        state
            .map(\.buttonViewModelVisibility)
            .map(\.defaultAlpha)
            .drive(button.rx.alpha)
            .disposed(by: disposeBag)

        state
            .compactMap(\.buttonViewModel)
            .drive(button.rx.viewModel)
            .disposed(by: disposeBag)

        let closeTapped = closeTriggered
            .map { PendingTransactionPageState.Effect.close }

        let tap = state
            .compactMap(\.buttonViewModel)
            .flatMap(\.tap)
            .flatMap { state.map(\.effect) }
            .asObservable()

        return Observable.merge(closeTapped, tap)
            .asDriver(onErrorJustReturn: .close)
    }

    // MARK: - Navigation

    override func navigationBarTrailingButtonPressed() {
        closeTriggered.onNext(())
    }
}
