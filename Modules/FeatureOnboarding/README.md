# Onboarding Feature

The Onboarding feature encompasses every segment of the app that prompts the user in performing a specific action.
In this sense, Onboarding is kind of a special feature as it's mostly limited to coordinating between other features to stitch them together and form onboarding flows.

For now, the feature only handles the onboarding flow intended to be presented to the user after they first sign up. In the future, this might include other forms of prompts. For example, it may eventually provide a way to show to the user "what's new" in a major release, or provide views for other features to consume to promt users to take an action like buying a newly supported crypto currency in the app.

## Key Classes

`FeatureOnboardingUI.OnboardingRouter` is the entry point to the feature. It requires providing a few dependencies in the form of protocols to be injected into the router or via `DIKit`.

## Demo

This module comes with a demo app. This app guides the user to the onboarding journey the user is supposed to take after signing up for the first time. To accomplish that, it uses demo implementations of key services.

NOTE: Because of how buying is implemented and because it heavily depends on `PlatformUIKit`, right now the demo only shows a sample screen for that section of the onboarding flow. However, the app can be used to try out every other part of the onboarding flow (currently only the Email Verification journey).

### Demo Instructions

The demo app is contructed so that the user Email Verification status is set to "unverified" by default. Tapping on "Check Inbox" within the journey, though, toggles the status to "verified". After tapping that button, simply wait for the screen to poll the latest data, and switch to the "email verified" prompt, or close and reopen the app to immediately refresh the status.   

You can reset the services to their default stubbed values, using the "reset" button in the main screen of the demo app.
