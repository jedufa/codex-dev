"""Fail closed if the inert demo source gains a runtime I/O capability."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
errors = []
for path in (root / 'lib').rglob('*.dart'):
    text = path.read_text()
    for directive in re.finditer(r"(?:import|export|part)\s+['\"]([^'\"]+)['\"]", text):
        uri = directive.group(1)
        if uri.startswith('dart:') and uri not in {'dart:async', 'dart:convert', 'dart:math'}:
            errors.append(f'{path.relative_to(root)}: forbidden Dart capability')
        if uri.startswith('package:') and not uri.startswith(('package:flutter/', 'package:codex_dev/')):
            errors.append(f'{path.relative_to(root)}: forbidden plugin/dependency')
    if re.search(r'\b(?:HttpClient|Socket|WebSocket|Process|File|Directory|MethodChannel|EventChannel|NetworkImage)\b|Image\.network|dart:ffi|dart:js|dart:html', text):
        errors.append(f'{path.relative_to(root)}: forbidden runtime I/O surface')
for path in (root / 'android').rglob('AndroidManifest.xml'):
    if 'android.permission.INTERNET' in path.read_text():
        errors.append('Android host grants Internet permission')
main = (root / 'lib/main.dart').read_text()
if 'MockCodexApiClient()' not in main or 'CodexHttpApiClient' in main:
    errors.append('Entry point is not exclusively the in-process mock')
assert not errors, '\n'.join(errors)
print('PASS: no live client, runtime I/O imports, platform plugins or Android Internet permission')
