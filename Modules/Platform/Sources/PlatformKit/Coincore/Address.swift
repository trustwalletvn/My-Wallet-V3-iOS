// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public protocol ReceiveAddress: TransactionTarget {
    var address: String { get }
    var memo: String? { get }
}

extension ReceiveAddress {
    public var memo: String? {
        nil
    }
}

public protocol InvoiceTarget {}

public protocol CryptoReceiveAddress: ReceiveAddress, CryptoTarget {}

public protocol CryptoAssetQRMetadataProviding {
    var metadata: CryptoAssetQRMetadata { get }
}

public enum ReceiveAddressError: Error {
    case notSupported
}
