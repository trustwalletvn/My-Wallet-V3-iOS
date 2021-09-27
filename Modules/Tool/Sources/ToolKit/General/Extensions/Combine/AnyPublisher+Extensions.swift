// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

extension AnyPublisher {

    public static func just(
        _ value: Output
    ) -> AnyPublisher<Output, Failure> {
        Just(value)
            .setFailureType(to: Failure.self)
            .eraseToAnyPublisher()
    }

    public static func failure(
        _ error: Failure
    ) -> AnyPublisher<Output, Failure> {
        Fail(error: error).eraseToAnyPublisher()
    }

    public static func empty() -> AnyPublisher<Output, Failure> {
        Empty().eraseToAnyPublisher()
    }
}

extension Publisher {

    public var resultPublisher: AnyPublisher<Result<Output, Failure>, Never> {
        flatMap { value -> AnyPublisher<Result<Output, Failure>, Failure> in
            .just(.success(value))
        }
        .catch { error -> AnyPublisher<Result<Output, Failure>, Never> in
            .just(.failure(error))
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Failure == Never {

    public func mapError<E: Error>(to type: E.Type) -> AnyPublisher<Output, E> {
        mapError()
    }

    public func mapError<E: Error>() -> AnyPublisher<Output, E> {
        setFailureType(to: E.self).eraseToAnyPublisher()
    }
}

extension Publisher {

    public func eraseError() -> AnyPublisher<Output, Error> {
        mapError { $0 }.eraseToAnyPublisher()
    }

    public func replaceError<E: Error>(with error: E) -> AnyPublisher<Output, E> {
        mapError { _ -> E in
            error
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {

    public func optional() -> AnyPublisher<Output?, Failure> {
        map { element -> Output? in
            element
        }
        .eraseToAnyPublisher()
    }

    public func mapToVoid() -> AnyPublisher<Void, Failure> {
        replaceOutput(with: ())
    }
}

extension Publisher {

    public func replaceOutput<O>(with output: O) -> AnyPublisher<O, Failure> {
        map { _ -> O in
            output
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {

    public func crashOnError() -> AnyPublisher<Output, Failure> {
        self.catch { error -> AnyPublisher<Output, Failure> in
            fatalError(error.localizedDescription)
        }
        .eraseToAnyPublisher()
    }

    public func crashOnError() -> AnyPublisher<Output, Never> {
        self.catch { error -> AnyPublisher<Output, Never> in
            fatalError(error.localizedDescription)
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {

    public func recordErrors(on recorder: ErrorRecording?) -> AnyPublisher<Output, Failure> {
        handleEvents(
            receiveCompletion: { completion in
                guard case .failure(let error) = completion else {
                    return
                }
                recorder?.error(error)
            }
        )
        .eraseToAnyPublisher()
    }

    public func recordErrors(on recorder: ErrorRecording?, enabled: Bool) -> AnyPublisher<Output, Failure> {
        guard enabled else {
            return eraseToAnyPublisher()
        }
        return recordErrors(on: recorder)
    }
}

extension Publisher {

    /// Subscribes to a `Publisher` ignoring all published events
    ///
    /// This method creates the subscriber and immediately requests an unlimited number of values, prior to returning the subscriber.
    ///
    /// - Returns: A cancellable instance, which you use when you end assignment of the received value. Deallocation of the result will tear down the subscription stream.
    public func subscribe() -> AnyCancellable {
        sink(receiveCompletion: { _ in }, receiveValue: { _ in })
    }
}
