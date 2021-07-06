import Foundation
import ComposableArchitecture

enum AccountAction {
    case webSocket(WebSocketAction)
}

struct AccountState: Equatable {
}

@dynamicMemberLookup
struct ComposedAccountState: Equatable {
    var accountState: AccountState
    var webSocketState: WebSocketState

    var messagesReceived: Int {
        get {
            return webSocketState.messagesReceived
        }
    }

    public subscript<T>(dynamicMember keyPath: WritableKeyPath<AccountState, T>) -> T {
        get { accountState[keyPath: keyPath] }
        set { accountState[keyPath: keyPath] = newValue }
    }
}

struct AccountEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let accountReducer = Reducer<ComposedAccountState, AccountAction, AccountEnvironment>.combine(
    .init { state, action, environment in
        switch action {
        default:
            break
        }
        return .none
    }
)


