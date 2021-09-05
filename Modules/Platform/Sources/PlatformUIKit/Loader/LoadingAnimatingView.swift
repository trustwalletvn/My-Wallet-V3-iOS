// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

public final class LoadingAnimatingView: LoadingCircleView {

    // MARK: - Static Properties

    private static let strokeEndKeyPath: String = "strokeEnd"
    private static let transformRotationKeyPath: String = "transform.rotation"

    // MARK: - Types

    private struct Descriptor {

        /// Describes the start time in relation to the previous start time.
        let startTime: CFTimeInterval

        /// Describes the start angle ratio to a full circle
        let startAngle: CGFloat

        /// Describes the length of the circumference
        let length: CGFloat

        init(startTime: CFTimeInterval, startAngle: CGFloat, length: CGFloat) {
            self.startTime = startTime
            self.startAngle = startAngle
            self.length = length
        }
    }

    private struct Summary {
        var times: [CFTimeInterval] = []
        var angles: [CGFloat] = []
        var lengths: [CGFloat] = []
    }

    // MARK: - Properties

    /// Represents the changes in times, start & end positions of stroke
    private let descriptors = [
        Descriptor(startTime: 0, startAngle: 0, length: 0),
        Descriptor(startTime: 0.15, startAngle: 0, length: 0.15),
        Descriptor(startTime: 0.3, startAngle: 0, length: 0.25),
        Descriptor(startTime: 0.5, startAngle: 0, length: 0.5),
        Descriptor(startTime: 0.3, startAngle: 0.25, length: 0.7),
        Descriptor(startTime: 0.2, startAngle: 0.5, length: 0.5),
        Descriptor(startTime: 0.2, startAngle: 0.7, length: 0.3),
        Descriptor(startTime: 0.2, startAngle: 0.9, length: 0.1),
        Descriptor(startTime: 0.1, startAngle: 0.95, length: 0.05),
        Descriptor(startTime: 0, startAngle: 1, length: 0)
    ]

    // MARK: - Setup

    override public init(diameter: CGFloat, strokeColor: UIColor, strokeBackgroundColor: UIColor, fillColor: UIColor, strokeWidth: CGFloat = 8) {
        super.init(
            diameter: diameter,
            strokeColor: strokeColor,
            strokeBackgroundColor: strokeBackgroundColor,
            fillColor: fillColor,
            strokeWidth: strokeWidth
        )
        accessibility = .id(Accessibility.Identifier.LoadingView.loadingView)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Starts the animation
    public func animate() {

        // Calculate the total time of the animation
        let totalTime = descriptors
            .map(\.startTime)
            .reduce(0, +)

        let fullAngle: CGFloat = 2 * .pi

        var time: CFTimeInterval = 0
        var summary = descriptors
            .reduce(into: Summary()) { result, current in
                time += current.startTime
                result.times.append(time / totalTime)
                result.angles.append(current.startAngle * fullAngle)
                result.lengths.append(current.length)
            }

        summary.times.append(summary.times[0])
        summary.angles.append(summary.angles[0])
        summary.lengths.append(summary.lengths[0])

        // Animate length
        animateKeyPath(
            keyPath: LoadingAnimatingView.strokeEndKeyPath,
            duration: totalTime,
            times: summary.times,
            values: summary.lengths
        )

        // Animate rotation
        animateKeyPath(
            keyPath: LoadingAnimatingView.transformRotationKeyPath,
            duration: totalTime,
            times: summary.times,
            values: summary.angles
        )
    }

    public func stop() {
        layer.removeAnimation(forKey: LoadingAnimatingView.strokeEndKeyPath)
        layer.removeAnimation(forKey: LoadingAnimatingView.transformRotationKeyPath)
    }

    private func animateKeyPath(
        keyPath: String,
        duration: CFTimeInterval,
        times: [CFTimeInterval],
        values: [CGFloat]
    ) {
        let animation = CAKeyframeAnimation(keyPath: keyPath)
        animation.keyTimes = times as [NSNumber]
        animation.values = values
        animation.calculationMode = .cubic
        animation.duration = duration
        animation.repeatCount = .infinity
        layer.add(animation, forKey: keyPath)
    }
}
