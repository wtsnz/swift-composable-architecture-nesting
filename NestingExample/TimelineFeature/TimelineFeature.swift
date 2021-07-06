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
    var selectedRowId: Int?
}

@dynamicMemberLookup
struct ComposedTimelineState: Equatable {
    var timelineState: TimelineState
    var webSocketState: WebSocketState

    var rows: [TimelineRow] {
        get {
            return webSocketState.lastTenMessages.map { TimelineRow(id: $0.id, title: $0.message) }
        }
    }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<TimelineState, T>) -> T {
        get { timelineState[keyPath: keyPath] }
        set { timelineState[keyPath: keyPath] = newValue }
    }
}

struct TimelineEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let timelineReducer = Reducer<ComposedTimelineState, TimelineAction, TimelineEnvironment>.combine(
    .init { state, action, environment in
        switch action {
        case let .tappedRow(id):
            state.selectedRowId = id
        }
        return .none
    }
)


