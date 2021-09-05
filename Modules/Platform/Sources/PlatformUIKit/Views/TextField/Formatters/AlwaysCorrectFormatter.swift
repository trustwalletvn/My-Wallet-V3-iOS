// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class AlwaysCorrectFormatter: TextFormatting {
    public func format(_ string: String, operation: TextInputOperation) -> TextFormattingSource {
        .original(text: string)
    }
}
