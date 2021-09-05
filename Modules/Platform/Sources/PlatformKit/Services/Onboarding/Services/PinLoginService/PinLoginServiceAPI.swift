// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

/// This service API is used to decrypt the password from the pin decryption key.
public protocol PinLoginServiceAPI: AnyObject {
    func password(from pinDecryptionKey: String) -> Single<String>
}
