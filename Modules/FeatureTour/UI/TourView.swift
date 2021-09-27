// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI

public struct TourView: View {

    let store: Store<TourState, TourAction>

    init(store: Store<TourState, TourAction>) {
        self.store = store
    }

    public init() {
        self.init(
            store: Store(
                initialState: TourState(),
                reducer: tourReducer,
                environment: TourEnvironment()
            )
        )
    }

    public var body: some View {
        WithViewStore(self.store) { _ in
            TabView {
                BrokerageView()
                EarnView()
                KeysView()
                PricesView()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        }
    }
}

private struct BrokerageView: View {

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.red)
                .contentShape(Rectangle())
            Text("Brokerage")
        }
    }
}

private struct EarnView: View {

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.purple)
                .contentShape(Rectangle())
            Text("Earn")
        }
    }
}

private struct KeysView: View {

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.green)
                .contentShape(Rectangle())
            Text("Keys")
        }
    }
}

private struct PricesView: View {

    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.pink)
                .contentShape(Rectangle())
            Text("Prices")
        }
    }
}

struct TourView_Previews: PreviewProvider {
    static var previews: some View {
        TourView()
    }
}
