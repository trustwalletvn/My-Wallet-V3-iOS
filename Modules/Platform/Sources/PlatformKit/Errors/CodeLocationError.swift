// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

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
