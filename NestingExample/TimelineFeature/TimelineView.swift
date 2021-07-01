//
//  TimelineView.swift
//  NestingExample
//
//  Created by Will Townsend on 2021-07-01.
//

import SwiftUI
import ComposableArchitecture

struct TimelineView: View {

    private let store: Store<TimelineState, TimelineAction>
    @ObservedObject private var viewStore: ViewStore<ViewState, TimelineAction>

    struct ViewState: Equatable {
        var rows: [TimelineRow]
    }

    public init(store: Store<TimelineState, TimelineAction>) {
        self.store = store
        self.viewStore = ViewStore(
            self.store.scope(
                state: {
                    ViewState(rows: $0.rows)
                }
            )
        )
    }

    public var body: some View {
        List {
            ForEach(viewStore.rows, id: \.id) { row in
                HStack {
                    Text(row.title)
                    Text("\(row.id)")
                }
            }
        }
    }

}
