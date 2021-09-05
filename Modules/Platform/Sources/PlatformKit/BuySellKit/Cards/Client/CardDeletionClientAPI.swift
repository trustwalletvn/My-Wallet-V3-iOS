// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol CardDeletionClientAPI: AnyObject {
    func deleteCard(by id: String) -> Completable
}
