// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol LinkedBanksClientAPI: AnyObject {
    /// Fetches any linked banks associated with the current user
    func linkedBanks() -> Single<[LinkedBankResponse]>

    /// Fetches a specific linked bank for the provided `id`
    /// - Parameter id: A `String` representing the id of the linked bank
    func getLinkedBank(for id: String) -> Single<LinkedBankResponse>

    /// Deletes the specified linked bank by the given id
    /// - Parameter id: A `String` representing the id of the linked bank
    func deleteLinkedBank(for id: String) -> Completable

    /// Starts the proccess of creating a bank linkage
    /// - Parameter currency: A `FiatCurrency` value of the linked bank
    func createBankLinkage(for currency: FiatCurrency) -> Single<CreateBankLinkageResponse>

    /// Fetches a specific bank with
    /// - Parameter id: A `String` representing the id of the linked bank
    /// - Parameter providerAccountId: A `String` representing the `providerAccountId` from partner's response
    /// - Parameter acountId: A `String` representing the `accountId` from partner's response
    func updateBankLinkage(for id: String, providerAccountId: String, accountId: String) -> Single<LinkedBankResponse>
}
