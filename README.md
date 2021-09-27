# Blockchain Wallet for iOS

![Banner](Documentation/Other/github_banner.png)
![GitHub last commit](https://img.shields.io/github/last-commit/blockchain/My-Wallet-V3-iOS.svg)
![GitHub pull requests](https://img.shields.io/github/issues-pr/blockchain/My-Wallet-V3-iOS.svg)

# Building

## Install Xcode

After installing Xcode, open it to begin the Command Line Tools installation. After finished, make sure that a valid CL Tool version is selected in `Xcode > Preferences > Locations > Command Line Tools`.

## Install Git submodules

    $ git submodule update --init

If the submodules are not fetched, run:

    $ git submodule update --recursive --force

### If you don't have read access to My-Wallet-V3-Private:

Open .gitmodules and modify My-Wallet-V3 entry url to the public repo:

`.gitmodules` from:
```
[submodule "Submodules/My-Wallet-V3"]
    path = Submodules/My-Wallet-V3
    url = git@github.com:blockchain/My-Wallet-V3-Private.git
    ignore = dirty
```
to:
```
[submodule "Submodules/My-Wallet-V3"]
    path = Submodules/My-Wallet-V3
    url = git@github.com:blockchain/My-Wallet-V3.git
    ignore = dirty
```

Then run:

    $ git submodule sync
    $ git submodule update --init

## Install `homebrew`

https://brew.sh/

## Install Ruby dependencies

Install a Ruby version manager such as [rbenv](https://github.com/rbenv/rbenv).

    $ brew update && brew install rbenv
    $ rbenv init

Install a recent ruby version:

    $ rbenv install 2.6.5
    $ rbenv global 2.6.5
    $ eval "$(rbenv init -)"

Then the project ruby dependencies (`fastlane`, etc.):

    $ gem install bundler
    $ bundle install

## Install build dependencies (brew)

    $ sh scripts/install-brew-dependencies.sh

## Install JS Dependencies

You will be installing:
    - [nvm](https://github.com/nvm-sh/nvm.git)
    - [node](https://nodejs.org/)
    - [yarn](https://github.com/yarnpkg/yarn)

### Install nvm and Node

Check [nvm installaton instructions](https://github.com/nvm-sh/nvm#installing-and-updating).

    $ curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

Install the correct node version:

    $ nvm install 8.17.0
    $ nvm use 8.17.0

### Install Yarn
    $ brew install yarn

### Checkout ios branch from Submodules/My-Wallet-V3
    $ cd Submodules/My-Wallet-V3
    $ git checkout ios
    $ cd ../..

### Install and build js files
    $ sh scripts/install-js.sh && sh scripts/build-js.sh


## Prepare OpenSSL

    $ cd ./Submodules/OpenSSL-for-iPhone
    $ ./build-libssl.sh --cleanup --archs="x86_64 arm64"

## Add production Config file

Clone the [wallet-ios-credentials](https://github.com/blockchain/wallet-ios-credentials) repository and copy it's `Config` directory to this project root directory, it contains a `.xcconfig` for each environment:

```
Config/BlockchainConfig/Dev.xcconfig
Config/BlockchainConfig/Production.xcconfig
Config/BlockchainConfig/Staging.xcconfig
Config/BlockchainConfig/Alpha.xcconfig
Config/NetworkKitConfig/Dev.xcconfig
Config/NetworkKitConfig/Production.xcconfig
Config/NetworkKitConfig/Staging.xcconfig
Config/NetworkKitConfig/Alpha.xcconfig
```

For example, This is how `BlockchainConfig/Production.xcconfig` looks like:

```
ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon
OPENSSL_CERT_URL = blockchain.info
```

For example, This is how `NetworkKitConfig/Production.xcconfig` looks like:

```
API_URL = api.blockchain.info
BUY_WEBVIEW_URL = blockchain.info/wallet/#/intermediate
COINIFY_URL = app-api.coinify.com
EXCHANGE_URL = exchange.blockchain.com
EXPLORER_SERVER = blockchain.com
RETAIL_CORE_SOCKET_URL = ws.blockchain.info/nabu-gateway/markets/quotes
RETAIL_CORE_URL = api.blockchain.info/nabu-gateway
WALLET_SERVER = blockchain.info
```

## Add Firebase Config Files

Clone `wallet-ios-credentials` repository and copy it's `Firebase` directory into `Blockchain` directory, it contains a `GoogleService-Info.plist` for each environment.

```
Firebase/Dev/GoogleService-Info.plist
Firebase/Prod/GoogleService-Info.plist
Firebase/Staging/GoogleService-Info.plist
Firebase/Alpha/GoogleService-Info.plist
```

## Add environment variables for scripts

Clone `wallet-ios-credentials` repository and copy the `env` to the root folder of the project, hide the file by using `mv env .env`

## XcodeGen

We are integrating XcodeGen and, despite still committing project files in git, we should generate project files using the following script:

### Installing:

    $ brew install xcodegen

## Generate projects & dependencies: 

    $ sh scripts/bootstrap.sh

👉 Beware that this will take a while. Feel free to read some docs, a 📖, get a ☕, or go for a 🚶 while it runs…

⚠️ You may need to run the following command if you encounter an `xcode-select` error:

    $ sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

## Install mocks for testing:

Install mockingbird mock generator CLI:

    $ sh scripts/install-mockingbird.sh

Install mock generation script in targets. It will generate mocks first time the test are run:

    $ sh scripts/install-mocks.sh

## Build the project

    cmd-r

# Modules

Please refer to the [README](./Modules/README.md) in the `Modules` directory.
Please also refer to the [README](./TestKit/README.md) in the `TestKit` directory.

# Contributing

If you would like to contribute code to the Blockchain iOS app, you can do so by forking this repository, making the changes on your fork, and sending a pull request back to this repository.

When submitting a pull request, please make sure that your code compiles correctly and all tests in the `BlockchainTests` target passes. Be as detailed as possible in the pull request’s summary by describing the problem you solved and your proposed solution.

Additionally, for your change to be included in the subsequent release’s change log, make sure that your pull request’s title and commit message is prefixed using one of the changelog types.

The pull request and commit message format should be:

```
<changelog type>(<component>): <brief description>
```

For example:

```
fix(Create Wallet): Fix email validation
```

For a full list of supported types, see [.changelogrc](https://github.com/blockchain/My-Wallet-V3-iOS/blob/dev/.changelogrc#L6...L69).

# License

Source Code License: LGPL v3

Artwork & images remain Copyright Blockchain Luxembourg S.A.R.L

# Security

Security issues can be reported to us in the following venues:
* Email: security@blockchain.info
* Bug Bounty: https://hackerone.com/blockchain
