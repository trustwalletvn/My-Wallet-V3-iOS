// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum PayloadDecoderError: Error {
    case decodingError
}

final class PayloadDecoder {

    private static let wrapperDecoder = JSONDecoder()

    func decode(wrapper: String) -> Result<WalletPayloadWrapper, Error> {
        decode(string: wrapper, with: Self.wrapperDecoder)
    }

    private func decode<T: Decodable>(string payload: String, with decoder: JSONDecoder) -> Result<T, Error> {
        guard let data = payload.data(using: .utf8) else {
            return .failure(PayloadDecoderError.decodingError)
        }
        return Result {
            try decoder.decode(T.self, from: data)
        }
    }
}
