// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

/// A protocol that provides the client with biometry API
public protocol BiometryProviding: AnyObject {
    var canAuthenticate: Result<Biometry.BiometryType, Biometry.EvaluationError> { get }
    var configuredType: Biometry.BiometryType { get }
    var configurationStatus: Biometry.Status { get }
    var supportedBiometricsType: Biometry.BiometryType { get }

    func authenticate(reason: Biometry.Reason) -> Single<Void>
}
