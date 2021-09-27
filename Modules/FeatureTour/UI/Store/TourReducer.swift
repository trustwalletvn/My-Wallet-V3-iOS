// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

let tourReducer = Reducer<TourState, TourAction, TourEnvironment> { _, action, _ in
    switch action {
    case .tourDidAppear:
        return .none
    }
}
