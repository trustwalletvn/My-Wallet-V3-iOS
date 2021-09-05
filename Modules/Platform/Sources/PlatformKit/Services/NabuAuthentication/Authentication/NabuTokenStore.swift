// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit

public final class NabuTokenStore {

    public var sessionTokenDataPublisher: AnyPublisher<NabuSessionTokenResponse?, Never> {
        .just(sessionTokenData.value)
    }

    public var sessionToken: String? {
        sessionTokenData.value?.token
    }

    var requiresRefresh: AnyPublisher<Bool, Never> {
        .just(sessionTokenData.value == nil)
    }

    private let sessionTokenData = Atomic<NabuSessionTokenResponse?>(nil)

    init() {
        NotificationCenter.when(.logout) { [weak self] _ in
            self?.sessionTokenData.mutate { $0 = nil }
        }
    }

    func invalidate() -> AnyPublisher<Void, Never> {
        let sessionTokenData = self.sessionTokenData
        return Deferred {
            Future { [sessionTokenData] promise in
                sessionTokenData.mutate { $0 = nil }
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }

    func store(
        _ sessionTokenData: NabuSessionTokenResponse
    ) -> AnyPublisher<NabuSessionTokenResponse, Never> {
        let sessionToken = self.sessionTokenData
        return Deferred {
            Future { [sessionToken] promise in
                sessionToken.mutate { $0 = sessionTokenData }
                promise(.success(sessionTokenData))
            }
        }
        .eraseToAnyPublisher()
    }
}
