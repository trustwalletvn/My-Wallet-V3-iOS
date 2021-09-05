// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RIBs
import RxRelay
import RxSwift

final class BillingAddressScreenInteractor: Interactor {

    // MARK: - Properties

    var selectedCountry: Observable<Country> {
        countrySelectionService.selectedData
            .map(\.id)
            .compactMap { Country(code: $0) }
    }

    // MARK: - Setup

    let countrySelectionService: CountrySelectionService

    var billingAddress: Observable<BillingAddress> {
        billingAddressRelay
            .compactMap { $0 }
    }

    let billingAddressRelay = BehaviorRelay<BillingAddress?>(value: nil)

    private let userDataRepository: DataRepositoryAPI
    private let service: CardUpdateServiceAPI
    private let cardData: CardData
    private var disposeBag = DisposeBag()

    private let routingInteractor: CardRouterInteractor

    // MARK: - Setup

    init(
        cardData: CardData,
        service: CardUpdateServiceAPI = resolve(),
        userDataRepository: DataRepositoryAPI = resolve(),
        routingInteractor: CardRouterInteractor
    ) {
        self.cardData = cardData
        self.service = service
        self.userDataRepository = userDataRepository
        self.routingInteractor = routingInteractor
        countrySelectionService = CountrySelectionService(defaultSelectedData: Country.current ?? .US)
    }

    // MARK: - Interactor

    override func didBecomeActive() {
        super.didBecomeActive()
        disposeBag = DisposeBag()

        userDataRepository.userSingle
            .map(\.address)
            .subscribe(
                onSuccess: { [weak self] address in
                    guard let address = address else { return }
                    self?.countrySelectionService.set(country: address.country)
                }
            )
            .disposed(by: disposeBag)
    }

    override func willResignActive() {
        super.willResignActive()
        disposeBag = DisposeBag()
    }

    /// Adds the billing address to the card
    /// - Parameter billingAddress: The data of the billing address
    /// - Returns: A completable indicating whether the op has been completed / error occured
    func add(billingAddress: BillingAddress) -> Completable {
        Completable
            .create(weak: self) { (self, observer) in
                let cardData = self.cardData.data(byAppending: billingAddress)
                let disposable = self.service.add(card: cardData)
                    .subscribe(
                        onSuccess: { [weak self] data in
                            self?.routingInteractor.authorizeCardAddition(with: data)
                            observer(.completed)
                        },
                        onError: { error in
                            observer(.error(error))
                        }
                    )
                return Disposables.create {
                    disposable.dispose()
                }
            }
    }

    func previous() {
        routingInteractor.previousRelay.accept(())
    }
}
