// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit

public protocol QRCodeScannerTextViewModel {
    var loadingText: String? { get }
    var headerText: String { get }
    var subtitleText: String? { get }
}

extension QRCodeScannerTextViewModel {
    public var loadingText: String? { nil }
    public var subtitleText: String? { nil }
}

protocol QRCodeScannerViewModelProtocol: AnyObject {
    var scanningStarted: (() -> Void)? { get set }
    var scanningStopped: (() -> Void)? { get set }
    var closeButtonTapped: (() -> Void)? { get set }
    var scanComplete: ((Result<String, QRScannerError>) -> Void)? { get set }
    var closeHandler: (() -> Void)? { get set }

    var videoPreviewLayer: CALayer? { get }
    var loadingText: String? { get }
    var headerText: String { get }
    var overlayViewModel: QRCodeScannerOverlayViewModel { get }

    func closeButtonPressed()
    func startReadingQRCode(from scannableArea: QRCodeScannableArea)
    func handleDismissCompleted(with scanResult: Result<String, QRScannerError>)

    func viewWillDisappear()
    func handleSelectedQRImage(_ image: UIImage)
}

public enum QRCodeScannerParsingOptions {

    /// Strict approach, only act on the link using the given parser
    case strict

    /// Lax parsing, allow acting on other routes at well
    case lax(routes: [DeepLinkRoute])
}

final class QRCodeScannerViewModel<P: QRCodeScannerParsing>: QRCodeScannerViewModelProtocol {

    typealias CompletionHandler = ((Result<P.Success, P.Failure>) -> Void)

    var scanningStarted: (() -> Void)?
    var scanningStopped: (() -> Void)?
    var closeButtonTapped: (() -> Void)?
    var scanComplete: ((Result<String, QRScannerError>) -> Void)?
    var closeHandler: (() -> Void)?

    let overlayViewModel: QRCodeScannerOverlayViewModel

    var videoPreviewLayer: CALayer? {
        scanner.videoPreviewLayer
    }

    var loadingText: String? {
        textViewModel.loadingText
    }

    var headerText: String {
        textViewModel.headerText
    }

    private let parser: AnyQRCodeScannerParsing<P.Success, P.Failure>
    private let textViewModel: QRCodeScannerTextViewModel
    private let scanner: QRCodeScannerProtocol
    private let completed: (Result<P.Success, P.Failure>) -> Void
    private let deepLinkQRCodeRouter: DeepLinkQRCodeRouter

    init?(
        parser: P,
        additionalParsingOptions: QRCodeScannerParsingOptions = .strict,
        textViewModel: QRCodeScannerTextViewModel,
        supportsCameraRoll: Bool,
        scanner: QRCodeScannerProtocol,
        completed: CompletionHandler?,
        closeHandler: (() -> Void)? = nil,
        deepLinkHandler: DeepLinkHandling = resolve(),
        deepLinkRouter: DeepLinkRouting = resolve()
    ) {
        guard let completed = completed else { return nil }

        let additionalLinkRoutes: [DeepLinkRoute]
        switch additionalParsingOptions {
        case .lax(routes: let routes):
            additionalLinkRoutes = routes
        case .strict:
            additionalLinkRoutes = []
        }
        deepLinkQRCodeRouter = DeepLinkQRCodeRouter(
            supportedRoutes: additionalLinkRoutes,
            deepLinkHandler: deepLinkHandler,
            deepLinkRouter: deepLinkRouter
        )
        self.parser = AnyQRCodeScannerParsing(parser: parser)
        self.textViewModel = textViewModel
        self.scanner = scanner
        self.completed = completed
        self.closeHandler = closeHandler
        overlayViewModel = .init(supportsCameraRoll: supportsCameraRoll, subtitleText: textViewModel.subtitleText)
        self.scanner.delegate = self
    }

    func viewWillDisappear() {
        scanner.stopReadingQRCode(complete: nil)
    }

    func closeButtonPressed() {
        scanner.stopReadingQRCode(complete: nil)
        closeButtonTapped?()
    }

    func startReadingQRCode(from scannableArea: QRCodeScannableArea) {
        scanner.startReadingQRCode(from: scannableArea)
    }

    func handleSelectedQRImage(_ image: UIImage) {
        scanner.handleSelectedQRImage(image)
    }

    func handleDismissCompleted(with scanResult: Result<String, QRScannerError>) {

        // In case the designate scan purpose was not fulfilled, try look for supported deeplink.
        let completion = { [weak self] (result: Result<P.Success, P.Failure>) in
            guard let self = self else { return }
            switch result {
            case .failure:
                if !self.deepLinkQRCodeRouter.routeIfNeeded(using: scanResult) {
                    self.completed(result)
                }
            case .success:
                self.completed(result)
            }
        }
        parser.parse(scanResult: scanResult, completion: completion)
    }
}

extension QRCodeScannerViewModel: QRCodeScannerDelegate {
    func scanComplete(with result: Result<String, QRScannerError>) {
        overlayViewModel.scanSuccess.accept(result.isSuccess)
        scanComplete?(result)
    }

    func didStartScanning() {
        scanningStarted?()
    }

    func didStopScanning() {
        scanningStopped?()
    }
}
