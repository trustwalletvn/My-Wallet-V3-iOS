// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct LatestBlockResponse: Decodable {

    /// The latest block number
    public let number: Int

    enum CodingKeys: String, CodingKey {
        case number
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let number = Int(try values.decode(String.self, forKey: .number)) else {
            throw DecodingError.dataCorruptedError(
                forKey: .number,
                in: values,
                debugDescription: "'number' field can't be converted to Int"
            )
        }
        self.number = number
    }
}
