// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum RoutingAction<A> {
    case next(A)
    case previous
    case dismiss
}
