# Analytics Module

The analytics module is responsible for sending user analytics events to Firebase and the internal analytics backend.

### Adding new events

When adding a new event it's highly recommended to wrap it in the AnalyticsKit's extension of  `AnalyticsEvents.New` .
It's an empty class that acts as the namespace. It eases the process of finding events in the project.
The newly created event `enum` must conform to `AnalyticsEvent`. It will by default output the name and parameters using reflection.

Nabu's default scheme for automatic generation:
Name uses space case: `amazingEvent` -> `"Amazing Event"`
Params use snake case: `awesomeParameter` -> `"awesome_parameter"`

Automatically supported parameter values are: `Bool`, `Int`, `Double`, `String` and `StringRawRepresentable` for custom enums backed by `String`.

It's allowed to override `name` and `params` of the `AnalyticsEvent` to achieve custom JSON output.


```
extension AnalyticsEvents.New {
    enum YourAnalyticsEvent: AnalyticsEvent {
        var type: AnalyticsEventType { .nabu }
    
        // If optional `name` property is not implement it will output "Other Event"
        case otherEvent
        // If optional `name` property is not implement it will output "Amazing Event"
        // If optional `params` property is not implemented it will output: "awesome_parameter" and "value" for associated values
        case amazingEvent(awesomeParameter: AwesomeParameterType, value: Double)
         
    }
    
    // StringRawRepresentable is used for custom enum types that translate to String in JSON.
    public enum AwesomeParameterType: String, StringRawRepresentable {
        case firstType = "FIRST"
        case secondType = "SECOND"
    }
    
    // Optional - only override if you need custom name for the event.
    var name: String {
        switch self {
        case .amazingEvent:
            return "🤓 custom name of the event 🤓"
        case .otherEvent:
            return "other_event"
        }
    }

    // Optional - only override if you need custom parameters names for the event.
    var params: [String: String]? {
        switch self {
        case let .amazingEvent(awesomeParameter, value):
            return [
                "parameter": awesomeParameter.rawValue,
                "value": value
            ]
        case .otherEvent:
            return nil
        }
    }
}
```

### Usage

After importing `AnalyticsKit` create `AnalyticsEventRecorder` directly or by using dependency injection framework. 

```
import AnalyticsKit

final class TokenRepository: TokenRepositoryAPI {
    var token: String? {
        "token"
    }
}

final class GuidProvider: GuidProviderAPI {
    var guid: String? {
        "guid"
    }
}

let apiUrl = https://api.dev.blockchain.info
let userAgent = "User-Agent"
let nabuAnalyticsServiceProvider = NabuAnalyticsProvider(platform: .wallet,
                                                         basePath: apiUrl,
                                                         userAgent: userAgent,
                                                         tokenRepository: TokenRepository(),
                                                         guidProvider: GuidProvider())
                                                         
let analyticsRecorder = AnalyticsEventRecorder(analyticsServiceProviders: [
    nabuAnalyticsServiceProvider
])
```

To track the event, simply call the `record(event:)` function and pass the event as a parameter.


```
import AnalyticsKit

class ClassToBeAnalyzed {

    private let analyticsRecorder: AnalyticsEventRecorderAPI

    init(analyticsRecorder: AnalyticsEventRecorderAPI = resolve()) {
        self.analyticsRecorder = analyticsRecorder
    }
    
    func functionToBeTracked() {
        recorder.record(event: AnalyticsEvents.New.Event.firstEvent(param: "paramValue"))
    }
}
```

### Adding custom providers

You can add multiple custom analytics providers, by implementing an object that conforms to  `AnalyticsServiceProviding` and registering it in `AnalyticsEventRecorder`. 
In Blockchain Wallet it's used to implement `FirebaseAnalyticsServiceProvider`.


```
public class BlockchainAnalyticsProvider: AnalyticsServiceProviding {
    
    public var supportedEventTypes: [AnalyticsEventType] = [.new]
    
    public init() {}
    
    public func trackEvent(title: String, parameters: [String : Any]? = nil) {
        print("New Event:\n\(title)\n\(parameters)")
    }
}
```
