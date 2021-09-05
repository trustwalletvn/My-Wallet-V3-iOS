// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public protocol QRCodeScannerParsing {
    associatedtype Success
    associatedtype Failure: Error

    func parse(scanResult: Result<String, QRScannerError>, completion: ((Result<Success, Failure>) -> Void)?)
}

public final class AnyQRCodeScannerParsing<Success, Failure: Error>: QRCodeScannerParsing {

    private let parse: (Result<String, QRScannerError>, ((Result<Success, Failure>) -> Void)?) -> Void

    public init<Parser: QRCodeScannerParsing>(parser: Parser) where Parser.Success == Success, Parser.Failure == Failure {
        parse = parser.parse
    }

    public func parse(scanResult: Result<String, QRScannerError>, completion: ((Result<Success, Failure>) -> Void)?) {
        parse(scanResult, completion)
    }
}
