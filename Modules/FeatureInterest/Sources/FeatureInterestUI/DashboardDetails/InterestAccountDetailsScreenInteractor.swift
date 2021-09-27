// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureInterestDomain
import Localization
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

public final class InterestAccountDetailsScreenInteractor {

    private typealias LocalizationId = LocalizationConstants.Interest.Screen.AccountDetails.Cell.Default
    private typealias TitleLabelInteractor = DefaultLabelContentInteractor
    private typealias DescriptionLabelInteractor = InterestAccountDetailsDescriptionLabelInteractor
    private typealias CellInteractor = DefaultLineItemCellInteractor

    typealias Interactors = Observable<[DetailCellInteractor]>

    var interactors: Interactors {
        _ = setup
        let items: Interactors = interactorsRelay
            .asObservable()
        let balance: Interactors = Observable.just([.balance(currentBalanceCellInteractor)])
        return Observable
            .combineLatest(balance, items)
            .map { $0.0 + $0.1 }
    }

    private lazy var setup: Void = {
        let rates = CellInteractor(
            title: TitleLabelInteractor(knownValue: LocalizationId.Rate.title),
            description: DescriptionLabelInteractor.Rates(
                service: service,
                cryptoCurrency: cryptoCurrency
            )
        )

        let nextPayment = CellInteractor(
            title: TitleLabelInteractor(knownValue: LocalizationId.Next.title),
            description: DescriptionLabelInteractor.NextPayment(
                cryptoCurrency: cryptoCurrency)
        )

        let limits = CellInteractor(
            title: TitleLabelInteractor(knownValue: LocalizationId.Hold.title),
            description: DescriptionLabelInteractor.LockUpDuration(
                service: service,
                cryptoCurrency: cryptoCurrency
            )
        )

        let total = CellInteractor(
            title: TitleLabelInteractor(knownValue: LocalizationId.Total.title),
            description: DescriptionLabelInteractor.TotalInterest(
                service: service,
                cryptoCurrency: cryptoCurrency
            )
        )

        let pending = CellInteractor(
            title: TitleLabelInteractor(knownValue: LocalizationId.Accrued.title),
            description: DescriptionLabelInteractor.PendingDeposit(
                service: service,
                cryptoCurrency: cryptoCurrency
            )
        )

        let interactors: [DetailCellInteractor] = [
            total,
            nextPayment,
            pending,
            limits,
            rates
        ]
        .map { .default($0) }
        .map { .item($0) }
        interactorsRelay.accept(interactors)
    }()

    let cryptoCurrency: CryptoCurrency
    let currentBalanceCellInteractor: CurrentBalanceCellInteracting

    private let interactorsRelay = BehaviorRelay<[DetailCellInteractor]>(value: [])
    private let service: InterestAccountServiceAPI
    private let disposeBag = DisposeBag()

    public init(
        service: InterestAccountServiceAPI = resolve(),
        account: BlockchainAccount
    ) {
        self.service = service
        cryptoCurrency = account.currencyType.cryptoCurrency!
        currentBalanceCellInteractor = CurrentBalanceCellInteractor(
            account: account
        )
    }
}
