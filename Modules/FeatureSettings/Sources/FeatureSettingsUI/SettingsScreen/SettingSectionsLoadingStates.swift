// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// This construct provides access to aggregated fiat-crypto-pair calculation states.
/// Any supported asset balance should be accessible here.
struct SettingSectionsLoadingStates {

    // MARK: - Properties

    /// Returns `FiatCryptoPairCalculationState` for a given `CryptoCurrency`
    subscript(sectionType: SettingsSectionType) -> SettingsSectionLoadingState {
        statePerSection[sectionType]!
    }

    /// Returns all the states
    var all: [SettingsSectionLoadingState] {
        Array(statePerSection.values)
    }

    /// All elements must be `.calculating` for that to return `true`
    var isCalculating: Bool {
        !all.contains { !$0.isLoading }
    }

    // MARK: - Private Properties

    private var statePerSection: [SettingsSectionType: SettingsSectionLoadingState] = [:]

    // MARK: - Setup

    init(statePerSection: [SettingsSectionType: SettingsSectionLoadingState]) {
        self.statePerSection = statePerSection
    }
}
