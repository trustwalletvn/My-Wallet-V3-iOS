// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum AddressValidationError: Error {
    case unknown
    case eip55ChecksumFailed
    case containsInvalidCharacters
    case invalidLength
}
