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

extension AnyPublisher {

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

extension AnyPublisher where Failure == Never {

    public func mapError<E: Error>(to type: E.Type) -> AnyPublisher<Output, E> {
        mapError()
    }

    public func mapError<E: Error>() -> AnyPublisher<Output, E> {
        setFailureType(to: E.self).eraseToAnyPublisher()
    }
}

extension AnyPublisher {

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

extension AnyPublisher {

    public func mapToVoid() -> AnyPublisher<Void, Failure> {
        replaceOutput(with: ())
    }
}

extension AnyPublisher {

    public func replaceOutput<O>(with output: O) -> AnyPublisher<O, Failure> {
        map { _ -> O in
            output
        }
        .eraseToAnyPublisher()
    }
}
