// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import ToolKit

struct QuoteResponse: Decodable {
    let time: String
    let rate: String
    let rateWithoutFee: String
    /* the fee value is more of a feeRate (ie it is the fee per 1 unit of crypto) to get the actual
     "fee" you'll need to multiply by amount of crypto
     */
    let fee: String
}

public struct Quote {

    // MARK: - Types

    enum SetupError: Error {
        case createFromMajorValue
        case dateFormatting
        case rateParsing
        case feeParsing
    }

    // MARK: - Properties

    public let time: Date
    public let fee: FiatValue
    public let rate: FiatValue
    public let estimatedAmount: CryptoValue

    private let dateFormatter = DateFormatter.sessionDateFormat

    // MARK: - Setup

    init(to cryptoCurrency: CryptoCurrency, amount: FiatValue, response: QuoteResponse) throws {
        guard let time = dateFormatter.date(from: response.time) else {
            throw SetupError.dateFormatting
        }
        guard let rate = BigInt(response.rate) else {
            throw SetupError.rateParsing
        }
        guard let feeRateMinor = Decimal(string: response.fee) else {
            throw SetupError.feeParsing
        }
        let majorEstimatedAmount: Decimal = amount.amount.decimalDivision(divisor: rate)
        // Decimal string interpolation always uses '.' (full stop) as decimal separator, because of that we will use US locale.
        guard let estimatedAmount = CryptoValue.create(major: "\(majorEstimatedAmount)", currency: cryptoCurrency)
        else { throw SetupError.createFromMajorValue }
        self.estimatedAmount = estimatedAmount
        let feeAmountMinor = feeRateMinor * estimatedAmount.displayMajorValue
        // Decimal string interpolation always uses '.' (full stop) as decimal separator, because of that we will use US locale.
        fee = FiatValue.create(minor: "\(feeAmountMinor)", currency: amount.currencyType)!
        self.time = time
        self.rate = FiatValue.create(minor: response.rate, currency: amount.currencyType)!
    }
}
