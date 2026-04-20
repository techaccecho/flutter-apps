# Flutter Apps
A collection of Flutter projects for team Project Echo.

## Flutter FVM
1. Install FVM
https://fvm.app/documentation/getting-started/overview

2. Use version 3.41.0
```
fvm use 3.41.0
```

## Helpful commands
### Running as a web app
`fvm flutter run -d chrome`

### Building for web
`fvm flutter build web`

## Things you'll need to understand about Flutter

### Widgets

Everything is a widget!
**Stateless widgets** - They just render a view
**Stateful widgets** - They render a view with state, and rerender when the state changes

You get Layout type widgets which will help you with the layout of the view components on the screen
Then you get content type widgets - Text, Image, Button, etc

Together these help you build the view/UI and interactive capabilities.

### BLoC - State management

Business Logic Component 
- It is a state management framwork.
- It allows you to extract the state from the view.
- Events are triggered to the Bloc, the bloc processes those events by computing some business logic, and it emits immutable states for the view to render.

As is native with Flutter, the view will rerender whenever the state changes. 
So emitting a new state (one or more of the properties are different) will rerender the view.
