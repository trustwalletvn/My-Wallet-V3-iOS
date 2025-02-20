// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit

final class MockFeatureFlagsService: FeatureFlagsServiceAPI {

    struct RecordedInvocations {
        var enable: [FeatureFlag] = []
        var disable: [FeatureFlag] = []
        var isEnabled: [FeatureFlag] = []
        var object: [FeatureFlag] = []
    }

    struct StubbedResults {
        var enable: AnyPublisher<Void, Never> = .empty()
        var disable: AnyPublisher<Void, Never> = .empty()
        var object: AnyPublisher<Codable?, FeatureFlagError> = .empty()
    }

    private(set) var recordedInvocations = RecordedInvocations()
    var stubbedResults = StubbedResults()

    private var features: [FeatureFlag: Bool] = [:]

    func enable(_ feature: FeatureFlag) -> AnyPublisher<Void, Never> {
        features[feature] = true
        recordedInvocations.enable.append(feature)
        return stubbedResults.enable
    }

    func disable(_ feature: FeatureFlag) -> AnyPublisher<Void, Never> {
        features[feature] = false
        recordedInvocations.disable.append(feature)
        return stubbedResults.disable
    }

    func isEnabled(_ feature: FeatureFlag) -> AnyPublisher<Bool, Never> {
        recordedInvocations.isEnabled.append(feature)
        return .just(features[feature] ?? false)
    }

    func object<Feature: Codable>(for feature: FeatureFlag) -> AnyPublisher<Feature?, FeatureFlagError> {
        recordedInvocations.object.append(feature)
        return stubbedResults.object
            .map { $0 as? Feature }
            .eraseToAnyPublisher()
    }
}
