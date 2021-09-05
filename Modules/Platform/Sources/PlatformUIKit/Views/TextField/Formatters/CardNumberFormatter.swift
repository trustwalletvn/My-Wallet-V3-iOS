// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

final class CardNumberFormatter: TextFormatting {

    // MARK: - Properties

    private let illegalCharacterSet = CharacterSet.decimalDigits.inverted

    // MARK: - TextCorrectorAPI

    func format(_ string: String, operation: TextInputOperation) -> TextFormattingSource {
        var processedString = string
        processedString.removeAll { illegalCharacterSet.contains($0) }

        let cardType = CardType.determineType(from: processedString)

        if cardType.isKnown {
            processedString = format(string: processedString, by: cardType.parts)
        } else {
            processedString = String(processedString.prefix(CardType.maxPossibleLength))
        }

        return string == processedString ? .original(text: string) : .formatted(to: processedString)
    }

    private func format(string: String, by parts: [Int]) -> String {
        var result: [String] = []
        var string = string
        for part in parts where !string.isEmpty {
            let substring = String(string.prefix(part))
            result.append(substring)
            string = String(string.dropFirst(part))
        }
        return result.joined(separator: " ")
    }
}
