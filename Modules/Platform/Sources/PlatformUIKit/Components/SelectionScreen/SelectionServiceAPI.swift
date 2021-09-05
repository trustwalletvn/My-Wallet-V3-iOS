// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

public protocol SelectionServiceAPI: AnyObject {
    var dataSource: Observable<[SelectionItemViewModel]> { get }
    var selectedDataRelay: BehaviorRelay<SelectionItemViewModel> { get }
    var selectedData: Observable<SelectionItemViewModel> { get }
}
