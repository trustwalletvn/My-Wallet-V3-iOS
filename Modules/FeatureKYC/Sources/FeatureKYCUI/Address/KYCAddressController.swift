// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureKYCDomain
import Localization
import PlatformKit
import PlatformUIKit
import ToolKit
import UIKit

class KYCAddressController: KYCBaseViewController, ValidationFormView, ProgressableView {

    // MARK: ProgressableView

    var barColor: UIColor = .green
    var startingValue: Float = 0.6
    @IBOutlet var progressView: UIProgressView!

    // MARK: - Private IBOutlets

    @IBOutlet fileprivate var searchBar: UISearchBar!
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var activityIndicator: UIActivityIndicatorView!
    @IBOutlet fileprivate var labelFooter: UILabel!
    @IBOutlet fileprivate var requiredLabel: UILabel!

    // MARK: Private IBOutlets (ValidationTextField)

    @IBOutlet fileprivate var addressTextField: ValidationTextField!
    @IBOutlet fileprivate var apartmentTextField: ValidationTextField!
    @IBOutlet fileprivate var cityTextField: ValidationTextField!
    @IBOutlet fileprivate var stateTextField: ValidationPickerField!
    @IBOutlet fileprivate var regionTextField: ValidationTextField!
    @IBOutlet fileprivate var postalCodeTextField: ValidationTextField!
    @IBOutlet fileprivate var primaryButtonContainer: PrimaryButtonContainer!

    private let webViewService: WebViewServiceAPI = resolve()
    private let analyticsRecorder: AnalyticsEventRecorderAPI = resolve()

    // MARK: - Public IBOutlets

    @IBOutlet var scrollView: UIScrollView!

    // MARK: Factory

    override class func make(with coordinator: KYCRouter) -> KYCAddressController {
        let controller = makeFromStoryboard(in: .module)
        controller.router = coordinator
        controller.pageType = .address
        return controller
    }

    // MARK: - KYCOnboardingNavigation

    weak var searchDelegate: SearchControllerDelegate?

    /// `validationFields` are all the fields listed below in a collection.
    /// This is just for convenience purposes when iterating over the fields
    /// and checking validation etc.
    var validationFields: [ValidationTextField] {
        [
            addressTextField,
            apartmentTextField,
            cityTextField,
            stateTextField,
            regionTextField,
            postalCodeTextField
        ]
    }

    var keyboard: KeyboardObserver.Payload?

    // MARK: Private Properties

    fileprivate var locationCoordinator: LocationSuggestionCoordinator!
    fileprivate var dataProvider: LocationDataProvider!
    private var user: NabuUser?
    private var country: CountryData?
    private var states: [KYCState] = []

    // MARK: KYCRouterDelegate

    override func apply(model: KYCPageModel) {
        guard case .address(let user, let country, let states) = model else { return }
        self.user = user
        self.country = country
        self.states = states
        if let country = self.country {
            stateTextField.options = states
                .map { ValidationPickerField.PickerItem($0) }
                .sorted(by: { $0.title < $1.title })
            updateStateAndRegionFieldsVisibility()
            validationFieldsPlaceholderSetup(country.code)
        }

        // NOTE: address is not prefilled. Bug?
        guard let address = user.address else { return }
        addressTextField.text = address.lineOne
        apartmentTextField.text = address.lineTwo
        postalCodeTextField.text = address.postalCode
        cityTextField.text = address.city
        stateTextField.text = address.state
        regionTextField.text = address.state
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        locationCoordinator = LocationSuggestionCoordinator(self, interface: self)
        dataProvider = LocationDataProvider(with: tableView)
        searchBar.searchTextField.accessibilityIdentifier = "kyc.address.search_bar"
        searchBar.delegate = self
        tableView.delegate = self
        scrollView.alwaysBounceVertical = true

        searchBar.barTintColor = .clear
        searchBar.placeholder = LocalizationConstants.KYC.yourHomeAddress

        progressView.tintColor = .green
        requiredLabel.text = LocalizationConstants.KYC.required + "*"

        addressTextField.accessibilityIdentifier = "kyc.address.street_field"
        apartmentTextField.accessibilityIdentifier = "kyc.address.apartment_field"
        cityTextField.accessibilityIdentifier = "kyc.address.city_field"
        stateTextField.accessibilityIdentifier = "kyc.address.state_field"
        regionTextField.accessibilityIdentifier = "kyc.address.country_field"
        postalCodeTextField.accessibilityIdentifier = "kyc.address.postcode_field"

        initFooter()
        validationFieldsSetup()
        setupNotifications()

        primaryButtonContainer.title = LocalizationConstants.KYC.submit
        primaryButtonContainer.actionBlock = { [weak self] in
            guard let self = self else { return }
            self.primaryButtonTapped()
        }

        setupProgressView()
        setupKeyboard()
    }

    private func setupKeyboard() {
        let bar = UIToolbar()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        bar.items = [flexibleSpace, doneButton]
        bar.sizeToFit()

        validationFields.forEach { $0.accessoryView = bar }
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: IBActions

    @IBAction func onFooterTapped(_ sender: UITapGestureRecognizer) {
        guard let text = labelFooter.text else {
            return
        }
        if let tosRange = text.range(of: LocalizationConstants.tos),
           sender.didTapAttributedText(in: labelFooter, range: NSRange(tosRange, in: text))
        {
            webViewService.openSafari(url: Constants.Url.termsOfService, from: self)
        }
        if let privacyPolicyRange = text.range(of: LocalizationConstants.privacyPolicy),
           sender.didTapAttributedText(in: labelFooter, range: NSRange(privacyPolicyRange, in: text))
        {
            webViewService.openSafari(url: Constants.Url.privacyPolicy, from: self)
        }
    }

    // MARK: Private Functions

    private func initFooter() {
        // TICKET: IOS-1436
        // Tap target is a bit off here. Refactor ActionableLabel to take in 2 CTAs
        let font = Font(.branded(.montserratRegular), size: .custom(15.0)).result
        let labelAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.gray5
        ]
        let labelText = NSMutableAttributedString(
            string: String(
                format: LocalizationConstants.KYC.termsOfServiceAndPrivacyPolicyNoticeAddress,
                LocalizationConstants.tos,
                LocalizationConstants.privacyPolicy
            ),
            attributes: labelAttributes
        )
        labelText.addForegroundColor(UIColor.brandSecondary, to: LocalizationConstants.tos)
        labelText.addForegroundColor(UIColor.brandSecondary, to: LocalizationConstants.privacyPolicy)
        labelFooter.attributedText = labelText
    }

    fileprivate func validationFieldsSetup() {

        /// Given that this is a form, we want all the fields
        /// except for the last one to prompt the user to
        /// continue to the next field.
        /// We also set the contentType that the field is expecting.
        addressTextField.returnKeyType = .next
        addressTextField.contentType = .streetAddressLine1

        apartmentTextField.returnKeyType = .next
        apartmentTextField.contentType = .streetAddressLine2

        cityTextField.returnKeyType = .next
        cityTextField.contentType = .addressCity

        stateTextField.returnKeyType = .next
        stateTextField.contentType = .addressState

        regionTextField.returnKeyType = .next
        regionTextField.contentType = .addressState

        postalCodeTextField.returnKeyType = .done
        postalCodeTextField.contentType = .postalCode

        validationFields.enumerated().forEach { index, field in
            field.returnTappedBlock = { [weak self] in
                guard let this = self else { return }
                guard this.validationFields.count > index + 1 else {
                    field.resignFocus()
                    return
                }
                let next = this.validationFields[index + 1]
                next.becomeFocused()
            }
        }

        handleKeyboardOffset()
    }

    fileprivate func validationFieldsPlaceholderSetup(_ countryCode: String) {
        if countryCode.lowercased() == "us" {
            addressTextField.placeholder = LocalizationConstants.KYC.streetLine + " 1"
            addressTextField.optionalField = false

            apartmentTextField.placeholder = LocalizationConstants.KYC.streetLine + " 2"
            apartmentTextField.optionalField = true

            cityTextField.placeholder = LocalizationConstants.KYC.city
            cityTextField.optionalField = false

            stateTextField.placeholder = LocalizationConstants.KYC.state
            stateTextField.optionalField = false
            regionTextField.optionalField = true

            postalCodeTextField.placeholder = LocalizationConstants.KYC.zipCode
            postalCodeTextField.optionalField = false
        } else {
            addressTextField.placeholder = LocalizationConstants.KYC.addressLine + " 1"
            addressTextField.optionalField = false

            apartmentTextField.placeholder = LocalizationConstants.KYC.addressLine + " 2"
            apartmentTextField.optionalField = true

            cityTextField.placeholder = LocalizationConstants.KYC.cityTownVillage
            cityTextField.optionalField = false

            regionTextField.placeholder = LocalizationConstants.KYC.stateRegionProvinceCountry
            regionTextField.optionalField = false
            stateTextField.optionalField = true

            postalCodeTextField.placeholder = LocalizationConstants.KYC.postalCode
            postalCodeTextField.optionalField = true
        }

        validationFields.forEach { field in
            if field.optionalField == false {
                field.placeholder += "*"
            }
        }
    }

    fileprivate func setupNotifications() {
        NotificationCenter.when(UIResponder.keyboardWillHideNotification) { [weak self] _ in
            self?.scrollView.contentInset = .zero
            self?.scrollView.setContentOffset(.zero, animated: true)
        }
    }

    fileprivate func primaryButtonTapped() {
        guard checkFieldsValidity() else { return }

        analyticsRecorder.record(event: AnalyticsEvents.KYC.kycAddressDetailSet)

        validationFields.forEach { $0.resignFocus() }

        let address = UserAddress(
            lineOne: addressTextField.text ?? "",
            lineTwo: apartmentTextField.text ?? "",
            postalCode: postalCodeTextField.text ?? "",
            city: cityTextField.text ?? "",
            state: stateTextField.selectedOption?.id ?? regionTextField.text ?? "",
            countryCode: country?.code ?? user?.address?.countryCode ?? ""
        )
        searchDelegate?.onSubmission(address, completion: { [weak self] in
            guard let this = self else { return }
            this.router.handle(event: .nextPageFromPageType(this.pageType, nil))
        })
    }
}

extension KYCAddressController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selection = dataProvider.locationResult.suggestions[indexPath.row]
        locationCoordinator.onSelection(selection)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard searchBar.isFirstResponder else { return }
        searchBar.resignFirstResponder()
        searchDelegate?.onSearchResigned()
    }
}

extension KYCAddressController: LocationSuggestionInterface {
    func termsOfServiceDisclaimer(_ visibility: Visibility) {
        labelFooter.alpha = visibility.defaultAlpha
    }

    func primaryButtonActivityIndicator(_ visibility: Visibility) {
        primaryButtonContainer.isLoading = visibility == .visible
    }

    func primaryButtonEnabled(_ enabled: Bool) {
        primaryButtonContainer.isEnabled = enabled
    }

    func addressEntryView(_ visibility: Visibility) {
        scrollView.alpha = visibility.defaultAlpha
    }

    func populateAddressEntryView(_ address: PostalAddress) {
        if let number = address.streetNumber, let street = address.street {
            addressTextField.text = "\(number) \(street)"
        }
        cityTextField.text = address.city
        // NOTE: This fixes a bug when the user selects a non-US country but then searches for an address within the US.
        // Ideally, we should reload the states, but since we're going to rewrite this module, I'm just patching it for now.
        if address.countryCode?.lowercased() == "us" {
            stateTextField.options = UnitedStates.states
                .map(ValidationPickerField.PickerItem.init)
                .sorted(by: { $0.title < $1.title })
        } else {
            stateTextField.options = []
        }
        updateStateAndRegionFieldsVisibility()
        if let state = address.state, !stateTextField.options.isEmpty {
            stateTextField.selectedOption = stateTextField.options.first(where: { option in
                if option.id == state || option.title == state {
                    return true
                }
                return String(describing: option.id)
                    .split(separator: "-")
                    .map(String.init)
                    .contains(state)
            })
        }
        regionTextField.text = address.state
        postalCodeTextField.text = address.postalCode
    }

    func updateActivityIndicator(_ visibility: Visibility) {
        visibility == .hidden ? activityIndicator.stopAnimating() : activityIndicator.startAnimating()
    }

    func suggestionsList(_ visibility: Visibility) {
        tableView.alpha = visibility.defaultAlpha
    }

    func primaryButton(_ visibility: Visibility) {
        primaryButtonContainer.alpha = visibility.defaultAlpha
    }

    func searchFieldActive(_ isFirstResponder: Bool) {
        switch isFirstResponder {
        case true:
            searchBar.becomeFirstResponder()
        case false:
            searchBar.resignFirstResponder()
        }
    }

    func searchFieldText(_ value: String?) {
        searchBar.text = value
    }

    private func updateStateAndRegionFieldsVisibility() {
        let countryHasStates = !stateTextField.options.isEmpty
        stateTextField.isHidden = !countryHasStates
        stateTextField.selectedOption = nil
        regionTextField.isHidden = countryHasStates
        regionTextField.text = regionTextField.isHidden ? nil : regionTextField.text
    }

    func didReceiveError(_ error: Error) {
        let alert = UIAlertController(
            title: LocalizationConstants.Errors.error,
            message: LocalizationConstants.KYC.Errors.genericErrorMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: LocalizationConstants.okString, style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension KYCAddressController: LocationSuggestionCoordinatorDelegate {
    func coordinator(_ locationCoordinator: LocationSuggestionCoordinator, generated address: PostalAddress) {
        // TODO: May not be needed depending on how we pass along the `PostalAddress`
    }

    func coordinator(_ locationCoordinator: LocationSuggestionCoordinator, updated model: LocationSearchResult) {
        dataProvider.locationResult = model
    }
}

extension KYCAddressController: UISearchBarDelegate {

    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }

    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchDelegate?.onStart()
        scrollView.setContentOffset(.zero, animated: true)
    }

    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let value = searchBar.text as NSString? {
            let current = value.replacingCharacters(in: range, with: text)
            searchDelegate?.onSearchRequest(current)
        }
        return true
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let value = searchBar.text {
            searchDelegate?.onSearchRequest(value)
        }
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchDelegate?.onSearchViewCancel()
        searchBar.text = nil
    }
}

extension KYCAddressController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        validationFields.forEach { $0.resignFocus() }
    }
}
