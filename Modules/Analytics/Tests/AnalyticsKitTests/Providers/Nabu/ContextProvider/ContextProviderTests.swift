// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Mockingbird
import XCTest

@testable import AnalyticsKit

final class ContextProviderTests: XCTestCase {

    var contextProvider: ContextProvider?

    let guidRepositoryMock = mock(GuidRepositoryAPI.self)

    override func setUpWithError() throws {
        try super.setUpWithError()
        let timeZone = TimeZone(abbreviation: "UTC")!
        let locale = Locale(identifier: "en-US")
        contextProvider = ContextProvider(guidProvider: guidRepositoryMock, timeZone: timeZone, locale: locale)
    }

    override func tearDownWithError() throws {
        contextProvider = nil
        try super.tearDownWithError()
    }

    func test_contextProvider_returnsCorrectAnonymousId() throws {
        let guid = "guid"
        given(guidRepositoryMock.getGuid()) ~> guid

        XCTAssertEqual(contextProvider?.anonymousId, guid)
    }

    func test_contextProvider_returnsCorrectContext() throws {
        let context = contextProvider?.context

        XCTAssertEqual(context?.locale, "en-US")
        XCTAssertEqual(context?.timezone, "GMT")
        XCTAssertEqual(context?.os.name, "iOS")
        XCTAssertEqual(context?.app.namespace, "com.apple.dt.xctest.tool")
        XCTAssertEqual(context?.device.manufacturer, "Apple")
        XCTAssertEqual(context?.device.type, "ios")
        XCTAssertEqual(context?.device.model, UIDevice.current.model)
        XCTAssertEqual(context?.device.name, UIDevice.current.name)
        XCTAssertEqual(context?.device.id, UIDevice.current.identifierForVendor?.uuidString)
    }
}
