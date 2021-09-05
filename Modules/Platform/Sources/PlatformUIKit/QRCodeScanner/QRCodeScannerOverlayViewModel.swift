// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

final class QRCodeScannerOverlayViewModel {

    /// The visibility of the camera roll button
    var cameraRollButtonVisibility: Driver<Visibility> {
        cameraRollButtonVisibilityRelay
            .asDriver(onErrorJustReturn: .hidden)
    }

    var subtitleLabelContent: Driver<LabelContent> {
        subtitleLabelContentRelay.asDriver()
    }

    /// Is the flash enabled
    var flashEnabled: Driver<Bool> {
        qrCodeFlashService.isEnabled
    }

    /// Streams events when a scan was successful
    let scanSuccess = PublishRelay<Bool>()

    /// Streams events when the flash button is tapped
    let flashTapRelay = PublishRelay<Void>()

    /// Streams events when the camera button is tapped
    let cameraTapRelay = PublishRelay<Void>()

    /// Closure for handling camera tap events
    var cameraButtonTapped: (() -> Void)?

    private let qrCodeFlashService = QRCodeScannerFlashService()
    private let cameraRollButtonVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let subtitleLabelContentRelay = BehaviorRelay<LabelContent>(value: .empty)
    private let disposeBag = DisposeBag()

    init(supportsCameraRoll: Bool, subtitleText: String?) {
        cameraRollButtonVisibilityRelay.accept(supportsCameraRoll ? .visible : .hidden)
        if let subtitleText = subtitleText {
            let labelContent = LabelContent(text: subtitleText, font: .main(.medium, 14), color: .white, alignment: .left)
            subtitleLabelContentRelay.accept(labelContent)
        }
        flashTapRelay
            .bindAndCatch(weak: self) { (self) in
                self.toggleFlash()
            }
            .disposed(by: disposeBag)

        cameraTapRelay
            .bindAndCatch(weak: self) { (self) in
                self.cameraButtonTapped?()
            }
            .disposed(by: disposeBag)
    }

    private func toggleFlash() {
        qrCodeFlashService.toggleFlash()
    }
}
