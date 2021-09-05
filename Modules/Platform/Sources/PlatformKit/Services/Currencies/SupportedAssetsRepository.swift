// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

protocol SupportedAssetsRepositoryAPI {
    var erc20Assets: SupportedAssets { get }
    var custodialAssets: SupportedAssets { get }
}

final class SupportedAssetsRepository: SupportedAssetsRepositoryAPI {

    let localService: SupportedAssetsServiceAPI

    private(set) lazy var erc20Assets: SupportedAssets = {
        switch localService.erc20Assets {
        case .success(let response):
            return SupportedAssets(response: response)
        case .failure(let error):
            #if INTERNAL_BUILD
            fatalError("Can' load local ERC20 assets. \(error.localizedDescription)")
            #else
            return SupportedAssets.empty
            #endif
        }
    }()

    private(set) lazy var custodialAssets: SupportedAssets = {
        switch localService.custodialAssets {
        case .success(let response):
            return SupportedAssets(response: response)
        case .failure(let error):
            #if INTERNAL_BUILD
            fatalError("Can' load local ERC20 assets. \(error.localizedDescription)")
            #else
            return SupportedAssets.empty
            #endif
        }
    }()

    init(localService: SupportedAssetsServiceAPI = resolve()) {
        self.localService = localService
    }
}
