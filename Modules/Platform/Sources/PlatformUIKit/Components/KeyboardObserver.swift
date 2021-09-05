// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

public final class KeyboardObserver {

    // MARK: - Types

    public struct Payload {
        public let duration: TimeInterval
        public let curve: UIView.AnimationCurve
        public let begin: CGRect
        public let end: CGRect

        public init?(with rawValue: [AnyHashable: Any]?) {
            guard let rawValue = rawValue else {
                return nil
            }
            duration = rawValue[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
            begin = (rawValue[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
            end = (rawValue[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue

            if let curveNumber = rawValue[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {
                curve = UIView.AnimationCurve(rawValue: curveNumber.intValue) ?? .linear
            } else {
                curve = .linear
            }
        }

        public var height: CGFloat {
            end.maxY - end.minY
        }
    }

    public struct State {
        public let visibility: Visibility
        public let payload: Payload

        public var isVisible: Bool {
            visibility == .visible
        }
    }

    // MARK: - Exposed

    /// The state of the keyboard
    public var state: Observable<State> {
        stateRelay.asObservable()
    }

    // MARK: - Private Properties

    private let stateRelay = PublishRelay<State>()

    // MARK: - Bootstrap

    public init() {}

    /// Setups `Self` as keyboard observer
    public func setup() {
        remove()

        NotificationCenter.when(UIResponder.keyboardWillShowNotification) { [weak self] notification in
            guard let self = self else { return }
            guard let payload = Payload(with: notification.userInfo) else { return }
            self.stateRelay.accept(.init(visibility: .visible, payload: payload))
        }

        NotificationCenter.when(UIResponder.keyboardWillChangeFrameNotification) { [weak self] notification in
            guard let self = self else { return }
            guard let payload = Payload(with: notification.userInfo) else { return }
            self.stateRelay.accept(.init(visibility: .visible, payload: payload))
        }

        NotificationCenter.when(UIResponder.keyboardWillHideNotification) { [weak self] notification in
            guard let self = self else { return }
            guard let payload = Payload(with: notification.userInfo) else { return }
            self.stateRelay.accept(.init(visibility: .hidden, payload: payload))
        }
    }

    // MARK: - Teardown

    /// Removes `Self` form observing the keyboard
    public func remove() {
        NotificationCenter.default.removeObserver(self)
    }
}
