// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

public struct PaymentMethodRemovalData {
    public enum MethodType {
        case card(CardType)
        case beneficiary(Beneficiary.AccountType)
    }

    public let id: String
    public let title: String
    public let description: String
    public let event: AnalyticsEvents.SimpleBuy
    public let type: MethodType

    public init(
        id: String,
        title: String,
        description: String,
        event: AnalyticsEvents.SimpleBuy,
        type: MethodType
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.event = event
        self.type = type
    }
}
