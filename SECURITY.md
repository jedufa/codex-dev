# Security and scope

This release is an experimental, unmaintained UI simulation. No live server,
remote execution API or account connection is included. The only app entry point
constructs MockCodexApiClient; replies and state live in memory. The app has no
runtime plugins, I/O imports or Android Internet permission. It reads packaged
UI/font resources and may copy a selected user bubble to the local clipboard.
No workspace file is read or changed. Do not enter private information into a
demo or treat its fictional status cards as operational evidence.

Web bootstrap loads local static resources. A Content Security Policy limits
connections to that same local origin; font fallback is also constrained to a
local resource path. Characters outside the bundled font repertoire may display
a missing-glyph box. The browser validation blocks
external requests from the start and disables networking entirely after the first turn has loaded its local symbol
font, then repeats the interaction. No dynamic/API request is allowed at any point. scripts/check_demo_boundary.py rejects prohibited
source capabilities. These are useful checks, not exhaustive proof against all
future changes or upstream vulnerabilities. Development tools download their
own dependencies; they are separate from runtime behaviour.

The original privileged server, supervisor, HTTP transport, vault, command and
deployment code are deliberately outside this release. There is no supported
recipe here for exposing a remote shell. Adding such features requires a new
security design and validation effort.

No response-time, vulnerability triage or patch promise is made. Fork and review
the source before any use beyond this simulation.
