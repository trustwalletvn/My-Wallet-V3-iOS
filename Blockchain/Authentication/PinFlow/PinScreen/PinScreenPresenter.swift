// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureSettingsDomain
import LocalAuthentication
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

private enum PinScreenPresenterError: Error {
    case absentPinValueWhenAuthenticateUsingBiometrics
}

// TODO: Dimitris - Move this to correct place
public struct ServerStatusViewModel {
    public let title: String?
    public let textViewModel: InteractableTextViewModel

    public init(title: String?, textViewModel: InteractableTextViewModel) {
        self.title = title
        self.textViewModel = textViewModel
    }
}

/// Presenter for PIN screen
final class PinScreenPresenter {

    // MARK: - Types

    typealias Settings = AppSettingsAPI &
        AppSettingsAuthenticating &
        CloudBackupConfiguring

    // MARK: - Properties

    var trailingButton: Screen.Style.TrailingButton {
        var hash = ""
        if let info = Bundle.main.infoDictionary {
            hash = (info[Constants.commitHash] as? String ?? "")
        }
        var title = "v\(Bundle.applicationVersion ?? "")"
        #if INTERNAL_BUILD
        title = "\(title) (\(hash))"
        #endif
        switch flow {
        case .create,
             .createPin:
            return .content(Screen.NavigationBarContent(title: title))
        case .authenticate(from: let origin, logoutRouting: _):
            switch origin {
            case .background, .attachedOn:
                return .content(Screen.NavigationBarContent(title: title))
            case .foreground:
                return .none
            }
        default:
            return .none
        }
    }

    var leadingButton: Screen.Style.LeadingButton {
        switch flow {
        case .authenticate(from: let origin, logoutRouting: _):
            switch origin {
            case .background, .attachedOn:
                return .text(value: LocalizationConstants.Pin.logoutButton)
            case .foreground:
                return .none
            }
        case .change, .enableBiometrics:
            return .back
        case .create:
            return .none
        case .createPin:
            return .none
        }
    }

    var titleView: Screen.Style.TitleView {
        switch flow {
        case .change:
            return .text(value: LocalizationConstants.Pin.changePinTitle)
        default:
            return .image(name: "logo_large", width: 40)
        }
    }

    var barStyle: Screen.Style.Bar {
        switch flow {
        case .authenticate(from: .background, logoutRouting: _):
            return .lightContent(ignoresStatusBar: true, isTranslucent: true, background: .clear)
        case .change(logoutRouting: _):
            return .lightContent(isTranslucent: true, background: .primary)
        default:
            return .lightContent(isTranslucent: true, background: .clear)
        }
    }

    let contentColor: UIColor
    let backgroundColor: UIColor

    // MARK: Rx

    private let disposeBag = DisposeBag()

    private let pinProcessingObservable: Observable<Pin>
    let pin = BehaviorRelay<Pin?>(value: nil)

    private let isProcessingRelay = BehaviorRelay<Bool>(value: false)

    /// When `true`, the the presenter is pending for an update from the interactor
    var isProcessing: Observable<Bool> {
        isProcessingRelay
            .observeOn(MainScheduler.instance)
    }

    var serverStatusRelay = PublishRelay<ServerStatusViewModel>()
    var serverStatus: Driver<ServerStatusViewModel> {
        serverStatusRelay
            .asDriver(onErrorDriveWith: .empty())
    }

    var learnMoreServerStatusTap: Signal<URL> {
        serverStatusRelay
            .map(\.textViewModel)
            .flatMap(\.tap)
            .map(\.url)
            .asSignal(onErrorSignalWith: .empty())
    }

    let serverStatusTitle = LocalizationConstants.ServerStatus.mainTitle

    private let digitPadIsEnabledRelay = BehaviorRelay<Bool>(value: true)
    var digitPadIsEnabled: Observable<Bool> {
        digitPadIsEnabledRelay
            .observeOn(MainScheduler.instance)
            .distinctUntilChanged()
    }

    private let remainingLockTimeMessageRelay = BehaviorRelay<String>(value: "")
    var remainingLockTimeMessage: Observable<String> {
        remainingLockTimeMessageRelay
            .observeOn(MainScheduler.instance)
    }

    // MARK: Routing

    private let performEffect: PinRouting.RoutingType.Effect
    private let forwardRouting: PinRouting.RoutingType.Forward
    let backwardRouting: PinRouting.RoutingType.Backward!

    // MARK: Services

    private let interactor: PinInteracting
    private let recorder: Recording
    private let appSettings: Settings
    private let biometryProvider: BiometryProviding
    private let credentialsStore: CredentialsStoreAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI

    // MARK: - View Models

    let digitPadViewModel: DigitPadViewModel
    let securePinViewModel: SecurePinViewModel

    /// The flow which `useCase` is under
    let flow: PinRouting.Flow

    /// The use case for the screen
    let useCase: PinScreenUseCase

    // MARK: - Setup

    init(
        useCase: PinScreenUseCase,
        flow: PinRouting.Flow,
        interactor: PinInteracting = PinInteractor(),
        biometryProvider: BiometryProviding = BiometryProvider(
            featureConfigurator: resolve()
        ),
        appSettings: Settings = BlockchainSettings.App.shared,
        recorder: Recording = CrashlyticsRecorder(),
        credentialsStore: CredentialsStoreAPI = resolve(),
        backwardRouting: PinRouting.RoutingType.Backward? = nil,
        forwardRouting: @escaping PinRouting.RoutingType.Forward,
        performEffect: @escaping PinRouting.RoutingType.Effect,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.useCase = useCase
        self.flow = flow
        self.interactor = interactor
        self.recorder = recorder
        self.appSettings = appSettings
        self.biometryProvider = biometryProvider
        self.backwardRouting = backwardRouting
        self.forwardRouting = forwardRouting
        self.credentialsStore = credentialsStore
        self.performEffect = performEffect
        self.analyticsRecorder = analyticsRecorder

        let emptyPinColor: UIColor
        let buttonHighlightColor: UIColor
        switch flow {
        case .change:
            contentColor = .primary
            backgroundColor = .white
            emptyPinColor = .securePinGrey
            buttonHighlightColor = UIColor.black.withAlphaComponent(0.08)
        case .authenticate, .create, .enableBiometrics, .createPin:
            contentColor = .white
            backgroundColor = .primary
            emptyPinColor = UIColor.white.withAlphaComponent(0.12)
            buttonHighlightColor = UIColor.white.withAlphaComponent(0.08)
        }

        // Setup the bottom leading button (biometrics) if necessary
        let customButtonViewModel: DigitPadButtonViewModel

        switch useCase {
        case .authenticateBeforeChanging, .authenticateOnLogin:
            let currentBiometricsType = biometryProvider.configuredType
            if currentBiometricsType.isValid {
                let biometricButtonImage: DigitPadButtonViewModel.Content.Image!
                switch currentBiometricsType {
                case .faceID:
                    biometricButtonImage = .faceId
                case .touchID:
                    biometricButtonImage = .touchId
                case .none:
                    biometricButtonImage = nil
                }
                let buttonBackground = DigitPadButtonViewModel.Background(
                    highlightColor: buttonHighlightColor
                )
                customButtonViewModel = DigitPadButtonViewModel(
                    content: .image(type: biometricButtonImage, tint: contentColor),
                    background: buttonBackground
                )
            } else {
                customButtonViewModel = .empty
            }
        case .authenticateBeforeEnablingBiometrics, .create, .select:
            customButtonViewModel = .empty
        }

        // Setup the subject
        let securePinTitle: String
        switch useCase {
        case .authenticateBeforeChanging, .authenticateBeforeEnablingBiometrics, .authenticateOnLogin:
            securePinTitle = LocalizationConstants.Pin.enterYourPinLabel
        case .select:
            securePinTitle = LocalizationConstants.Pin.createYourPinLabel
        case .create:
            securePinTitle = LocalizationConstants.Pin.confirmYourPinLabel
        }

        digitPadViewModel = DigitPadViewModel(
            padType: .pin(maxCount: 4),
            customButtonViewModel: customButtonViewModel,
            contentTint: contentColor,
            buttonHighlightColor: buttonHighlightColor
        )
        securePinViewModel = SecurePinViewModel(
            title: securePinTitle,
            tint: contentColor,
            emptyPinColor: emptyPinColor
        )

        // Bind PIN length to fill count
        digitPadViewModel.valueLengthObservable
            .bindAndCatch(to: securePinViewModel.fillCountRelay)
            .disposed(by: disposeBag)

        // Get the pin string once it's filled, map it to `Pin`, unwrap it.
        pinProcessingObservable = digitPadViewModel.valueInsertedObservable
            .withLatestFrom(digitPadViewModel.valueObservable)
            .map { Pin(string: $0) }
            .filter { $0 != nil }
            .map { $0! }

        // Bind pin processing to pin relay
        pinProcessingObservable
            .bindAndCatch(to: pin)
            .disposed(by: disposeBag)

        // Bind tapping on the biometrics button to authentication using biometrics
        digitPadViewModel.customButtonTapObservable
            .bind { [unowned self] in
                self.authenticateUsingBiometricsIfNeeded()
            }
            .disposed(by: disposeBag)

        // A count down timer starting from `remaining` seconds
        let timer = digitPadViewModel.remainingLockTimeObservable
            .flatMapLatest { remaining -> Observable<Int> in
                // Create a count down timer that counts for `remaining` seconds
                Observable<Int>.timer(.seconds(0), period: .seconds(1), scheduler: MainScheduler.instance)
                    .take(remaining) // takes the first `remaining` seconds
                    .map { $0 + 1 } // timer increment by 1 every time
                    .map { remaining - $0 } // `remaining` - timer value equals actual seconds remaining
            }

        // bind the timer to the lock time message shown when key pad is disabled
        timer
            .map(formatRemainingLockTimeMessage)
            .bindAndCatch(to: remainingLockTimeMessageRelay)
            .disposed(by: disposeBag)

        // bind the timer to the visibility of the key pad
        timer
            // check if seconds remaining is 0, if yes, enable keypad, otherwise disable
            .map { $0 == 0 }
            .bindAndCatch(to: digitPadIsEnabledRelay)
            .disposed(by: disposeBag)

        learnMoreServerStatusTap
            .emit(weak: self) { (self, url) in
                self.performEffect(.openLink(url: url))
            }
            .disposed(by: disposeBag)
    }

    func viewDidLoad() {

        // TODO: Re-enable this once we have isolated the source of the crash
//        interactor.serverStatus()
//            .map { incident -> ServerStatusViewModel in
//                ServerStatusViewModel(
//                    title: nil,
//                    textViewModel: .init(
//                        inputs: [
//                            .text(string: LocalizationConstants.ServerStatus.majorOutageSubtitle),
//                            .url(string: LocalizationConstants.ServerStatus.learnMore, url: incident.page.url)
//                        ],
//                        textStyle: .init(color: .white, font: UIFont.main(.medium, 16)),
//                        linkStyle: .init(color: .white, font: UIFont.main(.bold, 16))
//                    )
//                )
//            }
//            .bind(to: serverStatusRelay)
//            .disposed(by: disposeBag)
    }
}

// MARK: - Navigation

extension PinScreenPresenter {
    func leadingButtonPressed() {
        if !useCase.isAuthenticateOnLogin {
            backwardRouting()
        } else {
            logout()
        }
    }

    // TODO: Display an overlay for the pin
    func trailingButtonPressed() {}
}

// MARK: - Error Display

extension PinScreenPresenter {

    /// Formatting remaining PIN lock time error message
    /// - parameter duration: the lock time duration in seconds
    private func formatRemainingLockTimeMessage(duration: Int) -> String {
        var message = ""
        if duration > 0, duration <= 60 {
            message = LocalizationConstants.Pin.tryAgain +
                String(" \(duration)") + LocalizationConstants.Pin.seconds
        } else if duration > 60, duration <= 3600 {
            message = LocalizationConstants.Pin.tryAgain +
                String(" \(duration / 60)") + LocalizationConstants.Pin.minutes +
                String(" \(duration % 60)") + LocalizationConstants.Pin.seconds
        } else if duration > 3600 {
            message = LocalizationConstants.Pin.tryAgain +
                String(" \(duration / 3600)") + LocalizationConstants.Pin.hours +
                String(" \((duration / 60) % 60)") + LocalizationConstants.Pin.minutes +
                String(" \(duration % 60)") + LocalizationConstants.Pin.seconds
        }
        return message
    }
}

// MARK: - API & Functionality

extension PinScreenPresenter {

    /// Resets the pin
    /// - parameter value: the value to reset the pin to
    func reset(to value: String = "") {
        digitPadViewModel.reset(to: value)
    }

    /// Authenticate using set biometrics
    func authenticateUsingBiometricsIfNeeded() {

        // Verify the use case is authentication
        guard useCase.isAuthenticate else {
            return
        }

        // Verify biometrics authenticators are enabled on device and configured in app
        guard biometryProvider.configurationStatus.isConfigured else {
            return
        }

        /*
         At this point, the PIN is assumed to have been kept on
         keychain so it MUST have value, otherwise, report a non-fatal
         */
        guard let pin = appSettings.pin else {
            recorder.error(PinScreenPresenterError.absentPinValueWhenAuthenticateUsingBiometrics)
            return
        }

        biometryProvider.authenticate(reason: .enterWallet)
            .observeOn(MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak digitPadViewModel] _ in
                    // We reset the pin to the value kept by the app settings.
                    // That causes a chain reaction as if the user has filled the pin himself.
                    digitPadViewModel?.reset(to: pin)
                }
            )
            .disposed(by: disposeBag)
    }

    // MARK: - Changing/First Time Setting Pin

    /// Validates that the 1st pin entered by the user during the change pin flow,
    /// or the first time the user is setting a pin, is valid.
    func validateFirstEntry() -> Completable {
        Completable.create { [unowned self] completable in

            // Check for validity
            guard let pin = self.pin.value, pin.isValid else {
                completable(.error(PinError.invalid))
                return Disposables.create()
            }

            // Check that the current pin is different from the previous pin
            guard pin != self.useCase.pin else {
                completable(.error(PinError.identicalToPrevious))
                return Disposables.create()
            }

            // A completion to be executed in an case
            let completion = { [unowned self] in
                self.forwardRouting(.pin(value: pin))
                completable(.completed)
            }

            completion()
            return Disposables.create()
        }
    }

    /// Validates that the 2nd pin entered during the create/change pin flow matches the
    /// 1st pin entered, and if so, it will proceed to change the user's pin.
    func validateSecondEntry() -> Completable {
        Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }

            // Extract both current and previous pins before comparing them. Both MUST NOT be nil at that point
            let previousPin = self.useCase.pin!
            let pin = self.pin.value!

            // Current pin must be equal to the previous pin
            guard pin == previousPin else {
                completable(.error(PinError.pinMismatch(recovery: self.backwardRouting)))
                return Disposables.create()
            }

            // Generate a random key-pair
            guard let keyPair = try? PinStoreKeyPair.generateNewKeyPair() else {
                completable(.error(PinError.custom(LocalizationConstants.Pin.genericError)))
                return Disposables.create()
            }

            // Create the pin payload
            let payload = PinPayload(
                pinCode: pin.toString,
                keyPair: keyPair,
                persistsLocally: self.biometryProvider.configurationStatus.isConfigured
            )

            self.isProcessingRelay.accept(true)

            // Create the pin in the remote store
            self.interactor
                .create(using: payload)
                .observeOn(MainScheduler.instance)
                .do(onDispose: { [weak self] in
                    self?.isProcessingRelay.accept(false)
                })
                .flatMap(weak: self) { (self) in
                    self.backupCredentials(pinDecryptionKey: keyPair.value)
                }
                .subscribe(
                    onCompleted: {
                        completable(.completed)
                    },
                    onError: { error in
                        completable(.error(error))
                    }
                )
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }

    /// Invoked when user is authenticating himself using his PIN, before selecting a new one
    func verifyPinBeforeChanging() -> Completable {

        // Pin MUST NOT be nil at that point as it accompanies the use-case.
        let pin = self.pin.value!

        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }
            self.verify()
                .asCompletable()
                .do(onDispose: { [weak self] in
                    self?.isProcessingRelay.accept(false)
                })
                .subscribe(
                    onCompleted: { [weak self] in
                        self?.forwardRouting(.pin(value: pin))
                        completable(.completed)
                    },
                    onError: { error in
                        completable(.error(error))
                    }
                )
                .disposed(by: self.disposeBag)
            return Disposables.create()
        }
    }

    /// Invoked when user is authenticating himself using pin or biometrics.
    func authenticatePin() -> Completable {
        verify()
            .observeOn(MainScheduler.instance)
            .flatMap(weak: self) { (self, pinDecryptionKey) -> Single<String> in
                self.backupOrRestoreCredentials(pinDecryptionKey: pinDecryptionKey)
                    .andThen(.just(pinDecryptionKey))
            }
            .flatMapCompletable(weak: self) { (self, pinDecryptionKey) -> Completable in
                self.authenticatePin(pinDecryptionKey: pinDecryptionKey)
            }
    }

    /// Invoked during Pin Authentication.
    /// Proceeds with pin authentication using pinDecryptionKey to decrypt password.
    private func authenticatePin(pinDecryptionKey: String) -> Completable {
        interactor
            .password(from: pinDecryptionKey)
            .do(
                onSuccess: { [weak self] password in
                    self?.forwardRouting(.authentication(password: password))
                },
                onDispose: { [weak self] in
                    self?.isProcessingRelay.accept(false)
                }
            )
            .asCompletable()
    }

    /// Invoked during Pin Authentication.
    /// Under the 'regular' flow, `isPairedWithWallet` is already true.
    /// Backup credentials to iCloud if `isPairedWithWallet.
    /// Restore wallet guid and sharedKey from iCloud if `isPairedWithWallet` is false.
    private func backupOrRestoreCredentials(pinDecryptionKey: String) -> Completable {
        if shouldBackupCredentials {
            // Wallet is paired, back up credentials.
            return credentialsStore.backup(pinDecryptionKey: pinDecryptionKey)
        } else {
            // Wallet is not paired, attempt to retrieve wallet details from iCloud
            return credentialsStore
                .walletData(pinDecryptionKey: pinDecryptionKey)
                .do(
                    onSuccess: { [weak self] data in
                        // Restore everything to settings so the app can progress normally
                        self?.appSettings.guid = data.guid
                        self?.appSettings.sharedKey = data.sharedKey
                    }
                )
                .asCompletable()
                // Ignore any error regading restoring from iCloud
                .catchError { _ in .empty() }
        }
    }

    private var shouldBackupCredentials: Bool {
        appSettings.isPairedWithWallet && appSettings.cloudBackupEnabled
    }

    /// Invoked during Second Pin Validation.
    /// Backup credentials to iCloud if `isPairedWithWallet.
    private func backupCredentials(pinDecryptionKey: String) -> Completable {
        if shouldBackupCredentials {
            return credentialsStore.backup(pinDecryptionKey: pinDecryptionKey)
        } else {
            return .empty()
        }
    }
}

// MARK: - Accessors

extension PinScreenPresenter {

    /// Opts out the user
    func logout() {
        interactor.hasLogoutAttempted = true
        flow.logoutRouting?()
        credentialsStore.erase()
    }

    // Should be called after setting pin successfully
    func didSetPinSuccessfully() {
        forwardRouting(.pin(value: pin.value!))
    }

    // MARK: - Pin Validation

    /// Validates if the pin is correct, by generating payload (i.e. pin code and pin key combination)
    /// - Returns: Single wrapping the pin decryption key
    private func verify() -> Single<String> {
        guard Reachability.hasInternetConnection() else {
            let reset = { [weak self] () -> Void in
                self?.reset()
            }
            return .error(PinError.noInternetConnection(recovery: reset))
        }

        guard let pinKey = appSettings.pinKey else {
            return .error(PinError.nullifiedPinKey)
        }

        // Pin MUST NOT be nil at that point
        let pin = self.pin.value!

        // Create a pin payload to be validated by the interactor
        let payload = PinPayload(
            pinCode: pin.toString,
            pinKey: pinKey,
            persistsLocally: useCase.isAuthenticateBeforeEnablingBiometrics
        )

        isProcessingRelay.accept(true)

        // Ask the interactor to validate the payload
        return interactor.validate(using: payload)
            .observeOn(MainScheduler.instance)
    }
}

// MARK: - Alert View Models

/// In order to separate the alert UI from the pin presenter,
/// the presenter only decides what alert model should be displayed
/// and returns it to the component that requested it.
extension PinScreenPresenter {

    /// Logout alert model
    var logoutAlertModel: AlertModel {
        let okButton = AlertAction(style: .confirm(LocalizationConstants.okString))
        let image = UIImage(named: "lock_icon")!
        return AlertModel(
            headline: LocalizationConstants.Pin.tooManyAttemptsTitle,
            body: LocalizationConstants.Pin.tooManyAttemptsLogoutMessage,
            actions: [okButton],
            image: image,
            style: .sheet
        )
    }

    /// Enabling biometrics alert model (if biometrics is configurable)
    var biometricsAlertModel: AlertModel? {
        let biometricsStatus = biometryProvider.configurationStatus

        // Ensure bioemtrics is configurable before continuing
        guard biometricsStatus.isConfigurable else {
            return nil
        }

        let okButtonAction = { [unowned self] in
            self.interactor.persist(pin: self.pin.value!)
        }
        let okButton = AlertAction(
            style: .confirm(LocalizationConstants.okString),
            metadata: .block(okButtonAction)
        )
        let cancelButton = AlertAction(style: .default(LocalizationConstants.Pin.enableBiometricsNotNowButton))
        let title: String
        let image: UIImage
        switch biometricsStatus.biometricsType {
        case .faceID:
            title = LocalizationConstants.Pin.enableFaceIdTitle
            image = UIImage(named: "face_id_icon")!
        default: // touch-id
            title = LocalizationConstants.Pin.enableTouchIdTitle
            image = UIImage(named: "touch_id_icon")!
        }
        let alert = AlertModel(
            headline: title,
            body: LocalizationConstants.Pin.enableBiometricsMessage,
            actions: [okButton, cancelButton],
            image: image.withRenderingMode(.alwaysTemplate),
            style: .sheet
        )
        return alert
    }

    /// Set pin success alert model
    var setPinSuccessAlertModel: AlertModel? {
        guard flow.isChange else {
            return nil
        }
        analyticsRecorder.record(event: AnalyticsEvents.New.Security.mobilePinCodeChanged)
        let okButton = AlertAction(style: .confirm(LocalizationConstants.continueString))
        let image = UIImage(named: "success_icon")!
        let alert = AlertModel(
            headline: LocalizationConstants.Pin.pinSuccessfullySet,
            body: "",
            actions: [okButton],
            image: image,
            style: .sheet
        )
        return alert
    }
}
