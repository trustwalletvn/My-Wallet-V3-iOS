// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

protocol ERC20AccountServiceAPI {

    /// Checks if the provided `address` is a contract address
    /// - Parameter address: the ethereum address to check
    func isContract(address: String) -> Single<Bool>
}

final class ERC20AccountService: ERC20AccountServiceAPI {
    private typealias Tag = DependencyContainer.Tags.ERC20AccountService

    private let addresses: Atomic<[String: Bool]>
    private let accountClient: ERC20AccountAPIClientAPI

    init(
        accountClient: ERC20AccountAPIClientAPI = resolve(),
        addressLookupCache: Atomic<[String: Bool]> = resolve(tag: Tag.isContractAddressCache)
    ) {
        self.accountClient = accountClient
        addresses = addressLookupCache
    }

    func isContract(address: String) -> Single<Bool> {
        guard let isContractAddress = addresses.value[address] else {
            return accountClient
                .isContract(address: address)
                .map(\.contract)
                .do(onSuccess: { [weak self] isContractAddress in
                    self?.addresses.mutate { addresses in
                        addresses[address] = isContractAddress
                    }
                })
        }
        return .just(isContractAddress)
    }
}
