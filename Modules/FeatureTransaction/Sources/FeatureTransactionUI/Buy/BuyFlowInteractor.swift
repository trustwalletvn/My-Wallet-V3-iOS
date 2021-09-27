// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs
import ToolKit
import UIKit

final class BuyFlowInteractor: Interactor {

    var listener: BuyFlowListening?
    weak var router: BuyFlowRouting?
}

extension BuyFlowInteractor: TransactionFlowListener {

    func presentKYCFlowIfNeeded(from viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        listener?.presentKYCFlow(from: viewController, completion: completion)
    }

    func dismissTransactionFlow() {
        // TODO: can I make this also return completed?
        listener?.buyFlowDidComplete(with: .abandoned)
    }
}
