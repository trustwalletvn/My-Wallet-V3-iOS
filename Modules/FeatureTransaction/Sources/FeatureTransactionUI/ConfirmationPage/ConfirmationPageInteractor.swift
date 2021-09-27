// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import PlatformKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit

protocol ConfirmationPageInteractable: Interactable {
    var router: ConfirmationPageRouting? { get set }
    var listener: ConfirmationPageListener? { get set }
}

final class ConfirmationPageInteractor: PresentableInteractor<ConfirmationPagePresentable>,
    ConfirmationPageInteractable
{
    weak var router: ConfirmationPageRouting?
    weak var listener: ConfirmationPageListener?

    private let transactionModel: TransactionModel
    private let analyticsHook: TransactionAnalyticsHook

    init(
        presenter: ConfirmationPagePresentable,
        transactionModel: TransactionModel,
        analyticsHook: TransactionAnalyticsHook = resolve()
    ) {
        self.transactionModel = transactionModel
        self.analyticsHook = analyticsHook
        super.init(presenter: presenter)
    }

    override func didBecomeActive() {
        super.didBecomeActive()

        transactionModel.process(action: .validateTransaction)

        let actionDriver: Driver<Action> = transactionModel
            .state
            .map { Action.load($0) }
            .asDriver(onErrorJustReturn: .empty)

        presenter.continueButtonTapped
            .asObservable()
            .withLatestFrom(transactionModel.state)
            .subscribe(onNext: { [weak self] state in
                self?.transactionModel.process(action: .executeTransaction)
                self?.analyticsHook.onClose(action: state.action)
            })
            .disposeOnDeactivate(interactor: self)

        presenter.connect(action: actionDriver)
            .drive(onNext: handle(effect:))
            .disposeOnDeactivate(interactor: self)
    }

    func handle(effect: Effects) {
        switch effect {
        case .close:
            listener?.closeFlow()
        case .back:
            listener?.checkoutDidTapBack()
        case .updateMemo(let memo, let oldModel):
            let model = TransactionConfirmation.Model.Memo(textMemo: memo, required: oldModel.required)
            transactionModel.process(action: .modifyTransactionConfirmation(.memo(model)))
        }
    }
}

extension ConfirmationPageInteractor {
    enum Action: Equatable {
        case empty
        case load(TransactionState)
    }

    enum Effects: Equatable {
        case close
        case back
        case updateMemo(String?, oldModel: TransactionConfirmation.Model.Memo)
    }
}
