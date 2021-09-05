// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import ToolKit

final class SecureChannelCandidateStore {
    private var candidateInWait = Atomic<SecureChannelConnectionCandidate?>(nil)

    func store(_ candidate: SecureChannelConnectionCandidate) {
        if let current = candidateInWait.value, current.timestamp > candidate.timestamp {
            // Current candidate in wait is more recent.
            return
        } else {
            candidateInWait.mutate { $0 = candidate }
        }
    }

    func retrieve() -> SecureChannelConnectionCandidate? {
        let candidate = candidateInWait.value
        candidateInWait.mutate { $0 = nil }
        return candidate
    }
}
