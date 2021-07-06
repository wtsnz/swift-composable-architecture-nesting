//
//  ContentView.swift
//  NestingExample
//
//  Created by Will Townsend on 2021-06-30.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: Store<AppState, AppAction>

    init() {
        self.store = Store(
            initialState: AppState(
                selectedTab: .home,
                webSocketState: .init(),
                timelineState: .init(),
                accountState: .init()
            ),
            reducer: appReducer,
            environment: AppEnvironment(
                mainQueue: .main
            )
        )
    }

    var body: some View {
        WithViewStore(self.store) { viewStore in
            TabView(
                selection: viewStore.binding(
                    get: \.selectedTab,
                    send: AppAction.changeTab
                ),
                content:  {
                    TimelineView(
                        store: store.scope(
                            state: \.composedTimelineState,
                            action: AppAction.timeline
                        )
                    )
                    .tabItem { Text("Home") }
                    .tag(AppState.Tab.home)

                    AccountView(
                        store: store.scope(
                            state: \.composedAccountState,
                            action: AppAction.account
                        )
                    )
                    .tabItem { Text("Account") }
                    .tag(AppState.Tab.account)
                })
                .onAppear {
                    viewStore.send(.webSocket(.start))
                }
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
