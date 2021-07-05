import Foundation
import ComposableArchitecture

struct TimelineRow: Equatable {
    let id: Int
    let title: String
}

enum TimelineAction {
    case tappedRow(id: Int)
    case webSocket(WebSocketAction)
}

struct TimelineState: Equatable {
    var rows: [TimelineRow]
    var selectedRowId: Int?
    var webSocketState: WebSocketState
}

struct TimelineEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let timelineReducer = Reducer<TimelineState, TimelineAction, TimelineEnvironment>.combine(
    webSocketReducer
        .pullback(
            state: \.webSocketState,
            action: /TimelineAction.webSocket,
            environment: { env in
                WebSocketEnvironment(mainQueue: env.mainQueue)
            }
        ),
    .init { state, action, environment in
        switch action {
        case let .tappedRow(id):
            state.selectedRowId = id
        case .webSocket(.recievedMessage):
            state.rows = state.webSocketState.lastTenMessages.map { TimelineRow(id: $0.id, title: $0.message) }
        case .webSocket:
            break
        }
        return .none
    }
)


