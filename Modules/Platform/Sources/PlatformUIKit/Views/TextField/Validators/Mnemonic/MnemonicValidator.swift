// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain
import PlatformKit
import RxRelay
import RxSwift

/// Validates the users mnemonic or passphrase entry
final class MnemonicValidator: MnemonicValidating {

    // MARK: - TextValidating Properties

    let valueRelay = BehaviorRelay<String>(value: "")

    var validationState: Observable<TextValidationState> {
        isValidRelay.map { $0 ? .valid : .invalid(reason: nil) }
    }

    // MARK: - MnemonicValidating Properties

    var score: Observable<MnemonicValidationScore> {
        scoreRelay.asObservable()
    }

    // MARK: - Private Properties

    private let scoreRelay = BehaviorRelay<MnemonicValidationScore>(value: .none)
    private let isValidRelay = BehaviorRelay<Bool>(value: false)
    private let words: Set<String>
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(words: Set<String>, mnemonicLength: Int = 12) {
        self.words = words

        valueRelay
            .map(weak: self) { _, phrase -> MnemonicValidationScore in
                if phrase.isEmpty {
                    return .none
                }

                /// Make an array of the individual words
                let components = phrase
                    .components(separatedBy: .whitespacesAndNewlines)
                    .filter { !$0.isEmpty }

                if components.count < mnemonicLength {
                    return .incomplete
                } else if components.count > mnemonicLength {
                    return .excess
                }

                /// Separate out the words that are duplicates
                let duplicates = Set(components.duplicates ?? [])

                /// The total number of duplicates entered
                let duplicatesCount = duplicates
                    .map { duplicate in
                        components.filter { $0 == duplicate }.count
                    }
                    .reduce(0, +)

                /// Make a set for all the individual entries
                let set = Set(phrase.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty && !duplicates.contains($0) })

                guard !set.isEmpty || duplicatesCount > 0 else {
                    return .none
                }

                /// Are all the words entered thus far valid words
                let entriesAreValid = set.isSubset(of: words) && duplicates.isSubset(of: words)
                if entriesAreValid {
                    return .valid
                }

                /// Combine the `set` and `duplicates` to form a `Set<String>` of all
                /// words that are not included in the `WordList`
                let difference = set.union(duplicates).subtracting(words)

                /// Find the `NSRange` value for each word or incomplete word that is not
                /// included in the `WordList`
                let ranges = difference.map { delta -> [NSRange] in
                    phrase.ranges(of: delta)
                }
                .flatMap { $0 }

                return .invalid(ranges)
            }
            .catchErrorJustReturn(.none)
            .bindAndCatch(to: scoreRelay)
            .disposed(by: disposeBag)

        scoreRelay
            .map(\.isValid)
            .bindAndCatch(to: isValidRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: Convenience

extension String {
    /// A convenience function for getting an array of `NSRange` values
    /// for a particular substring.
    fileprivate func ranges(of substring: String) -> [NSRange] {
        var ranges: [Range<Index>] = []
        enumerateSubstrings(in: startIndex..<endIndex, options: .byWords) { word, value, _, _ in
            if let word = word, word == substring {
                ranges.append(value)
            }
        }
        return ranges.map { NSRange($0, in: self) }
    }
}
