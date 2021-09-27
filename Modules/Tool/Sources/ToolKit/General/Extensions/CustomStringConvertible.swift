// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension CustomStringConvertible {

    @inlinable
    @discardableResult
    public func peek(
        as level: LogLevel = .debug,
        if condition: KeyPath<Self, Bool>? = nil,
        using logger: Logger = .shared,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Self {
        if let condition = condition, self[keyPath: condition] == false { return self }
        logger.log("\(self)", level: level, file: file, function: function, line: line)
        return self
    }

    @inlinable
    @discardableResult
    public func peek<Message>(
        as level: LogLevel = .debug,
        _ message: @escaping @autoclosure () -> Message,
        if condition: KeyPath<Self, Bool>? = nil,
        using logger: Logger = .shared,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Self where Message: CustomStringConvertible {
        if let condition = condition, self[keyPath: condition] == false { return self }
        logger.log("\(message()) \(self)", level: level, file: file, function: function, line: line)
        return self
    }

    @inlinable
    @discardableResult
    public func peek<Property>(
        as level: LogLevel = .debug,
        _ keyPath: KeyPath<Self, Property>,
        if condition: KeyPath<Self, Bool>? = nil,
        using logger: Logger = .shared,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Self where Property: CustomStringConvertible {
        if let condition = condition, self[keyPath: condition] == false { return self }
        logger.log("\(self[keyPath: keyPath])", level: level, file: file, function: function, line: line)
        return self
    }

    @inlinable
    @discardableResult
    public func peek<Message, Property>(
        as level: LogLevel = .debug,
        _ message: @escaping @autoclosure () -> Message,
        _ keyPath: KeyPath<Self, Property>,
        if condition: KeyPath<Self, Bool>? = nil,
        using logger: Logger = .shared,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Self where Message: CustomStringConvertible, Property: CustomStringConvertible {
        if let condition = condition, self[keyPath: condition] == false { return self }
        logger.log("\(message()) \(self[keyPath: keyPath])", level: level, file: file, function: function, line: line)
        return self
    }
}
