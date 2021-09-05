// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

final class CVVFormatter: TextFormatting {
    func format(_ string: String, operation: TextInputOperation) -> TextFormattingSource {
        let processedString = string
            .compactMap { Int(String($0)) }
            .map { String($0) }
            .prefix(4)
            .joined()
        return string == processedString ? .original(text: string) : .formatted(to: String(processedString))
    }
}
