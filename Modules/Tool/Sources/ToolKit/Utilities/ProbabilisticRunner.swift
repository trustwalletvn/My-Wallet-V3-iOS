// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// Run a specified block probabilistically with an assigned probability
public enum ProbabilisticRunner {

    /// The percentage used for the run expressed in `Basis Points` (`1/10000`)
    public struct BasisPoints {

        enum BasisPointError: Error {
            case invalidInput
        }

        // swiftlint:disable force_try
        public static let pointZeroOnePercent = try! BasisPoints(basisPoints: 1)
        public static let pointOnePercent = try! BasisPoints(basisPoints: 10)
        public static let onePercent = try! BasisPoints(basisPoints: 100)
        public static let fivePercent = try! BasisPoints(basisPoints: 500)
        public static let tenPercent = try! BasisPoints(basisPoints: 1000)
        public static let twentyPercent = try! BasisPoints(basisPoints: 2000)
        public static let fiftyPercent = try! BasisPoints(basisPoints: 5000)

        fileprivate static let min = 0
        fileprivate static let max = 10000

        fileprivate let basisPoints: Int

        fileprivate init(basisPoints: Int) throws {
            guard basisPoints >= Self.min, basisPoints <= Self.max else {
                throw BasisPointError.invalidInput
            }
            self.basisPoints = basisPoints
        }
    }

    /// Run the specified `block` probabilistically for a specified fraction of runs
    /// - Parameters:
    ///   - basisPoints: The probability to use, expressed in `Basis Points` (`1/10000`)
    ///   - block: The block to run
    public static func run(for basisPoints: BasisPoints, block: () -> Void) {
        if shouldRun(for: basisPoints) {
            block()
        }
    }

    private static func shouldRun(for basisPoints: BasisPoints) -> Bool {
        let number = Int.random(in: BasisPoints.min...BasisPoints.max)
        return number <= basisPoints.basisPoints
    }
}
