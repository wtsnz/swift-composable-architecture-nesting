//
//  AccountView.swift
//  NestingExample
//
//  Created by Will Townsend on 2021-07-01.
//

import SwiftUI
import ComposableArchitecture

struct AccountView: View {

    private let store: Store<AccountState, AccountAction>
    @ObservedObject private var viewStore: ViewStore<ViewState, AccountAction>

    struct ViewState: Equatable {
        var messagesReceived: Int
    }

    public init(store: Store<AccountState, AccountAction>) {
        self.store = store
        self.viewStore = ViewStore(
            self.store.scope(
                state: {
                    ViewState(messagesReceived: $0.messagesReceived)
                }
            )
        )
    }

    public var body: some View {
        Text("\(viewStore.messagesReceived) messages receieved")
    }

}
