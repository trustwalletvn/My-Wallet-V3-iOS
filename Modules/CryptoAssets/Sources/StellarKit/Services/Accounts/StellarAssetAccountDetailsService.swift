// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import stellarsdk
import ToolKit

public protocol StellarAccountDetailsServiceAPI {
    func accountDetails(for accountID: String) -> Single<StellarAccountDetails>
}

final class StellarAccountDetailsService: StellarAccountDetailsServiceAPI {

    private let horizonProxy: HorizonProxyAPI

    init(horizonProxy: HorizonProxyAPI = resolve()) {
        self.horizonProxy = horizonProxy
    }

    func accountDetails(for accountID: String) -> Single<StellarAccountDetails> {
        horizonProxy.accountResponse(for: accountID)
            .map { [horizonProxy] response -> StellarAccountDetails in
                let minBalance = horizonProxy.minimumBalance(subentryCount: response.subentryCount)
                return response.toAssetAccountDetails(minimumBalance: minBalance)
            }
            .catchError { error in
                // If the network call to Horizon fails due to there not being a default account (i.e. account is not yet
                // funded), catch that error and return a StellarAccount with 0 balance
                switch error {
                case StellarAccountError.noDefaultAccount:
                    return Single.just(StellarAccountDetails.unfunded(accountID: accountID))
                default:
                    throw error
                }
            }
    }
}

extension stellarsdk.AccountService {
    fileprivate func getAccountDetails(accountId: String) -> Single<AccountResponse> {
        Single<AccountResponse>.create { [weak self] event -> Disposable in
            guard let self = self else {
                event(.error(ToolKitError.nullReference(Self.self)))
                return Disposables.create()
            }
            self.getAccountDetails(
                accountId: accountId,
                response: { response in
                    switch response {
                    case .success(details: let details):
                        event(.success(details))
                    case .failure(error: let error):
                        event(.error(error.toStellarServiceError()))
                    }
                }
            )
            return Disposables.create()
        }
    }
}
