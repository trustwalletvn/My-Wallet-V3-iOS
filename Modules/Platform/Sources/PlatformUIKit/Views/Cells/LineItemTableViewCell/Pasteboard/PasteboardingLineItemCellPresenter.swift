// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

public protocol PasteboardLineItemPresenting: AnyObject {
    var pasteboardValue: String { get }
}

public final class PasteboardingLineItemCellPresenter: LineItemCellPresenting, PasteboardLineItemPresenting {

    // MARK: - Input

    public struct Input {
        let title: String
        let titleInteractionText: String
        let description: String
        let descriptionInteractionText: String
        let interactionDuration: Int
        let analyticsEvent: AnalyticsEvent?

        public init(
            title: String,
            titleInteractionText: String,
            description: String,
            descriptionInteractionText: String,
            analyticsEvent: AnalyticsEvent? = nil,
            interactionDuration: Int = 4
        ) {
            self.title = title
            self.titleInteractionText = titleInteractionText
            self.description = description
            self.descriptionInteractionText = descriptionInteractionText
            self.interactionDuration = interactionDuration
            self.analyticsEvent = analyticsEvent
        }
    }

    // MARK: - Properties

    public let titleLabelContentPresenter: LabelContentPresenting
    public let descriptionLabelContentPresenter: LabelContentPresenting

    /// The background color relay
    let backgroundColorRelay = BehaviorRelay<UIColor>(value: .clear)

    /// The background color of the button
    public var backgroundColor: Driver<UIColor> {
        backgroundColorRelay.asDriver()
    }

    public var image: Driver<UIImage?> {
        imageRelay.asDriver()
    }

    /// This is fixed at 22px for pasteboard line items
    public let imageWidth: Driver<CGFloat>

    public var identifier: String {
        pasteboardValue
    }

    /// The background color relay
    let imageRelay = BehaviorRelay<UIImage?>(value: #imageLiteral(resourceName: "clipboard"))

    // MARK: - PasteboardLineItemPresenting

    /// Streams events when the component is being tapped
    public let tapRelay = PublishRelay<Void>()
    public let pasteboardValue: String

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()
    private let analyticsRecorder: AnalyticsEventRecorderAPI

    public var interactor: LineItemCellInteracting

    // MARK: - Init

    public init(
        input: Input,
        pasteboard: Pasteboarding = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI,
        accessibilityIdPrefix: String
    ) {
        self.analyticsRecorder = analyticsRecorder
        pasteboardValue = input.description

        let titleInteractor = PasteboardLabelContentInteractor(
            text: input.title,
            interactionText: input.titleInteractionText,
            interactionDuration: input.interactionDuration
        )

        let descriptionInteractor = PasteboardLabelContentInteractor(
            text: input.description,
            interactionText: input.descriptionInteractionText,
            interactionDuration: input.interactionDuration
        )

        imageWidth = Driver.just(22)

        interactor = DefaultLineItemCellInteractor(title: titleInteractor, description: descriptionInteractor)

        titleLabelContentPresenter = PasteboardLabelContentPresenter(
            interactor: titleInteractor,
            descriptors: .lineItemTitle(accessibilityIdPrefix: accessibilityIdPrefix)
        )
        descriptionLabelContentPresenter = PasteboardLabelContentPresenter(
            interactor: descriptionInteractor,
            descriptors: .lineItemDescription(accessibilityIdPrefix: accessibilityIdPrefix)
        )

        tapRelay
            .bindAndCatch(to: titleInteractor.pasteboardTriggerRelay)
            .disposed(by: disposeBag)

        tapRelay
            .bindAndCatch(to: descriptionInteractor.pasteboardTriggerRelay)
            .disposed(by: disposeBag)

        tapRelay
            .bind {
                let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
                feedbackGenerator.prepare()
                feedbackGenerator.impactOccurred()
            }
            .disposed(by: disposeBag)

        tapRelay
            .map { "green-checkmark-bottom-sheet" }
            .map { UIImage(named: $0) }
            .bindAndCatch(to: imageRelay)
            .disposed(by: disposeBag)

        tapRelay
            .map { .affirmativeBackground }
            .bindAndCatch(to: backgroundColorRelay)
            .disposed(by: disposeBag)

        tapRelay
            .bind { pasteboard.string = input.description }
            .disposed(by: disposeBag)

        tapRelay
            .compactMap { input.analyticsEvent }
            .subscribe(onNext: analyticsRecorder.record(event:))
            .disposed(by: disposeBag)

        let delay = tapRelay
            .debounce(
                .seconds(input.interactionDuration),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated)
            )
            .share(replay: 1)

        delay
            .map { "clipboard" }
            .map { UIImage(named: $0) }
            .bindAndCatch(to: imageRelay)
            .disposed(by: disposeBag)

        delay
            .map { .clear }
            .bindAndCatch(to: backgroundColorRelay)
            .disposed(by: disposeBag)
    }
}
