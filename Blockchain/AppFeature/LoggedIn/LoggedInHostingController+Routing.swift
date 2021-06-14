// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DashboardUIKit
import DIKit
import PlatformKit
import PlatformUIKit
import SettingsUIKit
import ToolKit

// Provides necessary methods for several protocols and tab swapping
// most, if not all, is copied over from `AppCoordinator`
extension LoggedInHostingController {
    func handleAirdrops() {
        airdropRouter.presentAirdropCenterScreen()
    }

    func handleSecureChannel() {
        struct SecureChannelQRCodeTextViewModel: QRCodeScannerTextViewModel {
            private typealias LocalizedString = LocalizationConstants.SecureChannel.QRCode
            let headerText: String = LocalizedString.header
            let subtitleText: String? = LocalizedString.subtitle
        }

        let parser = SecureChannelQRCodeParser()
        let textViewModel = SecureChannelQRCodeTextViewModel()
        let builder = QRCodeScannerViewControllerBuilder(
            parser: parser,
            textViewModel: textViewModel,
            completed: { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let string):
                    self.secureChannelRouter.didScanPairingQRCode(msg: string)
                case .failure(let error):
                    Logger.shared.debug(error.localizedDescription)
                    AlertViewPresenter.shared.standardError(message: error.localizedDescription)
                }
            }
        )
        guard let viewController = builder.build() else {
            // No camera access, an alert will be displayed automatically.
            return
        }
        UIApplication.shared.topMostViewController?.present(
            viewController,
            animated: true
        )
    }

    func startBackupFlow() {
        let router: DashboardUIKit.BackupRouterAPI = resolve()
        backupRouter = router
        router.start()
    }

    func createAccountsAndAddressesViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "AccountsAndAddresses", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "AccountsAndAddressesNavigationController"
        ) as! AccountsAndAddressesNavigationController
        viewController.modalPresentationStyle = .fullScreen
        viewController.modalTransitionStyle = .coverVertical
        self.accountsAndAddressesNavigationController = viewController
        return viewController
    }

    func handleAccountsAndAddresses() {
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            createAccountsAndAddressesViewController(),
            animated: true
        )
    }

    func handleSettings() {
        showSettingsView()
    }

    func handleExchange() {
        guard let tabViewController = tabControllerManager?.tabViewController else { return }
        ExchangeCoordinator.shared.start(from: tabViewController)
    }

    func handleWebLogin() {
        let presenter = WebLoginScreenPresenter()
        let viewController = WebLoginScreenViewController(presenter: presenter)
        let navigationController = UINavigationController(rootViewController: viewController)
        UIApplication.shared.topMostViewController?.present(
            navigationController,
            animated: true
        )
    }

    func handleSupport() {
        let title = String(format: LocalizationConstants.openArg, Constants.Url.blockchainSupport)
        let alert = UIAlertController(
            title: title,
            message: LocalizationConstants.youWillBeLeavingTheApp,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.continueString, style: .default) { _ in
                guard let url = URL(string: Constants.Url.blockchainSupport) else { return }
                UIApplication.shared.open(url)
            }
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        )
        self.topMostViewController?.present(
            alert,
            animated: true
        )
    }

    func handleLogout() {
        let alert = UIAlertController(
            title: LocalizationConstants.SideMenu.logout,
            message: LocalizationConstants.SideMenu.logoutConfirm,
            preferredStyle: .alert
        )
        alert.addAction(
            UIAlertAction(title: LocalizationConstants.okString, style: .default) { [weak self] _ in
                self?.viewStore.send(.logout)
            }
        )
        alert.addAction(UIAlertAction(title: LocalizationConstants.cancel, style: .cancel))
        UIApplication.shared.keyWindow?.rootViewController?.topMostViewController?.present(
            alert,
            animated: true
        )
    }

    func clearOnLogout() {
        unimplemented()
//        tabControllerManager = nil
//        slidingViewController = nil
//        sideMenuViewController = nil
    }

    /// Starts Buy Crypto flow.
    func handleBuyCrypto(currency: CryptoCurrency = .bitcoin) {
        let builder = PlatformUIKit.Builder(
            stateService: PlatformUIKit.StateService()
        )
        buyRouter = PlatformUIKit.Router(builder: builder, currency: currency)
        buyRouter.start()
    }

    /// Starts Sell Crypto flow
    @objc func handleSellCrypto() {
        let accountSelectionService = AccountSelectionService()
        let interactor = SellRouterInteractor(
            accountSelectionService: accountSelectionService
        )
        let builder = PlatformUIKit.SellBuilder(
            accountSelectionService: accountSelectionService,
            routerInteractor: interactor
        )
        sellRouter = PlatformUIKit.SellRouter(builder: builder)
        sellRouter.load()
    }

    func startSimpleBuyAtLogin() {
        let stateService = PlatformUIKit.StateService()
        guard !stateService.cache.value[.hasShownIntroScreen] else {
            return
        }

        let builder = PlatformUIKit.Builder(
            stateService: stateService
        )

        buyRouter = PlatformUIKit.Router(builder: builder)
        buyRouter.start()
    }

    func showFundTrasferDetails(fiatCurrency: FiatCurrency, isOriginDeposit: Bool) {
        let stateService = PlatformUIKit.StateService()
        let builder = PlatformUIKit.Builder(
            stateService: stateService
        )

        buyRouter = PlatformUIKit.Router(builder: builder)
        buyRouter.setup(startImmediately: false)
        stateService.showFundsTransferDetails(
            for: fiatCurrency,
            isOriginDeposit: isOriginDeposit
        )
    }
}
