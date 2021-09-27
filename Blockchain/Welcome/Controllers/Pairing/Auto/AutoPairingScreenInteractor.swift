// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureAuthenticationDomain
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class AutoPairingScreenInteractor {

    // MARK: - Properties

    /// Streams potential parsing errors
    var error: Observable<Error> {
        errorRelay.asObservable()
    }

    let parser = PairingDataQRCodeParser()

    /// The service responsible for taking the parser code and the login using it
    private let service: AutoWalletPairingServiceAPI

    private let walletFetcher: AuthenticationCoordinator

    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let errorRelay = PublishRelay<Error>()

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        service: AutoWalletPairingServiceAPI = resolve(),
        walletFetcher: AuthenticationCoordinator = AuthenticationCoordinator.shared,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.service = service
        self.analyticsRecorder = analyticsRecorder
        self.walletFetcher = walletFetcher
    }

    /// Receives the result of the paiting code and passes it on to the login service
    func handlePairingCodeResult(result: Result<PairingData, PairingDataQRCodeParser.PairingCodeParsingError>) {
        switch result {
        case .success(let pairingCode):
            analyticsRecorder.record(event: AnalyticsEvents.Onboarding.walletAutoPairing)
            login(with: pairingCode)
        case .failure(let error):
            analyticsRecorder.record(event: AnalyticsEvents.Onboarding.walletAutoPairingError)
            errorRelay.accept(error)
        }
    }

    // MARK: - Private methods

    /// Login using pairing data retrieved from parsing the QR code
    private func login(with pairingData: PairingData) {
        service
            .pair(using: pairingData)
            .asObservable()
            .asSingle()
            .subscribe(
                onSuccess: walletFetcher.authenticate,
                onError: errorRelay.accept
            )
            .disposed(by: disposeBag)
    }
}
