// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

extension Publisher {

    /// Repeats the publisher's operation until the `until` closure returns `true` or there's a timeout.
    /// - Parameters:
    ///   - timeoutInterval: The time interval after which the operation will stop retrying.
    ///   - retryInterval: A delay for each attempt after the first. So, the publisher will execute immediately, but retries are delayed by this amount.
    ///   - resultMatcher: A closure invoked every time the publisher receives a value. You should return `true` when the publisher receives a value matching your expectations.
    public func startPolling(
        timeoutInterval: TimeInterval = .minutes(2),
        retryInterval: TimeInterval = .seconds(3),
        until resultMatcher: @escaping (Output) -> Bool,
        currentDateFactory: @escaping () -> Date = Date.init
    ) -> AnyPublisher<Output, Failure> {
        func pollingHelper(
            timeout: Date,
            scheduler: DispatchQueue,
            retryDelay: DispatchQueue.SchedulerTimeType.Stride,
            attempt: Int = 1
        ) -> AnyPublisher<Output, Failure> {
            // Poll the API every x seconds until `taskComplete` is `true` or an error is returned from the upstream until timeout.
            // This should only take a couple of seconds in reality.
            self // using self to make the logic below more readable
                .subscribe(on: scheduler)
                .flatMap { result -> AnyPublisher<Output, Failure> in
                    // If result matches expectations, return it
                    guard !resultMatcher(result) else {
                        return .just(result)
                    }
                    // Otherwise, if we're past timeout, return what we got so far
                    guard currentDateFactory() < timeout else {
                        return .just(result)
                    }
                    // In all other cases, poll again
                    return Deferred {
                        Just(())
                            .delay(for: retryDelay, scheduler: scheduler)
                            .flatMap { _ in
                                pollingHelper(
                                    timeout: timeout,
                                    scheduler: scheduler,
                                    retryDelay: retryDelay,
                                    attempt: attempt + 1
                                )
                            }
                    }
                    .eraseToAnyPublisher()
                }
                .receive(on: scheduler)
                .eraseToAnyPublisher()
        }

        return pollingHelper(
            timeout: Date(timeIntervalSinceNow: timeoutInterval),
            scheduler: DispatchQueue(label: "Polling Queue", qos: .userInitiated),
            retryDelay: .seconds(retryInterval)
        )
    }
}
