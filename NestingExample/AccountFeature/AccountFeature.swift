import Foundation
import ComposableArchitecture

enum AccountAction {
    
}

struct AccountState: Equatable {
    var messagesReceived: Int
}

struct AccountEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let accountReducer = Reducer<AccountState, AccountAction, AccountEnvironment>.combine(
    .init { state, action, environment in
        switch action {
        default:
            break
        }
        return .none
    }
)


