// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

public protocol ActivityItemEventDetailsFetcherAPI: AnyObject {
    associatedtype Model
    func details(for identifier: String) -> Observable<Model>
}

public struct AnyActivityItemEventDetailsFetcher<Model> {

    private let detailsObservable: (String) -> Observable<Model>

    public init<API: ActivityItemEventDetailsFetcherAPI>(api: API) where API.Model == Model {
        detailsObservable = api.details
    }

    public func details(for identifier: String) -> Observable<Model> {
        detailsObservable(identifier)
    }
}
