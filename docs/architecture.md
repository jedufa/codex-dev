# How the demonstration works

`lib/main.dart` constructs `CodexDevApp` with `MockCodexApiClient`. The app's API
parameter is explicitly typed to that mock implementation. Controllers and
widgets retain the original typed interface shape, while the only included
implementation uses Dart futures/streams and fictional values.

The connection store is a small in-memory object. Disconnect clears that marker;
reconnect restores an inert marker and leaves chat/drafts in their existing
controllers. This demonstrates a UI transition, not persistent session recovery
across process death. Closing/reloading the app starts over.

The app does not interpret prompts, model identifiers or project paths as
commands. A delayed scripted reply produces the progress/reply states. The
queue and cancellation logic run locally. There are no sockets, HTTP clients,
filesystem imports, FFI, JavaScript bridges or platform I/O plugins in `lib/`.
The Android entry point loads Flutter only, with no Internet permission.

The browser preview uses a loopback static file server as development tooling.
Bundled Roboto/symbol fonts and a local Flutter renderer avoid external runtime
downloads. CSP limits connections to the local origin. Unsupported font fallback
is a local resource lookup, never an external service.
Build tools and tests necessarily use host capabilities; they are not a remote
command service exposed by the application.
