// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public protocol CodeLocationError: Error, CustomStringConvertible {
    var message: String { get set }
    var location: CodeLocation { get set }

    init(message: String, location: CodeLocation)
}

extension CodeLocationError {

    public init(
        _ message: String,
        _ function: String = #function,
        _ file: String = #file,
        _ line: Int = #line
    ) {
        self.init(message: message, location: .init(function, file, line))
    }

    public var description: String {
        "\(message) ← \(location)"
    }
}

public struct CodeLocation: CustomStringConvertible {

    let function: String
    let file: String
    let line: Int

    public init(
        _ function: String = #function,
        _ file: String = #file,
        _ line: Int = #line
    ) {
        (self.function, self.file, self.line) = (function, file, line)
    }

    public var description: String {
        "\(function)\t\(file)\t\(line)"
    }
}
