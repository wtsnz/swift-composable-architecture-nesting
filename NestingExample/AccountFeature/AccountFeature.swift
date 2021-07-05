import Foundation
import ComposableArchitecture

enum AccountAction {
    case webSocket(WebSocketAction)
}

struct AccountState: Equatable {
    var messagesReceived: Int
    var webSocketState: WebSocketState
}

struct AccountEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let accountReducer = Reducer<AccountState, AccountAction, AccountEnvironment>.combine(
    webSocketReducer
        .pullback(
            state: \.webSocketState,
            action: /AccountAction.webSocket,
            environment: { env in
                WebSocketEnvironment(mainQueue: env.mainQueue)
            }
        ),
    .init { state, action, environment in
        switch action {
        case .webSocket(.recievedMessage):
            state.messagesReceived = state.webSocketState.messagesReceived
        default:
            break
        }
        return .none
    }
)


