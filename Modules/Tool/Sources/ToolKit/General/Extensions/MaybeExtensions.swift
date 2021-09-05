// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

extension Maybe {
    public func flatMap<A: AnyObject, R>(weak object: A, _ selector: @escaping (A, Element) throws -> Maybe<R>) -> Maybe<R> {
        asObservable()
            .flatMap(weak: object) { object, value in
                try selector(object, value).asObservable()
            }
            .asMaybe()
    }
}
