// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureKYCDomain
import PhoneNumberKit
import PlatformKit
import PlatformUIKit
import ToolKit

final class KYCEnterPhoneNumberController: KYCBaseViewController, BottomButtonContainerView, ProgressableView {

    // MARK: ProgressableView

    var barColor: UIColor = .green
    var startingValue: Float = 0.7
    @IBOutlet var progressView: UIProgressView!

    // MARK: Properties

    private var user: NabuUser?

    // MARK: BottomButtonContainerView

    var originalBottomButtonConstraint: CGFloat!
    var optionalOffset: CGFloat = 0
    @IBOutlet var layoutConstraintBottomButton: NSLayoutConstraint!

    // MARK: IBOutlets

    @IBOutlet private var validationTextFieldMobileNumber: ValidationTextField!
    @IBOutlet private var primaryButton: PrimaryButtonContainer!

    // MARK: Private Properties

    private lazy var presenter: KYCVerifyPhoneNumberPresenter = { [unowned self] in
        KYCVerifyPhoneNumberPresenter(view: self)
    }()

    private lazy var phoneNumberPartialFormatter: PartialFormatter = {
        PartialFormatter()
    }()

    // MARK: Factory

    override class func make(with coordinator: KYCRouter) -> KYCEnterPhoneNumberController {
        let controller = makeFromStoryboard(in: .module)
        controller.router = coordinator
        controller.pageType = .enterPhone
        return controller
    }

    // MARK: - KYCRouterDelegate

    override func apply(model: KYCPageModel) {
        guard case .phone(let user) = model else { return }
        self.user = user

        guard let mobile = user.mobile else { return }
        validationTextFieldMobileNumber.text = mobile.phone
    }

    // MARK: - UIViewController Lifecycle Methods

    deinit {
        cleanUp()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        validationTextFieldMobileNumber.keyboardType = .numberPad
        validationTextFieldMobileNumber.contentType = .telephoneNumber
        validationTextFieldMobileNumber.textReplacementBlock = { [unowned self] in
            self.phoneNumberPartialFormatter.formatPartial($0)
        }
        validationTextFieldMobileNumber.returnTappedBlock = { [unowned self] in
            self.validationTextFieldMobileNumber.resignFocus()
        }
        primaryButton.actionBlock = { [unowned self] in
            self.primaryButtonTapped()
        }
        originalBottomButtonConstraint = layoutConstraintBottomButton.constant
        setupProgressView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpBottomButtonContainerView()
        validationTextFieldMobileNumber.becomeFocused()
    }

    // MARK: - Actions

    private func primaryButtonTapped() {
        guard case .valid = validationTextFieldMobileNumber.validate() else {
            validationTextFieldMobileNumber.becomeFocused()
            Logger.shared.warning("phone number field is invalid.")
            return
        }
        guard let number = validationTextFieldMobileNumber.text else {
            Logger.shared.warning("number is nil.")
            return
        }
        presenter.startVerification(number: number)
    }
}

extension KYCEnterPhoneNumberController: KYCVerifyPhoneNumberView {
    func showError(message: String) {
        AlertViewPresenter.shared.standardError(message: message, in: self)
    }

    func showLoadingView(with text: String) {
        primaryButton.isLoading = true
    }

    func startVerificationSuccess() {
        guard let number = validationTextFieldMobileNumber.text else {
            Logger.shared.warning("number is nil.")
            return
        }
        Logger.shared.info("Show verification view!")
        let payload = KYCPagePayload.phoneNumberUpdated(phoneNumber: number)
        router.handle(event: .nextPageFromPageType(pageType, payload))
    }

    func hideLoadingView() {
        primaryButton.isLoading = false
    }
}
