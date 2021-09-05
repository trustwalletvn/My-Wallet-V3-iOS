// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

public enum BankLinkageError: Error {
    case generic
    case server(Error)
}

public protocol LinkedBanksServiceAPI {
    /// Fetches any linked bank associated with the current user
    var linkedBanks: Single<[LinkedBankData]> { get }

    /// Starts the flow to linked a bank
    var bankLinkageStartup: Single<Result<BankLinkageData?, BankLinkageError>> { get }

    /// Returns the requested linked bank for the given id
    func linkedBank(for id: String) -> Single<LinkedBankData?>

    /// Fetches and updates the underlying cached value
    func fetchLinkedBanks() -> Single<[LinkedBankData]>

    /// Deletes a linked bank by its id
    /// - Parameter id: A `String` representing the bank id.
    func deleteBank(by id: String) -> Completable
}

final class LinkedBanksService: LinkedBanksServiceAPI {

    var linkedBanks: Single<[LinkedBankData]> {
        cachedValue.valueSingle
    }

    let bankLinkageStartup: Single<Result<BankLinkageData?, BankLinkageError>>

    // MARK: - Private

    private let cachedValue: CachedValue<[LinkedBankData]>

    // MARK: - Injected

    private let client: LinkedBanksClientAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI

    init(
        client: LinkedBanksClientAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        self.client = client
        self.fiatCurrencyService = fiatCurrencyService

        cachedValue = CachedValue<[LinkedBankData]>(configuration: .onSubscription())

        cachedValue.setFetch {
            client.linkedBanks()
                .map { response -> [LinkedBankData] in
                    // The API path is `banking-info` that includes both linked banked and bank account/beneficiary
                    // we currently only need to display the linked banks as for beneficiaries we use older APIs.
                    // So the filtering is a patch until we remove the older backend APIs
                    response.compactMap(LinkedBankData.init(response:))
                }
        }

        bankLinkageStartup = fiatCurrencyService.fiatCurrency
            .flatMap { currency -> Single<CreateBankLinkageResponse> in
                client.createBankLinkage(for: currency)
            }
            .mapToResult(
                successMap: { BankLinkageData(from: $0) },
                errorMap: { BankLinkageError.server($0) }
            )
    }

    // MARK: Methods

    func linkedBank(for id: String) -> Single<LinkedBankData?> {
        linkedBanks
            .map { $0.first(where: { $0.identifier == id }) }
    }

    func fetchLinkedBanks() -> Single<[LinkedBankData]> {
        cachedValue.fetchValue
    }

    func deleteBank(by id: String) -> Completable {
        client.deleteLinkedBank(for: id)
    }
}
