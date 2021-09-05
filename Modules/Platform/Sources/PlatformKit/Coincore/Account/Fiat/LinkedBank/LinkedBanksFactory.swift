// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

public protocol LinkedBanksFactoryAPI {
    var linkedBanks: Single<[LinkedBankAccount]> { get }
    var nonWireTransferBanks: Single<[LinkedBankAccount]> { get }

    func bankPaymentMethods(for currency: FiatCurrency) -> Single<[PaymentMethodType]>
    func bankTransferLimits(for currency: FiatCurrency) -> Single<PaymentLimits>
}

/// A top-level closure that checks if the passed `LinkedBankData.Partner` is of type `yodlee`
/// Currently we only support deposit for linked accounts via `Yodlee` not `Yapily` (aka Open Banking)
var checkDepositSupport = { (partner: LinkedBankData.Partner) -> Bool in
    partner == .yodlee
}

final class LinkedBanksFactory: LinkedBanksFactoryAPI {

    private let linkedBankService: LinkedBanksServiceAPI
    private let paymentMethodService: PaymentMethodTypesServiceAPI

    init(
        linkedBankService: LinkedBanksServiceAPI = resolve(),
        paymentMethodService: PaymentMethodTypesServiceAPI = resolve()
    ) {
        self.linkedBankService = linkedBankService
        self.paymentMethodService = paymentMethodService
    }

    var linkedBanks: Single<[LinkedBankAccount]> {
        linkedBankService
            .linkedBanks
            .map { linkedBankData in
                linkedBankData.filter(\.isActive)
            }
            .map { linkedBankData in
                linkedBankData.map { data in
                    LinkedBankAccount(
                        label: data.account?.bankName ?? "",
                        accountNumber: data.account?.number ?? "",
                        accountId: data.identifier,
                        accountType: data.account?.type ?? .checking,
                        currency: data.currency,
                        paymentType: data.paymentMethodType,
                        supportsDeposit: checkDepositSupport(data.partner)
                    )
                }
            }
    }

    var nonWireTransferBanks: Single<[LinkedBankAccount]> {
        linkedBankService
            .linkedBanks
            .map { banks in
                banks
                    .filter {
                        $0.isActive && $0.paymentMethodType == .bankTransfer
                    }
            }
            .map { linkedBankData in
                linkedBankData.map { data in
                    LinkedBankAccount(
                        label: data.account?.name ?? "",
                        accountNumber: data.account?.number ?? "",
                        accountId: data.identifier,
                        accountType: data.account?.type ?? .checking,
                        currency: data.currency,
                        paymentType: data.paymentMethodType,
                        supportsDeposit: checkDepositSupport(data.partner)
                    )
                }
            }
    }

    func bankPaymentMethods(for currency: FiatCurrency) -> Single<[PaymentMethodType]> {
        paymentMethodService
            .eligiblePaymentMethods(for: currency)
            .map { paymentMethodTyps in
                paymentMethodTyps.filter { paymentType in
                    paymentType.method == .bankAccount(.fiat(currency)) || paymentType.method == .bankTransfer(.fiat(currency))
                }
            }
    }

    func bankTransferLimits(for currency: FiatCurrency) -> Single<PaymentLimits> {
        paymentMethodService
            .eligiblePaymentMethods(for: currency)
            .map { $0.filter { $0.method == .bankTransfer(.fiat(currency)) } }
            .map { paymentMetodTypes in
                guard let item = paymentMetodTypes.first else {
                    fatalError("Expected a suggested payment method type")
                }
                guard case .suggested(let suggested) = item else {
                    fatalError("Expected a sugggested payment method type")
                }
                return .init(
                    min: suggested.min,
                    max: .init(
                        transactional: suggested.max,
                        daily: suggested.maxDaily,
                        annual: suggested.maxAnnual
                    )
                )
            }
    }
}
