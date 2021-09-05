// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class LuhnNumberValidator {

    private let decimalDigits = CharacterSet.decimalDigits

    public func validate(number: String) -> Bool {
        guard !(number.contains { !decimalDigits.contains($0) }) else {
            return false
        }

        let sum = number
            .map { Int(String($0))! }
            .reversed()
            .enumerated()
            .map { (index: $0.offset, digit: $0.element) }
            .reduce(0) { result, element in
                let isOdd = element.index % 2 == 1
                switch (isOdd, element.digit) {
                case (true, 9):
                    return result + 9
                case (true, 0...8):
                    return result + (element.digit * 2) % 9
                default:
                    return result + element.digit
                }
            }
        return sum % 10 == 0
    }
}
