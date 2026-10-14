<div align="center">

# 💬 Codex Dev

### A small screen for a focused conversation.

**A phone-first Flutter interface experiment for keeping development conversations in view.**

Four threads, local drafts, scripted progress, and a reconnect flow, all in a self-contained simulation.

[**See the interface ↓**](#a-look-inside) · [**Run the demo →**](#try-the-interface) · [**Explore the boundaries →**](#what-is-real-and-what-is-simulated)

<br>

![Status](https://img.shields.io/badge/status-experimental%20UI%20demo-536171?style=flat-square)
![Stack](https://img.shields.io/badge/Flutter-Dart-287ec2?style=flat-square)
![Connectivity](https://img.shields.io/badge/Codex%20connection-none-85686b?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-24836b?style=flat-square)

</div>

> **Simulation only. No live Codex connection.** Every response, project, model option and connection state is generated locally by an inert mock. The app cannot execute shell commands, read your repositories, contact an AI service or access an account.

---

## A look inside

<table>
  <tr>
    <td align="center" width="50%">
      <a href="docs/screenshots/chat.png"><img src="docs/screenshots/chat.png" alt="Real Flutter UI screenshot showing a fictional Garden Notes conversation" width="320"></a>
    </td>
    <td align="center" width="50%">
      <a href="docs/screenshots/progress.png"><img src="docs/screenshots/progress.png" alt="Flutter demo showing scripted in-process progress rather than a real AI operation" width="320"></a>
    </td>
  </tr>
  <tr>
    <td align="center"><strong>01 · Keep threads separate</strong><br><sub>Four independent tabs, each with its own draft.</sub></td>
    <td align="center"><strong>02 · See a turn unfold</strong><br><sub>Scripted progress makes the UI flow testable.</sub></td>
  </tr>
  <tr>
    <td align="center">
      <a href="docs/screenshots/reply.png"><img src="docs/screenshots/reply.png" alt="In-process fictional response with no tool or repository access" width="320"></a>
    </td>
    <td align="center">
      <a href="docs/screenshots/reconnect.png"><img src="docs/screenshots/reconnect.png" alt="Locally simulated disconnect and reconnect interface" width="320"></a>
    </td>
  </tr>
  <tr>
    <td align="center"><strong>03 · Read the reply</strong><br><sub>An inert mock returns fictional text.</sub></td>
    <td align="center"><strong>04 · Recover the view</strong><br><sub>Try an in-process disconnect and reconnect.</sub></td>
  </tr>
</table>

<sub>These are genuine Chromium screenshots of the included Flutter app, not design mockups. All examples are fictional. Progress is scripted and is **not** an AI reasoning trace.</sub>

## What is real, and what is simulated?

| Real, inspectable UI behavior | Simulated or absent |
|:--|:--|
| Four independent chat tabs and per-tab drafts | No live language-model connection |
| Bounded prompt queue, cancellation and unread indicators | No shell commands or filesystem tools |
| Session-only activity and connection-state UI | No production server or account pairing |
| In-process scripted replies and reconnects | No persistent conversation storage across app restarts |
| Flutter app, controller and focused tests | No speech input, file transfer or deployed service |

Project paths are labels, not filesystem permissions. Model names are illustrative, not a current compatibility catalogue.

## Try the interface

**Requirements:** Flutter **3.44.1** (Dart **3.12.1**), Python 3, and a recent Chromium browser.

```bash
git clone https://github.com/jedufa/codex-dev.git
cd codex-dev
flutter pub get --enforce-lockfile
python3 scripts/check_demo_boundary.py
flutter analyze
flutter test
flutter build web --release --no-web-resources-cdn --no-wasm-dry-run
python3 -m http.server 8080 --bind 127.0.0.1 --directory build/web
```

Open **http://127.0.0.1:8080**. The server supplies locally built static assets; the running mock has no remote API. Characters outside bundled fonts may show as missing glyphs.

Switch tabs C1–C4, type a fictional request, queue another, then use **Demo settings → Simulate disconnect → Reconnect simulation**. Drafts and chat survive that simulated reconnect **only while the app process stays alive**. Reloading resets the session.

For an Android **debug** build, install Java 17 and Android SDK/platform 36, then run:

```bash
flutter build apk --debug
```

The Android demo has no Internet permission. No downloadable signed APK, app-store release, iOS host or desktop host is provided.

## Tests and implementation notes

The source passed **18 Flutter tests**, static analysis, local web and Android builds, a real API 35 emulator smoke check, and a browser workflow that blocks external network access after static assets are loaded. This is bounded engineering validation, **not a security certification**.

```bash
npm ci --ignore-scripts
npx playwright install chromium
npm run test:browser
```

Use Node 22 and the web build above for the browser workflow. See [validation](docs/validation.md), [architecture](docs/architecture.md) and [dependency notes](docs/dependencies.md).

The live HTTP client, credentials, secure storage, production server, command tools, speech integration, private history, deployment assets and original artwork are excluded. Speech-controller tests use a fake engine; speech is disabled in the application.

## Fork the interface, not the claims

Codex Dev is an **experimental, unmaintained source demo**. There is no promised support, pull-request review, security update or next release. The code is here to study, customize or continue; connecting real tools or AI services would be a separate engineering and security effort.

This project is **independent and not affiliated with or endorsed by OpenAI**. OpenAI and Codex trademarks remain with their owners.

[**Architecture**](docs/architecture.md) · [**Validation**](docs/validation.md) · [**Dependencies**](docs/dependencies.md) · [**License**](LICENSE) · [**Third-party notices**](THIRD_PARTY_NOTICES.md)

First-party source, tests and documentation: **MIT License**. Third-party fonts, Flutter templates and build tools retain their respective terms.

---

<div align="center">

### Design the experience first. Connect real systems only when the boundaries are ready.

*An open UI experiment for the small screen.*

</div>
