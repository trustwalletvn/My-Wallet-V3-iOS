// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public enum CustodyActionState {

    /// The start of the custody-send flow
    case start

    /// Custody introduction, should only show based on a
    /// user defaults flag
    case introduction

    /// Backup but only if an introduction is shown
    /// otherwise it the state should be `backup`
    case backupAfterIntroduction

    /// Starts the `BackupRouter`
    case backup

    /// Route to send
    case send

    /// Route to receive
    case receive

    /// Route to activity
    case activity

    /// Route to fiat deposit
    case deposit(isKYCApproved: Bool)

    /// Route to buy
    case buy

    /// Route to sell
    case sell

    /// Route to swap
    case swap

    /// The withdrawal custodial funds screen
    case withdrawal

    case withdrawalFiat(isKYCApproved: Bool)

    /// The withdrawal screen but only
    /// if the user just backed up their wallet.
    /// Otherwise the state should be `withdrawal`
    case withdrawalAfterBackup

    /// ~Fin~
    case end
}
