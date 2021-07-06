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
        var selectedRowId: Int?
        var rows: [TimelineRow]
    }

    public init(store: Store<TimelineState, TimelineAction>) {
        self.store = store
        self.viewStore = ViewStore(
            self.store.scope(
                state: {
                    ViewState(selectedRowId: $0.selectedRowId ,rows: $0.rows)
                }
            )
        )
    }

    public var body: some View {
        List {
            ForEach(viewStore.rows, id: \.id) { row in
                Button(action: { viewStore.send(.tappedRow(id: row.id)) }, label: {
                    HStack {
                        Text(row.title)
                        Text("\(row.id)")
                        if viewStore.selectedRowId == row.id {
                            Text("⭐️")
                        }
                    }
                })
            }
        }
    }

}
