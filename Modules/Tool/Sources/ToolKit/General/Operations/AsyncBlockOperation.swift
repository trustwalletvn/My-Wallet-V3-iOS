// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public class AsyncBlockOperation: AsyncOperation {

    public typealias ExecutionBlock = (@escaping AsyncOperation.CompletionBlock) -> Void

    // MARK: Private Properties

    fileprivate let executionBlock: ExecutionBlock

    // MARK: Lifecycle

    public init(executionBlock: @escaping ExecutionBlock) {
        self.executionBlock = executionBlock
    }

    // MARK: Overrides

    override public func begin(done: @escaping () -> Void) {
        executionBlock(done)
    }
}
