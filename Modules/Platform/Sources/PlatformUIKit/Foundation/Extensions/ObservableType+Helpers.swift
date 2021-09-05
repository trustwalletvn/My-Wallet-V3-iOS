// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

extension ObservableType {
    public func asDriverCatchError(
        file: String = #file,
        line: Int = #line,
        function: String = #function
    ) -> Driver<Element> {
        asDriver { error -> Driver<Element> in
            fatalError("Binding error to observers. file: \(file), line: \(line), function: \(function), error: \(error).")
        }
    }
}
