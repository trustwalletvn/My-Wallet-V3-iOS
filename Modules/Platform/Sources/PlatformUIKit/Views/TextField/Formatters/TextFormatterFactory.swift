// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A factory for text formatters
public enum TextFormatterFactory {

    public static var alwaysCorrect: TextFormatting {
        AlwaysCorrectFormatter()
    }

    public static var cardNumber: TextFormatting {
        CardNumberFormatter()
    }

    public static var cardCVV: TextFormatting {
        CVVFormatter()
    }

    public static var cardExpirationDate: TextFormatting {
        CardExpirationDateFormatter()
    }

    public static var mobile: TextFormatting {
        MobileNumberTextFormatter()
    }
}
