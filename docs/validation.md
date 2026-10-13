# Validation and limits

Toolchain: Flutter 3.44.1 / Dart 3.12.1, Node 22.22.1, Playwright 1.60.0 / Chromium,
Python 3.14.4, Java 17, Gradle 9.1.0, Android Gradle Plugin 9.0.1,
Kotlin 2.3.20, Android SDK 36 and API 35 x86_64 emulator.

- 18 Flutter tests: controller queue/cancel/unread behaviour, chat scrolling,
  pure speech formatting with a fake engine, and the whole simulated
  send/progress/tab-draft/disconnect/reconnect flow under a denying HTTP override.
- Flutter analyzer and Android debug/web release builds.
- Browser: actual Flutter UI at 430×850, local static bootstrap only, no external
  requests, then fully offline repeated send/progress/reply, tab draft isolation and reconnect.
  The first turn may load the bundled symbol font; only exact static GET paths
  are allowed, without query strings. Subsequent runtime fetch/XHR/socket/beacon
  attempts are trapped and asserted absent.
- Android emulator: launch, scripted response to a typed fictional prompt,
  disconnect and local reconnect. The merged manifest grants no Internet access.
- Static boundary guard: allowlisted Dart/framework imports, no live transport,
  subprocess, socket, file, FFI/JS bridge or platform plugin in app source.

The four screenshots come from that included browser workflow. They are actual
app renders with fictional Garden Notes data, not generated illustrations.
Set CAPTURE_DIR to an output directory when running the Playwright suite to
reproduce them; timestamps and rendering can vary. Source/image hashes are
recorded in the private release receipt.

HTTP transport tests and the original server-pairing/settings tests are excluded
with those features. This is not an inherited full-product test claim. Speech
is disabled at runtime; only its pure formatter/controller interface is tested
with a fake engine. No iOS, physical-device, live Codex/backend, encrypted storage,
store, production deployment, exhaustive vulnerability or formal qualification
claim is made. Android debug signing is for local testing only.

The web build emits a Cupertino font-reference warning. No Cupertino font is
bundled; the tested Chromium/Android flows render the included Material icons.
An iOS interface is outside this release.
