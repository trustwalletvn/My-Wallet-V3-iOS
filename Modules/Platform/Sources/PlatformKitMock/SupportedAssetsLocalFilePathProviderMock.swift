// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit

final class SupportedAssetsLocalFilePathProviderMock: SupportedAssetsFilePathProviderAPI {
    var remoteERC20Assets: URL?
    var localERC20Assets: URL?
    var remoteCustodialAssets: URL?
    var localCustodialAssets: URL?
}
