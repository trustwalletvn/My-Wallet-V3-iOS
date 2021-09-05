// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

public final class CardExpiryTextFieldViewModel: TextFieldViewModel {

    // MARK: - Setup

    public init(messageRecorder: MessageRecording) {
        super.init(
            with: .expirationDate,
            validator: TextValidationFactory.Card.expirationDate,
            formatter: TextFormatterFactory.cardExpirationDate,
            messageRecorder: messageRecorder
        )
    }
}
