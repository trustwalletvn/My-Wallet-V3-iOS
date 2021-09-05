// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

extension Result {
    public var isFailure: Bool {
        switch self {
        case .failure:
            return true
        case .success:
            return false
        }
    }

    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}

extension Result {
    public var successData: Success? {
        try? get()
    }
}

extension Result where Success: OptionalType {
    public func onNil(error: Failure) -> Result<Success.Wrapped, Failure> {
        flatMap { element -> Result<Success.Wrapped, Failure> in
            guard let value = element.value else {
                return .failure(error)
            }
            return .success(value)
        }
    }
}

extension Result {
    public var single: Single<Success> {
        switch self {
        case .success(let value):
            return Single.just(value)
        case .failure(let error):
            return Single.error(error)
        }
    }
}

extension Result {
    public var completable: Completable {
        switch self {
        case .success:
            return Completable.empty()
        case .failure(let error):
            return Completable.error(error)
        }
    }
}

extension Result {
    public var maybe: Maybe<Success> {
        switch self {
        case .success(let value):
            return Maybe.just(value)
        case .failure:
            return Maybe.empty()
        }
    }
}

extension Result where Failure == Never {
    public func mapError<E: Error>(to type: E.Type) -> Result<Success, E> {
        mapError()
    }

    public func mapError<E: Error>() -> Result<Success, E> {
        mapError { _ -> E in
            fatalError("This can never be executed")
        }
    }
}

extension Result where Success == Never {
    public func map<T>(to type: T.Type) -> Result<T, Failure> {
        map()
    }

    public func map<T>() -> Result<T, Failure> {
        map { _ in
            fatalError("This can never be executed")
        }
    }
}

extension Result {
    public func replaceError<E: Error>(with error: E) -> Result<Success, E> {
        mapError { _ in error }
    }
}

extension Result {
    public func eraseError() -> Result<Success, Error> {
        mapError { $0 }
    }
}

extension Result {
    public func reduce<NewValue>(_ transform: (Result<Success, Failure>) -> NewValue) -> NewValue {
        transform(self)
    }
}

extension Result {
    public var singleEvent: SingleEvent<Success> {
        switch self {
        case .success(let value):
            return .success(value)
        case .failure(let error):
            return .error(error)
        }
    }
}

extension Result {
    public var publisher: AnyPublisher<Success, Failure> {
        switch self {
        case .success(let value):
            return .just(value)
        case .failure(let error):
            return .failure(error)
        }
    }
}
