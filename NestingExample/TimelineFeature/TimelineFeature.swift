import Foundation
import ComposableArchitecture

struct TimelineRow: Equatable {
    let id: Int
    let title: String
}

enum TimelineAction {
    case tappedRow(id: Int)
}

struct TimelineState: Equatable {
    var rows: [TimelineRow]
    var selectedRowId: Int?
}

struct TimelineEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let timelineReducer = Reducer<TimelineState, TimelineAction, TimelineEnvironment>.combine(
    .init { state, action, environment in
        switch action {
        case let .tappedRow(id):
            state.selectedRowId = id
        }
        return .none
    }
)


