# Swift Composable Architecture: Nesting State

I've been enjoying using the Swift Composable Architecture over the last year. It comes with a promising sell and it mostly pulls it off. Thing is, I'm having a little trouble sharing state accross my apps and am not sure the best way forward.

With this example project I hope to demonstrate a problem that keeps popping up in projects I've used TCA with, along with a couple of potential solutions. It doesn't take much complexity for the nesting state issue to show up. Making an app that navigates between different modules via a push, or presentation sheet is enough to start facing this issue.

## The example app

The app is a fictional app where we have four Feature Modules that depend on some shared state to derrive their own state. Oh, and when I refer to a `Module`, I mean a collection of related State, Action, Environment and Reducer objects.

A general gist of the app is that we have a TabBar with two tabs. A Home Tab and an Account Tab. The Home Tab must show a list of the last 10 messages received by the WebSocket. The Account Tab must show the total number of messages received by the WebSocket.

The Modules are split out into:

- AppFeature Module
  - Responsible for the App's root most view and TabBar
- WebSocketFeature Module
  - Responsible for managing the (fake) webSocket connection and state
- AccountFeature Module
  - Responsible for showing the total number of messages sent
- TimelineFeature Module
  - Responsible for showing a timeline of TimelineItems in a list and keeping track of the id of the last selected item so we can render the text in a different color.

Right now, on the initial commit, I've fleshed out the initial version of this where each module works in their own right except from the AppFeature Module. In order to get the AppFeature, and thus the app, working, we'll have to somehow share the state of the WebSocket and derrive the related parts of the AccountState and TimelineState.  

Now, the question is, what is the most ideal way to get this example project working?
