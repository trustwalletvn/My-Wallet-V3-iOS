// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A URI scheme that conforms to BIP 21 (https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki)
public protocol BIP21URI: CryptoAssetQRMetadata {
    static var scheme: String { get }

    init(address: String, amount: String?)
}

extension BIP21URI {
    public var absoluteString: String {
        let prefix = includeScheme ? "\(Self.scheme):" : ""
        let uri = "\(prefix)\(address)"
        if let amount = amount {
            return "\(uri)?amount=\(amount)"
        }
        return uri
    }

    public init?(url: URL) {
        guard url.scheme == Self.scheme else {
            return nil
        }

        let address: String?
        let amount: String?
        let urlString = url.absoluteString
        let doubleSlash = "//"
        let colon = ":"
        let bitpayPaymentLink = "https://bitpay.com/"
        let hasBitpayPaymentUrl = urlString.contains(bitpayPaymentLink)

        if urlString.contains(doubleSlash), !hasBitpayPaymentUrl {
            let queryArgs = url.queryArgs

            address = url.host ?? queryArgs["address"]
            amount = queryArgs["amount"]
        } else if urlString.contains(colon), hasBitpayPaymentUrl {
            return nil
        } else if urlString.contains(colon) {
            // Handle web format (e.g. "scheme:1Amu4uPJnYbUXX2HhDFMNq7tSneDwWYDyv")
            guard let request = urlString.components(separatedBy: colon).last else {
                return nil
            }
            let requestComponents = request.components(separatedBy: "?")
            if let args = requestComponents.last {
                let queryArgs = args.queryArgs
                address = requestComponents.first ?? queryArgs["address"]
                amount = queryArgs["amount"]
            } else {
                address = requestComponents.first
                amount = nil
            }
        } else {
            address = nil
            amount = nil
        }

        guard let address = address else {
            return nil
        }

        self.init(address: address, amount: amount)
    }
}
