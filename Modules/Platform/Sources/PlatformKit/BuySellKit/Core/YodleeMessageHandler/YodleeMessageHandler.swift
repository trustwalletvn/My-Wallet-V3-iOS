// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import WebKit

public final class YodleeMessageHandler: NSObject, WKScriptMessageHandler {

    static let yodleeHandlerName = "YWebViewHandler"

    public var receivedMessage: Observable<YodleeModel> {
        rx
            .methodInvoked(#selector(userContentController(_:didReceive:)))
            .compactMap { args -> WKScriptMessage? in
                guard args.count == 2 else {
                    return nil
                }
                guard let message = args[1] as? WKScriptMessage else {
                    return nil
                }
                return message
            }
            .filter { $0.name == YodleeMessageHandler.yodleeHandlerName }
            .compactMap { message -> YodleeModel? in
                guard let string = message.body as? String else { return nil }
                guard let data = string.data(using: .utf8) else { return nil }
                return try JSONDecoder().decode(YodleeModel.self, from: data)
            }
            .share(replay: 1, scope: .whileConnected)
    }

    private let webViewConfiguration: WKWebViewConfiguration

    public init(webViewConfiguration: WKWebViewConfiguration) {
        self.webViewConfiguration = webViewConfiguration
        super.init()
    }

    deinit {
        webViewConfiguration
            .userContentController
            .removeScriptMessageHandler(forName: YodleeMessageHandler.yodleeHandlerName)
    }

    /// Registers the underlying configuration to receive events
    public func registerForEvents() {
        webViewConfiguration
            .userContentController
            .add(self, name: YodleeMessageHandler.yodleeHandlerName)
    }

    // MARK: - WKScriptMessageHandler

    public func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        // empty implementation on purpose as it will be handled by `receivedMessage` observable
    }
}
