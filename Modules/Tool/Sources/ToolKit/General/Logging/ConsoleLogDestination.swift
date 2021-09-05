// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A destination wherein log statements are outputted to standard output (i.e. XCode's console)
public class ConsoleLogDestination: LogDestination {
    public func log(statement: String, level: LogLevel) {
        print(statement)
    }
}
