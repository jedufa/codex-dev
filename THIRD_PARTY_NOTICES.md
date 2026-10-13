# Third-party notices

The root MIT grant covers the authorized first-party source/tests/docs. It does
not replace upstream licenses or grant rights to OpenAI/Codex or other marks.

- Flutter Android/web host templates were generated with Flutter 3.44.1
  (revision 924134a44c). Flutter's BSD notice is retained in
  [third_party/Flutter_LICENSE.txt](third_party/Flutter_LICENSE.txt).
- Roboto Regular/Bold are bundled from the official Flutter material-fonts
  artifact and verified byte-for-byte against that immutable upstream archive.
  Their Apache-2.0 notice is [assets/fonts/LICENSE.txt](assets/fonts/LICENSE.txt).
- Noto Sans Symbols is bundled from the official google/fonts project under
  [SIL OFL 1.1](assets/fonts/NotoSansSymbols_OFL.txt). It supplies local symbol
  fallback; this font retains its original license and is not relicensed MIT.
- Material Icons are supplied by the Flutter SDK at build time. Its Apache notice
  is retained in [third_party/MaterialIcons_LICENSE.txt](third_party/MaterialIcons_LICENSE.txt).
- Gradle 9.1.0 wrapper scripts retain their Apache notices. The wrapper JAR was
  verified against the official published hash, `76805e32c009c0cf0dd5d206bddc9fb22ea42e84db904b764f3047de095493f3`.
  The distribution checksum is pinned in gradle-wrapper.properties. Official
  [LICENSE](third_party/gradle/LICENSE) and [NOTICE](third_party/gradle/NOTICE)
  are retained from the checksum-verified distribution.
- The app icon is a new simple vector chat shape. No original raster icon,
  tattoo image, private media or uncleared artwork is included. Screenshots show
  the actual included app with fictional data.

See [the resolved dependency review](docs/dependencies.md) for 26 SDK/hosted Dart
packages and 50 exact Android dependency coordinates. SDKs, dependency caches,
compiled engines, browsers and app binaries are not redistributed. New forks
must review their own added components and any binary distribution separately.
