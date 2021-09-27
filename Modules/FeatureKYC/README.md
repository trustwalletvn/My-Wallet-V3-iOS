# KYC Module

_**NOTE: This documentation only applies to the latest implementation of KYC. This is what's stored in the `_New_KYC` subdirectories!**_

## FeatureKYCDomain

`FeatureKYCDomain` exposes a number of `Service`s and `APIClient`s that interface with Blockchain's APIs. All interfaces are exposed via `protocol`s and asynchrounous work is exposed to the client using the `Combine` framework's APIs. The framework also provides default implementations of all `Service`s and `Client`s but, of course, you can provide your own by adopting the relevant `protocol`s.

**NOTE**: The framework is designed so that the UI layer of your app (and `FeatureKYCUI`) only depend on  `Service`s but not on `APIClient`s. Those should be instanciated by the coordination/adaptation layer that is using the `Service`. This way you can keep dependencies on the UI layer to a minimum and use the `Services` to translate the `APIClient`s responses in the format most appropriate for the UI. 

### Usage

For example, to check the email verification status of a user you can write the following:

```swift
import Combine
import FeatureKYCDomain

let emailVerificationService: EmailVerificationServiceAPI = EmailVerificationService()
let cancellable = emailVerificationService.checkEmailVerificationStatus()
    .receive(on: DispatchQueue.main)
    .sink { (response) in
        // do stuff
    }
...
```

## FeatureKYCUI

The entry point, and only public interface for the new KYC module's UI implementation sits in the `Router`  class. You should use this class to present any part of the KYC flow exposed by it.

### Usage

For example, to present the Email Verification Flow you can write the following:

```swift
import FeatureKYCDomain
import FeatureKYCUI

let emailVerificationService: EmailVerificationServiceAPI = EmailVerificationService()
let router = FeatureKYCUI.Router(emailVerificationService: emailVerificationService)
router.routeToEmailVerification(
    from: viewController,
    emailAddress: "gtranchedone+ev@blockchain.com",
    flowCompletion: { [weak viewController] in
        viewController?.dismiss(animated: true, completion: nil)
    }
)
```

### Implementation Details

The new UI is implemented using [Swift Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture/) and SwiftUI.

#### Email Verification

The Email Verification flow is implemented using `EmailVerificationView` as a _master_ view defining the entire flow: from the root view to the navigation stack. That view wraps subviews implementing each a step of the flow.

SwiftUI Previews are available for all views in the module, covering multiple states when necessary.

**NOTE**: Alert states don't show in _static_ previews. Instead, you have to _run_ the preview to make it interactive, then any Alert will be presented. 
