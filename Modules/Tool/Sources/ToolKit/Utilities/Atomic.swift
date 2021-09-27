// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

/// A wrapper for atomic access to a generic value.
///
/// Uses a concurrent `DispatchQueue` for thread-safety.
public final class Atomic<Value> {

    // MARK: - Public Properties

    /// Atomic read access to the wrapped value.
    public var value: Value {
        queue.sync { self._value }
    }

    /// A publisher that emits the wrapped value whenever it updates.
    ///
    /// When subscribing to this publisher, the first value emitted will be the current wrapped value.
    public var publisher: AnyPublisher<Value, Never> {
        subject.eraseToAnyPublisher()
    }

    // MARK: - Private Properties

    /// The wrapped value.
    private var _value: Value {
        didSet {
            subject.send(_value)
        }
    }

    /// The wrapped value subject.
    private let subject: CurrentValueSubject<Value, Never>

    /// The concurrent `DispatchQueue`, allows concurrent reads in order to improve performance.
    /// Read [this](https://basememara.com/creating-thread-safe-generic-values-in-swift/) blog post for more information.
    private let queue = DispatchQueue(label: "Atomic read/write queue", attributes: .concurrent)

    // MARK: - Setup

    /// Creates an atomic wrapper.
    ///
    /// - Parameter value: A value.
    public init(_ value: Value) {
        _value = value
        subject = CurrentValueSubject(value)
    }

    // MARK: - Public Methods

    /// Atomically mutates the wrapped value.
    ///
    /// The `transform` closure should not perform any slow computation as it it blocks the current thread.
    ///
    /// Read [this](https://github.com/objcio/S01E42-thread-safety-reactive-programming-5/commit/2c8b4c60e2154776b575ce7641b6e23e4e8be12d) github commit for more information.
    ///
    /// - Parameters:
    ///   - transform: A transform closure, atomically mutating the wrapped value.
    ///   - current:   The current wrapped value, passed as an `inout` parameter to allow mutation.
    ///
    /// - Returns: The updated wrapped value.
    @discardableResult
    public func mutate(_ transform: (_ current: inout Value) -> Void) -> Value {
        queue.sync(flags: .barrier) {
            transform(&self._value)
            return self._value
        }
    }

    /// Atomically mutates the wrapped value.
    ///
    /// The `transform` closure should not perform any slow computation as it it blocks the current thread.
    ///
    /// Read [this](https://github.com/objcio/S01E42-thread-safety-reactive-programming-5/commit/2c8b4c60e2154776b575ce7641b6e23e4e8be12d) github commit for more information.
    ///
    /// - Parameters:
    ///   - transform: A transform closure, atomically mutating the wrapped value.
    ///   - current:   The current wrapped value, passed as an `inout` parameter to allow mutation.
    ///
    /// - Returns: The return value of the `transform` closure.
    public func mutateAndReturn<T>(_ transform: (_ current: inout Value) -> T) -> T {
        queue.sync(flags: .barrier) {
            transform(&self._value)
        }
    }
}
