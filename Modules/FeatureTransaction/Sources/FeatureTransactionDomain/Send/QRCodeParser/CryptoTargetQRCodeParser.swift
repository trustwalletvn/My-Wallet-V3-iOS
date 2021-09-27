// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

public protocol CryptoTargetPayloadFactoryAPI {
    func create(fromString string: String?, asset: CryptoCurrency) -> Single<CryptoTargetQRCodeParser.Target>
}

public final class CryptoTargetQRCodeParser: QRCodeScannerParsing {

    public enum CryptoTargetParserError: Error {
        case scanError(QRScannerError)
        case unableToCreatePayload
    }

    public enum Target {
        case address(CryptoReceiveAddress)
        case bitpay(String)
    }

    private let assetType: CryptoCurrency
    private let payloadFactory: CryptoTargetPayloadFactoryAPI
    private let disposeBag = DisposeBag()

    public init(
        assetType: CryptoCurrency,
        payloadFactory: CryptoTargetPayloadFactoryAPI = resolve()
    ) {
        self.assetType = assetType
        self.payloadFactory = payloadFactory
    }

    public func parse(scanResult: Result<String, QRScannerError>, completion: ((Result<Target, CryptoTargetParserError>) -> Void)?) {
        switch scanResult {
        case .success(let address):
            handleSuccess(address: address, completion: completion)
        case .failure(let error):
            completion?(.failure(.scanError(error)))
        }
    }

    private func handleSuccess(address: String, completion: ((Result<Target, CryptoTargetParserError>) -> Void)?) {
        payloadFactory
            .create(fromString: address, asset: assetType)
            .subscribe(onSuccess: { target in
                completion?(.success(target))
            }, onError: { _ in
                completion?(.failure(.unableToCreatePayload))
            })
            .disposed(by: disposeBag)
    }
}
