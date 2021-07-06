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

---

### Possible Solution 1: Derrived states

See the branch `possible-solution-1` for code.

This appears to be a popular solution, and is the method described in the Swift Composable Architecture Case Studies.

Downsides:
- The Timeline's selected row index appears to have to be contained by the "parent" module. It would be nice for this state to be contained inside the module.
- Difficult to control SwiftUI state update animations. How could we dispatch the action so that the rows animate the change in the Home tab? Ideally the WebSocketFeature wouldn't know anything about SwiftUI, or have to worry about returning Effects wrapped in an animation.
- Potentially expensive conversion when mapping WebSocketState.lastTenMessages into TimelineRows each time the TimelineState is read.
- Odd property `set { }` (setters) are required when the Module is read only - see the AccountState property in AppFeature.

### Possible Solution 2: Each Feature Module contains WebSocket State

In order to try and address the first downside from Solution 1, we put the WebSocketState into each module that depends on it, and attempt to share the WebSocketState.

This solution, however, doesn't work because the State isn't shared from the AppFeature down to the AccountFeature and TimelineFeature. They use different instances of the State struct.

This makes sense as not every instance of the WebSocket Reducer receives a `.start` event (only the AppView dispatches this event when it appears, so only the AppFeature's reducer has started the WebSocket connection) and if we were to dispatch a `.start` event in each module, we'd end up with multiple Web Socket conections (timers in this example) which is not what we want. 

- Doesn't work as expected as no state is shared.
- Could work if the state of the WebSocket is contained in the Environment, and the Environment state is read into the Module state at the time of the initialisation (to sync). This gets a little hairy as then the module gets pushed out of TCA.

### Possible Solution 3: Add a "ComposedState" object

ComposedState is another object that contains the Module State and any states the module depends upon. These states are held the parent Module. In this case, the AppState.

However, the problem is that there isn't a way to respond to the actions that are dispatched from any Composed State. In this case we can't react to any WebSocket actions that are dispatched in the Account or Timeline Reducers, which we might want to do in order to respond to changes in the WebSocket state. If we want to display a message in the TimelineView when the WebSocket disconnects, how could we do this? 

Downsides:
- Reducers are not invoked when dependant state (WebSocket State) is changed so there is no way to react to sub-state changes.
- Computing derrived state on the fly from Composed State could be expensive. We can't cache the rows in TimelineFeature.swift:L24 with this method.
