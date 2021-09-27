// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

protocol LocationSuggestionInterface: AnyObject {
    func updateActivityIndicator(_ visibility: Visibility)
    func suggestionsList(_ visibility: Visibility)
    func termsOfServiceDisclaimer(_ visibility: Visibility)
    func addressEntryView(_ visibility: Visibility)
    func primaryButtonEnabled(_ enabled: Bool)
    func primaryButton(_ visibility: Visibility)
    func primaryButtonActivityIndicator(_ visibility: Visibility)
    func populateAddressEntryView(_ address: PostalAddress)
    func searchFieldActive(_ isFirstResponder: Bool)
    func searchFieldText(_ value: String?)
    func didReceiveError(_ error: Error)
}
