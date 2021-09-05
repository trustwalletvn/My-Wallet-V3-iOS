// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import XCTest

@testable import AnalyticsKit

final class AnalyticsEventTests: XCTestCase {
    enum NabuEvent: AnalyticsEvent {
        var type: AnalyticsEventType { .nabu }

        case simpleEventWithoutParams
        case eventWithParams(nameOfTheParam: String, valueOfTheParam: Double)
        case eventWithCustom(custom: CustomEnum)

        enum CustomEnum: String, StringRawRepresentable {
            case type = "TYPE"
        }
    }

    enum FirebaseEvent: AnalyticsEvent {
        case eventWithParams(nameOfTheParam: String, valueOfTheParam: Double)
    }

    func test_nabuAnalyticsEventReflection_simpleEventTitleAndParams() throws {
        let event: NabuEvent = .simpleEventWithoutParams

        XCTAssertEqual(event.name, "Simple Event Without Params")
        XCTAssertEqual(event.params?.count, 0)
    }

    func test_nabuAnalyticsEventReflection_advancedEventTitleAndParams() throws {
        let event: NabuEvent = .eventWithParams(nameOfTheParam: "The Name", valueOfTheParam: 3)

        XCTAssertEqual(event.name, "Event With Params")
        XCTAssertEqual(event.params?.count, 2)
        XCTAssertEqual(event.params?["name_of_the_param"] as? String, "The Name")
        XCTAssertEqual(event.params?["value_of_the_param"] as? Double, 3)
    }

    func test_nabuAnalyticsEventReflection_advancedEventCustomEnum() throws {
        let event: NabuEvent = .eventWithCustom(custom: .type)

        XCTAssertEqual(event.name, "Event With Custom")
        XCTAssertEqual(event.params?.count, 1)
        XCTAssertEqual(event.params?["custom"] as? String, "TYPE")
    }

    func test_firebaseAnalyticsEventReflection_advancedEventReflectedTitleAndParams() throws {
        let event: FirebaseEvent = .eventWithParams(nameOfTheParam: "The Name", valueOfTheParam: 3)

        XCTAssertEqual(event.name, "Event With Params")
        XCTAssertNil(event.params)
    }
}
