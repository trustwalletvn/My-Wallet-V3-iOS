// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkKit
import ToolKit

public protocol SupportedAssetsRemoteServiceAPI {
    func refreshCustodialAssetsCache() -> AnyPublisher<Void, Never>
}

final class SupportedAssetsRemoteService: SupportedAssetsRemoteServiceAPI {

    private let client: SupportedAssetsClientAPI
    private let filePathProvider: SupportedAssetsFilePathProviderAPI
    private let fileIO: FileIOAPI
    private let jsonDecoder: JSONEncoder
    private var fileURL: URL? {
        filePathProvider.remoteCustodialAssets
    }

    init(
        client: SupportedAssetsClientAPI = resolve(),
        filePathProvider: SupportedAssetsFilePathProviderAPI = resolve(),
        fileIO: FileIOAPI = resolve(),
        jsonDecoder: JSONEncoder = .init()
    ) {
        self.client = client
        self.filePathProvider = filePathProvider
        self.fileIO = fileIO
        self.jsonDecoder = jsonDecoder
    }

    func refreshCustodialAssetsCache() -> AnyPublisher<Void, Never> {
        client.custodialAssets
            .eraseError()
            .flatMap { [fileURL, fileIO, jsonDecoder] response -> AnyPublisher<Void, Error> in
                fileIO
                    .write(response, to: fileURL!, encodedUsing: jsonDecoder)
                    .eraseError()
                    .publisher
            }
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }
}
