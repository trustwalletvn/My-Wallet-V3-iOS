// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

/// A publisher that never completes, streaming values or errors of the given types.
public typealias StreamOf<Value, Error> = AnyPublisher<Result<Value, Error>, Never> where Error: Swift.Error
