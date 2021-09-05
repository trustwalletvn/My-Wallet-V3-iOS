// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

final class QRCodeScannerViewOverlay: UIView {

    /// The area that the QR code must be within.
    var scannableFrame: CGRect {
        // We want a 280x280 square.
        let halfAxis: CGFloat = 140
        // We have the target coordinate space bounds.
        let targetBounds = targetCoordinateSpace.bounds
        // We create a rect representing a 280x280 square in the middle of target.
        let targetSquare = CGRect(
            x: targetBounds.midX - halfAxis,
            y: targetBounds.midY - halfAxis,
            width: 2 * halfAxis,
            height: 2 * halfAxis
        )
        // We convert the rect from the target coordinate space into ours.
        return convert(targetSquare, from: targetCoordinateSpace)
    }

    private let viewModel: QRCodeScannerOverlayViewModel
    private let scanningViewFinder = UIView()
    private let flashButton = UIButton()
    private let cameraRollButton = UIButton()
    private let subtitleLabel = UILabel()
    private let disposeBag = DisposeBag()
    private let scanningBorder = CAShapeLayer()
    private let targetCoordinateSpace: UICoordinateSpace

    init(viewModel: QRCodeScannerOverlayViewModel, targetCoordinateSpace: UICoordinateSpace) {
        self.viewModel = viewModel
        self.targetCoordinateSpace = targetCoordinateSpace
        super.init(frame: .zero)
        setupSubviews()

        viewModel.scanSuccess
            .subscribe(onNext: { [weak self] isSuccess in
                self?.setScanningBorder(color: isSuccess ? .successBorder : .white)
            })
            .disposed(by: disposeBag)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setScanningBorder(color: UIColor) {
        UIView.animate(withDuration: 0.3) {
            self.scanningBorder.strokeColor = color.cgColor
        }
    }

    private func setupSubviews() {
        backgroundColor = UIColor.primary.withAlphaComponent(0.9)
        setupButtons()
        setupLabels()
        setupBorderView()
    }

    private func setupLabels() {
        addSubview(subtitleLabel)
        subtitleLabel.layoutToSuperview(.leading, offset: 24)
        subtitleLabel.layoutToSuperview(.trailing, offset: -24)
        subtitleLabel.layoutToSuperview(.top, offset: 16)
        subtitleLabel.numberOfLines = 0
        viewModel.subtitleLabelContent
            .drive(subtitleLabel.rx.content)
            .disposed(by: disposeBag)
    }

    private func setupButtons() {
        addSubview(flashButton)
        addSubview(cameraRollButton)
        cameraRollButton.layout(size: .edge(44))
        cameraRollButton.layoutToSuperview(.trailing, offset: -44)
        cameraRollButton.layoutToSuperview(.bottom, offset: -64)

        flashButton.layout(size: .edge(44))
        flashButton.layoutToSuperview(.leading, offset: 44)
        flashButton.layoutToSuperview(.bottom, offset: -64)

        viewModel
            .cameraRollButtonVisibility
            .map(\.isHidden)
            .drive(cameraRollButton.rx.isHidden)
            .disposed(by: disposeBag)

        cameraRollButton.rx.tap
            .throttle(
                .milliseconds(200),
                latest: false,
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .observeOn(MainScheduler.instance)
            .bindAndCatch(to: viewModel.cameraTapRelay)
            .disposed(by: disposeBag)

        viewModel
            .flashEnabled
            .drive(flashButton.rx.isSelected)
            .disposed(by: disposeBag)

        flashButton.rx.tap
            .throttle(
                .milliseconds(200),
                latest: false,
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
            .observeOn(MainScheduler.instance)
            .bindAndCatch(to: viewModel.flashTapRelay)
            .disposed(by: disposeBag)

        cameraRollButton.setImage(UIImage(named: "camera-roll-button"), for: .normal)

        flashButton.setImage(UIImage(named: "flash-button"), for: .normal)
        flashButton.setImage(UIImage(named: "flash-enabled-button"), for: .selected)
        flashButton.setImage(UIImage(named: "flash-enabled-button"), for: .highlighted)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let scannableFrame = self.scannableFrame
        setupLayerMask(frame: scannableFrame)
        updateScanningBorder(frame: scannableFrame)
    }

    /// Sets up layers mask given the frame provided.
    private func setupLayerMask(frame: CGRect) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        let path = UIBezierPath(rect: bounds)
        path.append(
            .init(
                roundedRect: scannableFrame,
                byRoundingCorners: .allCorners,
                cornerRadii: .edge(8)
            )
        )
        maskLayer.fillRule = .evenOdd
        maskLayer.path = path.cgPath
        layer.mask = maskLayer
    }

    /// Updates `scanningBorder` path to the given frame.
    private func updateScanningBorder(frame: CGRect) {
        scanningBorder.path = UIBezierPath(
            roundedRect: frame,
            cornerRadius: 8
        ).cgPath
    }

    /// Sets up `scanningBorder`, adding it to this view's layer.
    /// Should only be called once.
    private func setupBorderView() {
        scanningBorder.strokeColor = UIColor.white.cgColor
        scanningBorder.lineWidth = 8.0
        layer.addSublayer(scanningBorder)
    }
}
