// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformUIKit
import UIKit

/// Welcome screen in KYC flow
final class KYCWelcomeController: KYCBaseViewController {

    // MARK: - IBOutlets

    @IBOutlet private var imageViewMain: UIImageView!
    @IBOutlet private var labelMain: UILabel!
    @IBOutlet private var labelTermsOfService: UILabel!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private let webViewService: WebViewServiceAPI = resolve()

    // MARK: Factory

    override class func make(with coordinator: KYCRouter) -> KYCWelcomeController {
        let controller = makeFromStoryboard(in: .module)
        controller.router = coordinator
        controller.pageType = .welcome
        return controller
    }

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = LocalizationConstants.KYC.welcome
        initMainView()
        initFooter()
    }

    // MARK: - Actions

    @IBAction func onCloseTapped(_ sender: Any) {
        presentingViewController?.dismiss(animated: true)
    }

    @IBAction private func onLabelTapped(_ sender: UITapGestureRecognizer) {
        guard let text = labelTermsOfService.text else {
            return
        }
        if let tosRange = text.range(of: LocalizationConstants.tos),
           sender.didTapAttributedText(in: labelTermsOfService, range: NSRange(tosRange, in: text))
        {
            webViewService.openSafari(url: Constants.Url.termsOfService, from: self)
        }
        if let privacyPolicyRange = text.range(of: LocalizationConstants.privacyPolicy),
           sender.didTapAttributedText(in: labelTermsOfService, range: NSRange(privacyPolicyRange, in: text))
        {
            webViewService.openSafari(url: Constants.Url.privacyPolicy, from: self)
        }
    }

    @IBAction private func primaryButtonTapped(_ sender: Any) {
        router.handle(event: .nextPageFromPageType(pageType, nil))
    }

    // MARK: - Private Methods

    private func initMainView() {
        if router.user?.isSunriverAirdropRegistered == true {
            labelMain.text = LocalizationConstants.KYC.welcomeMainTextSunRiverCampaign
            imageViewMain.image = UIImage(named: "Icon-Verified-Large", in: .featureKYCUI, compatibleWith: nil)
        } else {
            labelMain.text = LocalizationConstants.KYC.welcomeMainText
            imageViewMain.image = UIImage(named: "Welcome", in: .featureKYCUI, compatibleWith: nil)
        }
    }

    private func initFooter() {
        let font = UIFont(
            name: Constants.FontNames.montserratRegular,
            size: Constants.FontSizes.ExtraExtraExtraSmall
        ) ?? UIFont.systemFont(ofSize: Constants.FontSizes.ExtraExtraExtraSmall)
        let labelAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.gray5
        ]
        let labelText = NSMutableAttributedString(
            string: String(
                format: LocalizationConstants.KYC.termsOfServiceAndPrivacyPolicyNotice,
                LocalizationConstants.tos,
                LocalizationConstants.privacyPolicy
            ),
            attributes: labelAttributes
        )
        labelText.addForegroundColor(UIColor.brandSecondary, to: LocalizationConstants.tos)
        labelText.addForegroundColor(UIColor.brandSecondary, to: LocalizationConstants.privacyPolicy)
        labelTermsOfService.attributedText = labelText
    }
}
