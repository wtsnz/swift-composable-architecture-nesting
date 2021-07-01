import Foundation
import ComposableArchitecture

enum AppAction {
    case changeTab(AppState.Tab)

    case webSocket(WebSocketAction)
    case timeline(TimelineAction)
    case account(AccountAction)
}

struct AppState: Equatable {
    enum Tab: Hashable {
        case home
        case account
    }

    var selectedTab: AppState.Tab = .home

    var webSocketState: WebSocketState
    var timelineState: TimelineState
    var accountState: AccountState
}

struct AppEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    webSocketReducer
        .pullback(
            state: \.webSocketState,
            action: /AppAction.webSocket,
            environment: { env in
                WebSocketEnvironment(mainQueue: env.mainQueue)
            }
        ),
    timelineReducer
        .pullback(
            state: \.timelineState,
            action: /AppAction.timeline,
            environment: { env in
                TimelineEnvironment(
                    mainQueue: env.mainQueue
                )
            }
        ),
    accountReducer
        .pullback(
            state: \.accountState,
            action: /AppAction.account,
            environment: { env in
                AccountEnvironment(
                    mainQueue: env.mainQueue
                )
            }
        ),
    .init { state, action, environment in

        switch action {
        case let .changeTab(tab):
            state.selectedTab = tab
        default:
            break
        }

        return .none
    }
)
.debug()
