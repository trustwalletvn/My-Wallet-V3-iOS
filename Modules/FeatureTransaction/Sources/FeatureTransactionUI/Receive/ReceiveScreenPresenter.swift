// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class ReceiveScreenPresenter {

    // MARK: Types

    private typealias LocalizedString = LocalizationConstants.Receive
    private typealias AccessibilityID = Accessibility.Identifier.Receive

    // MARK: Properties

    let nameLabelContentPresenting: LabelContentPresenting
    let balanceLabelContentPresenting: LabelContentPresenting
    let addressLabelContentPresenting: LabelContentPresenting
    let memoLabelContentPresenting: LabelContentPresenting
    let walletAddressLabelContent: LabelContent
    let memoLabelContent: LabelContent
    let memoNoteViewModel: InteractableTextViewModel
    let copyButton: ButtonViewModel
    let shareButton: ButtonViewModel
    private(set) lazy var title = "\(LocalizedString.Text.receive) \(interactor.account.currencyType.code)"
    var assetImage: Driver<ImageViewContent> {
        .just(ImageViewContent(imageResource: interactor.account.currencyType.logoResource))
    }

    var qrCode: Driver<UIImage?> {
        qrCodeRelay.asDriver()
    }

    let webViewLaunchRelay = PublishRelay<URL>()

    // MARK: Private Properties

    private var eventsRecorder: AnalyticsEventRecorderAPI
    private let qrCodeRelay = BehaviorRelay<UIImage?>(value: nil)
    private let interactor: ReceiveScreenInteractor
    private let disposeBag = DisposeBag()

    // MARK: Setup

    init(
        pasteboard: Pasteboarding = resolve(),
        eventsRecorder: AnalyticsEventRecorderAPI = resolve(),
        interactor: ReceiveScreenInteractor
    ) {
        self.interactor = interactor
        self.eventsRecorder = eventsRecorder
        walletAddressLabelContent = LabelContent(
            text: LocalizedString.Text.walletAddress,
            font: .main(.semibold, 12),
            color: .titleText
        )
        memoLabelContent = LabelContent(
            text: LocalizedString.Text.memo,
            font: .main(.semibold, 12),
            color: .titleText
        )
        memoNoteViewModel = InteractableTextViewModel(
            inputs: [
                .text(string: LocalizedString.Text.memoNote),
                .url(string: LocalizedString.Text.learnMore, url: Constants.Url.stellarMemo)
            ],
            textStyle: .init(color: .descriptionText, font: .main(.semibold, 12)),
            linkStyle: .init(color: .linkableText, font: .main(.semibold, 12))
        )
        nameLabelContentPresenting = DefaultLabelContentPresenter(
            knownValue: interactor.account.label,
            descriptors: .init(
                fontWeight: .semibold,
                contentColor: .textFieldText,
                fontSize: 16,
                accessibility: .id(AccessibilityID.walletNameLabel)
            )
        )
        balanceLabelContentPresenting = DefaultLabelContentPresenter(
            knownValue: "  ",
            descriptors: .init(
                fontWeight: .medium,
                contentColor: .descriptionText,
                fontSize: 14,
                accessibility: .id(AccessibilityID.balanceLabel)
            )
        )
        addressLabelContentPresenting = DefaultLabelContentPresenter(
            knownValue: "  ",
            descriptors: .init(
                fontWeight: .medium,
                contentColor: .darkTitleText,
                fontSize: 14,
                accessibility: .id(AccessibilityID.addressLabel)
            )
        )
        memoLabelContentPresenting = DefaultLabelContentPresenter(
            knownValue: "",
            descriptors: .init(
                fontWeight: .medium,
                contentColor: .darkTitleText,
                fontSize: 14,
                accessibility: .id(AccessibilityID.memoLabel)
            )
        )
        copyButton = .secondary(with: LocalizedString.Button.copy)
        shareButton = .primary(with: LocalizedString.Button.share)

        let state = interactor.state
            .asObservable()
            .share(replay: 1)

        let qrCodeMetadata = state
            .map(\.metadata)

        qrCodeMetadata
            .map { metadata -> QRCodeAPI? in
                QRCode(metadata: metadata)
            }
            .map { $0?.image }
            .catchErrorJustReturn(nil)
            .bindAndCatch(to: qrCodeRelay)
            .disposed(by: disposeBag)

        qrCodeMetadata
            .map(\.address)
            .map { LabelContent.Value.Interaction.Content(text: $0) }
            .map { .loaded(next: $0) }
            .bindAndCatch(to: addressLabelContentPresenting.interactor.stateRelay)
            .disposed(by: disposeBag)

        interactor.account
            .balance
            .map { $0.toDisplayString(includeSymbol: true) }
            .asObservable()
            .mapToLabelContentStateInteraction()
            .catchErrorJustReturn(.loading)
            .bindAndCatch(to: balanceLabelContentPresenting.interactor.stateRelay)
            .disposed(by: disposeBag)

        state
            .map(\.memo)
            .compactMap { $0 }
            .map { LabelContent.Value.Interaction.Content(text: $0) }
            .map { .loaded(next: $0) }
            .bindAndCatch(to: memoLabelContentPresenting.interactor.stateRelay)
            .disposed(by: disposeBag)

        memoNoteViewModel.tap
            .map(\.url)
            .bindAndCatch(to: webViewLaunchRelay)
            .disposed(by: disposeBag)

        // MARK: - Copy

        copyButton.tapRelay
            .bind { [eventsRecorder] in
                eventsRecorder.record(event:
                    AnalyticsEvents.New.Receive.receiveDetailsCopied(
                        accountType: .init(self.interactor.account as? CryptoAccount),
                        currency: self.interactor.account.currencyType.code
                    )
                )
            }
            .disposed(by: disposeBag)

        copyButton.tapRelay
            .withLatestFrom(qrCodeMetadata.map(\.absoluteString))
            .bind { pasteboard.string = $0 }
            .disposed(by: disposeBag)

        copyButton.tapRelay
            .bindAndCatch(weak: self) { _, _ in
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred()
            }
            .disposed(by: disposeBag)

        copyButton.tapRelay
            .map {
                ButtonViewModel.Theme(
                    backgroundColor: .successButton,
                    contentColor: .white,
                    text: LocalizedString.Button.copied
                )
            }
            .bindAndCatch(weak: self) { (self, theme) in
                self.copyButton.animate(theme: theme)
            }
            .disposed(by: disposeBag)

        copyButton.tapRelay
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                self.copyButton.animate(theme: ButtonViewModel.secondary(with: LocalizedString.Button.copy).theme)
            }
            .disposed(by: disposeBag)

        // MARK: - Share

        shareButton.tapRelay
            .withLatestFrom(qrCodeMetadata)
            .subscribe(onNext: { [weak self] metadata in
                guard let self = self else { return }
                self.interactor.receiveRouter.shareDetails(for: metadata)
            })
            .disposed(by: disposeBag)
    }
}
