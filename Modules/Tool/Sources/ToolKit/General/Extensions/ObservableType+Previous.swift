// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

extension ObservableType {

    public func withPrevious() -> Observable<(Element?, Element)> {
        scan([]) { previous, current in
            Array(previous + [current]).suffix(2)
        }
        .map { arr -> (previous: Element?, current: Element) in
            (arr.count > 1 ? arr.first : nil, arr.last!)
        }
    }
}
