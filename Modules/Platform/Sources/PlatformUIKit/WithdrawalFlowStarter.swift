//
//  WithdrawalFlowStarter.swift
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

public protocol WithdrawFlowStarter: AnyObject {
    /// Helper method for starting the withdraw flow
    func startFlow(flowDismissed: @escaping () -> Void)
}

/// Provides the entry point for `WithdrawRootRouter`
public protocol WithdrawBuildable {
    /// Builds the components for the Withdraw Flow
    ///
    ///
    /// - Returns: A tuple consisting
    ///     - `flow`: A `WithdrawFlowStarter` which allows the flow to start
    ///     - `controller`: A `UINavigationController` object which acts as the root navigation of the flow.
    func build() -> (flow: WithdrawFlowStarter, controller: UINavigationController)
}
