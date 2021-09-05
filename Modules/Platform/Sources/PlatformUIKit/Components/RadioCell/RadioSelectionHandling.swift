import PlatformKit
import RxCocoa
import RxSwift

/// An `enum` to be used by types that conform to `RadioSelectionHandling`.
public enum RadioSelectionAction: Equatable {
    case initialValues([AnyHashable])
    case select(AnyHashable)
    case deselect(AnyHashable)
    case deselectAll
}

/// Types adopting to `RadioSelectionHandling` should provide a way to keep a selection state updated
/// with correct values for single selection purposes.
public protocol RadioSelectionHandling {
    /// A `Relay` that listens to actions of `RadioSelectionAction` and updates the state
    var selectionAction: PublishRelay<RadioSelectionAction> { get }
    /// Streams a `[String: Bool]` mapping that corresponts to the current state of the selection
    var selectionState: Observable<[AnyHashable: Bool]> { get }
}
