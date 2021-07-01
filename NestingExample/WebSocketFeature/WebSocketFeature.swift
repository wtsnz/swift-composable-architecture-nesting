import Foundation
import ComposableArchitecture

struct WebSocketMessage: Equatable {
    let id: Int
    let message: String
}

enum WebSocketAction {
    case start
    case stop

    case startResponse(isConnected: Bool)
    case recievedMessage(message: String)

    case timerTicked
}

struct WebSocketState: Equatable {
    enum ConnectionState: Hashable {
        case pending
        case connected
        case disconnected
    }

    var connectionState: ConnectionState = .pending
    var lastTenMessages: [WebSocketMessage] = []
    var messagesReceived: Int = 0
}

struct WebSocketEnvironment {
    var mainQueue: AnySchedulerOf<DispatchQueue>
}

let webSocketReducer = Reducer<WebSocketState, WebSocketAction, WebSocketEnvironment>.init { state, action, environment in

    struct TimerId: Hashable {}

    switch action {
    case .start:
        guard state.connectionState != .connected else {
            return .none
        }

        return Effect(value: .startResponse(isConnected: true))
            .delay(for: 2, scheduler: environment.mainQueue)
            .eraseToEffect()

    case .stop:
        return Effect(value: .startResponse(isConnected: false))
            .delay(for: 2, scheduler: environment.mainQueue)
            .eraseToEffect()

    case let .startResponse(isConnected):
        if isConnected {
            state.connectionState = .connected

            return Effect.timer(
                id: TimerId(),
                every: 1,
                tolerance: .zero,
                on: environment.mainQueue
              )
              .map { _ in .timerTicked }

        } else {
            state.connectionState = .disconnected
            return Effect.cancel(id: TimerId())
        }

    case let .recievedMessage(message):
        state.lastTenMessages.append(WebSocketMessage(id: state.messagesReceived, message: message))
        state.lastTenMessages = state.lastTenMessages.suffix(10) // Keep only the last 10
        state.messagesReceived += 1

        return .none

    case .timerTicked:
        return Effect(value: .recievedMessage(message: "Message"))
    }
}
