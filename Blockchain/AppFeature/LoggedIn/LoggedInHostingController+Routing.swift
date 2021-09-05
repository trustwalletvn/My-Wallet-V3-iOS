// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
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
                    Logger.shared.debug(String(describing: error))
                    AlertViewPresenter.shared.standardError(message: String(describing: error))
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
        accountsAndAddressesNavigationController = viewController
        return viewController
    }

    func handleAccountsAndAddresses() {
        present(createAccountsAndAddressesViewController(), animated: true)
    }

    func handleInterest() {
        unimplemented()
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
        present(alert, animated: true)
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
        present(alert, animated: true)
    }

    /// Starts Buy Crypto flow.
    func handleBuyCrypto(currency: CryptoCurrency = .coin(.bitcoin)) {
        coincore
            .cryptoAccounts(for: currency, supporting: .buy, filter: .custodial)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                // NOOP
            } receiveValue: { [weak self] accounts in
                self?.handleBuyCrypto(account: accounts.first)
            }
            .store(in: &cancellables)
    }

    func handleBuyCrypto(account: CryptoAccount?) {
        let presenter = topMostViewController ?? self
        transactionsAdapter.presentTransactionFlow(to: .buy(account), from: presenter) { result in
            Logger.shared.info("[AppCoordinator] Transaction Flow completed with result '\(result)'")
        }
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
        sellRouter?.load()
    }

    func startSimpleBuyAtLogin() {
        handleBuyCrypto()
    }

    func showFundTrasferDetails(fiatCurrency: FiatCurrency, isOriginDeposit: Bool) {
        let stateService = PlatformUIKit.StateService()
        let builder = PlatformUIKit.Builder(
            stateService: stateService
        )

        buyRouter = PlatformUIKit.Router(builder: builder, currency: .coin(.bitcoin))
        buyRouter?.setup(startImmediately: false)
        stateService.showFundsTransferDetails(
            for: fiatCurrency,
            isOriginDeposit: isOriginDeposit
        )
    }
}
