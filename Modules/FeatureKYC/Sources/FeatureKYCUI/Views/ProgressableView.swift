// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

protocol ProgressableView {
    var progressView: UIProgressView! { get }
    var barColor: UIColor { get set }
    var startingValue: Float { get set }

    func setupProgressView()
    func updateProgress(_ progress: Float)
}

extension ProgressableView {
    func setupProgressView() {
        progressView.progressTintColor = barColor
        progressView.setProgress(startingValue, animated: true)
    }

    func updateProgress(_ progress: Float) {
        progressView.setProgress(progress, animated: true)
    }
}
