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

    var composedAccountState: ComposedAccountState {
        get {
            ComposedAccountState(
                accountState: accountState,
                webSocketState: webSocketState
            )
        }
        set {
            accountState = newValue.accountState
            webSocketState = newValue.webSocketState
        }
    }

    var composedTimelineState: ComposedTimelineState {
        get {
            ComposedTimelineState(
                timelineState: timelineState,
                webSocketState: webSocketState
            )
        }
        set {
            timelineState = newValue.timelineState
            webSocketState = newValue.webSocketState
        }
    }

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
            state: \.composedTimelineState,
            action: /AppAction.timeline,
            environment: { env in
                TimelineEnvironment(
                    mainQueue: env.mainQueue
                )
            }
        ),
    accountReducer
        .pullback(
            state: \.composedAccountState,
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
