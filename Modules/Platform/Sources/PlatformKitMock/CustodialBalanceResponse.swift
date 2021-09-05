// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit

extension CustodialBalanceResponse {

    static let mockJson = """
    {
      "BTC": {
        "pendingDeposit": "0",
        "pendingWithdrawal": "0",
        "available": "0",
        "withdrawable": "0",
        "pending": "0"
      },
      "ETH": {
        "pendingDeposit": "100",
        "pendingWithdrawal": "0",
        "available": "100",
        "withdrawable": "100",
        "pending": "100"
      }
    }
    """

    static func mock(json: String) -> CustodialBalanceResponse! {
        do {
            return try JSONDecoder().decode(CustodialBalanceResponse.self, from: Data(json.utf8))
        } catch {
            return nil
        }
    }
}
