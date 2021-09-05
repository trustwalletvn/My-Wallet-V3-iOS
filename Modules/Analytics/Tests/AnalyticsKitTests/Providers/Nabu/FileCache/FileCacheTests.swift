// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Mockingbird
import XCTest

@testable import AnalyticsKit

final class FileCacheTests: XCTestCase {

    var fileCache: FileCache?

    let event = Event(title: "TestEvent", properties: ["test_property": "VALUE"])

    override func setUpWithError() throws {
        try super.setUpWithError()
        fileCache = FileCache(fileManager: .default, jsonEncoder: JSONEncoder(), jsonDecoder: JSONDecoder())
    }

    override func tearDownWithError() throws {
        fileCache = nil
        try super.tearDownWithError()
    }

    func test_fileCache_savesAndReadsCache() throws {
        fileCache?.save(events: [event])
        let readEvent = fileCache?.read()?.first

        XCTAssertEqual(readEvent?.name, event.name)
        XCTAssertEqual(readEvent?.properties, event.properties)
    }

    func test_fileCache_removesFileAfterReading() throws {
        fileCache?.save(events: [event])
        _ = fileCache?.read()?.first

        XCTAssertNil(fileCache?.read()?.first)
    }
}
