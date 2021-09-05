// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformUIKit
@testable import PlatformUIKitMock
import XCTest

class QRCodeScannerTests: XCTestCase {
    var subject: QRCodeScanner!
    var deviceInputMock: MockCaptureInput!
    var captureSession: CaptureSessionMock!
    // swiftlint:disable weak_delegate
    var delegate: QRCodeScannerDelegateMock!

    override func setUp() {
        super.setUp()
        deviceInputMock = MockCaptureInput()
        captureSession = CaptureSessionMock()
        delegate = QRCodeScannerDelegateMock()
        subject = QRCodeScanner(
            deviceInput: deviceInputMock,
            captureSession: captureSession
        )
        subject.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        captureSession = nil
        deviceInputMock = nil
        subject = nil
        super.tearDown()
    }

    // TODO:
    // * Fix these tests
    //    func test_setup() {
    //        let inputAddedExpectaion = expectation(description: "Input added")
    //        let outputAddedExpectaion = expectation(description: "Output added")
    //        let metadataObjectsAddedExpectaion = expectation(description: "metadata objects added")
    //
    //        deviceInputMock = DeviceInputMock()
    //        captureSession = CaptureSessionMock()
    //        captureMetadataOutput = CaptureMetadataOutputMock()
    //        delegate = QRCodeScannerDelegateMock()
    //
    //        XCTAssertEqual(captureSession.inputsAdded.count, 0)
    //        captureSession.addInputCallback = { [unowned self] _ in
    //            XCTAssertEqual(self.captureSession.inputsAdded.count, 1)
    //            inputAddedExpectaion.fulfill()
    //        }
    //
    //        XCTAssertEqual(captureSession.outputsAdded.count, 0)
    //        captureSession.addOutputCallback = { [unowned self] _ in
    //            XCTAssertEqual(self.captureSession.outputsAdded.count, 1)
    //            outputAddedExpectaion.fulfill()
    //        }
    //
    //        XCTAssertEqual(captureMetadataOutput.metadataObjects.count, 0)
    //        captureMetadataOutput.setMetadataObjectsDelegateCalled = { [unowned self] _ in
    //            XCTAssertEqual(self.captureMetadataOutput.metadataObjects.count, 1)
    //            metadataObjectsAddedExpectaion.fulfill()
    //        }
    //
    //        subject = QRCodeScanner(
    //            deviceInput: deviceInputMock,
    //            captureSession: captureSession,
    //            captureMetadataOutputBuilder: { [unowned self] in
    //                self.captureMetadataOutput
    //            }
    //        )
    //        subject.delegate = delegate
    //
    //        waitForExpectations(timeout: 5)
    //    }
    //
    //    func test_startReadingQRCode() {
    //        let startRunningCalled = expectation(description: "startRunning called")
    //        let didStartScanningCalled = expectation(description: "didStartScanning called")
    //
    //        deviceInputMock = DeviceInputMock()
    //        captureSession = CaptureSessionMock()
    //        captureMetadataOutput = CaptureMetadataOutputMock()
    //        delegate = QRCodeScannerDelegateMock()
    //
    //        captureSession.startRunningCallback = {
    //            startRunningCalled.fulfill()
    //        }
    //
    //        captureSession.stopRunningCallback = {
    //            XCTFail("Stop running shouldn't be called")
    //        }
    //
    //        XCTAssertEqual(delegate.didStartScanningCallCount, 0)
    //        XCTAssertEqual(captureSession.startRunningCallCount, 0)
    //
    //        delegate.didStartScanningCalled = { [unowned self] in
    //            XCTAssertEqual(self.delegate.didStartScanningCallCount, 1)
    //            XCTAssertEqual(self.captureSession.startRunningCallCount, 1)
    //
    //            didStartScanningCalled.fulfill()
    //        }
    //
    //        delegate.didStopScanningCalled = {
    //            XCTFail("Stop scanning shouldn't be called")
    //        }
    //
    //        subject = QRCodeScanner(
    //            deviceInput: deviceInputMock,
    //            captureSession: captureSession,
    //            captureMetadataOutputBuilder: { [unowned self] in
    //                self.captureMetadataOutput
    //            }
    //        )
    //        subject.delegate = delegate
    //
    //        subject.startReadingQRCode()
    //
    //        waitForExpectations(timeout: 5)
    //    }
    //
    //    func test_stopReadingQRCode() {
    //        let stopRunningCalled = expectation(description: "stopRunning called")
    //        let didStopScanningCalled = expectation(description: "didStopScanning called")
    //
    //        deviceInputMock = DeviceInputMock()
    //        captureSession = CaptureSessionMock()
    //        captureMetadataOutput = CaptureMetadataOutputMock()
    //        delegate = QRCodeScannerDelegateMock()
    //
    //        captureSession.startRunningCallback = {
    //            XCTFail("Start running shouldn't be called")
    //        }
    //
    //        captureSession.stopRunningCallback = {
    //             stopRunningCalled.fulfill()
    //        }
    //
    //        XCTAssertEqual(delegate.didStopScanningCallCount, 0)
    //        XCTAssertEqual(captureSession.stopRunningCallCount, 0)
    //
    //        delegate.didStartScanningCalled = {
    //            XCTFail("Start scanning shouldn't be called")
    //        }
    //
    //        delegate.didStopScanningCalled = { [unowned self] in
    //            XCTAssertEqual(self.delegate.didStopScanningCallCount, 1)
    //            XCTAssertEqual(self.captureSession.stopRunningCallCount, 1)
    //
    //            didStopScanningCalled.fulfill()
    //        }
    //
    //        subject = QRCodeScanner(
    //            deviceInput: deviceInputMock,
    //            captureSession: captureSession,
    //            captureMetadataOutputBuilder: { [unowned self] in
    //                self.captureMetadataOutput
    //            }
    //        )
    //        subject.delegate = delegate
    //
    //        subject.stopReadingQRCode()
    //
    //        waitForExpectations(timeout: 5)
    //    }
}
