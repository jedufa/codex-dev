# Dependency review

Only Flutter is a direct runtime dependency. Platform plugins were removed.
Hosted package versions/hashes are pinned in pubspec.lock; SDK packages bind to
Flutter 3.44.1. Packages and compiled engine artifacts are not vendored.

## Dart graph

| Package | License declaration |
|---|---|
| async | BSD-3-Clause |
| boolean_selector | BSD-3-Clause |
| characters | BSD-3-Clause |
| clock | Apache-2.0 |
| collection | BSD-3-Clause |
| fake_async | Apache-2.0 |
| flutter | BSD-3-Clause |
| flutter_lints | BSD-3-Clause |
| flutter_test | BSD-3-Clause |
| leak_tracker | BSD-3-Clause |
| leak_tracker_flutter_testing | BSD-3-Clause |
| leak_tracker_testing | BSD-3-Clause |
| lints | BSD-3-Clause |
| matcher | BSD-3-Clause |
| material_color_utilities | Apache-2.0 |
| meta | BSD-3-Clause |
| path | BSD-3-Clause |
| sky_engine | BSD-3-Clause |
| source_span | BSD-3-Clause |
| stack_trace | BSD-3-Clause |
| stream_channel | BSD-3-Clause |
| string_scanner | BSD-3-Clause |
| term_glyph | BSD-3-Clause |
| test_api | BSD-3-Clause |
| vector_math | BSD-3-Clause |
| vm_service | BSD-3-Clause |

## Android graph

The actual debug compile/runtime/test graph contains these 50 external
coordinates. Licenses come from exact POMs or the identified parent/Flutter SDK
notice. This does not claim clearance for distributing a compiled app.

| Coordinate | License declaration |
|---|---|
| `androidx.activity:activity:1.8.1` | The Apache Software License, Version 2.0 |
| `androidx.annotation:annotation-experimental:1.4.0` | The Apache Software License, Version 2.0 |
| `androidx.annotation:annotation-jvm:1.8.1` | The Apache Software License, Version 2.0 |
| `androidx.annotation:annotation:1.8.1` | The Apache Software License, Version 2.0 |
| `androidx.arch.core:core-common:2.2.0` | The Apache Software License, Version 2.0 |
| `androidx.arch.core:core-runtime:2.2.0` | The Apache Software License, Version 2.0 |
| `androidx.collection:collection:1.1.0` | The Apache Software License, Version 2.0 |
| `androidx.concurrent:concurrent-futures:1.1.0` | The Apache Software License, Version 2.0 |
| `androidx.core:core-ktx:1.13.1` | The Apache Software License, Version 2.0 |
| `androidx.core:core-ktx:1.2.0` | The Apache Software License, Version 2.0 |
| `androidx.core:core:1.13.1` | The Apache Software License, Version 2.0 |
| `androidx.customview:customview:1.0.0` | The Apache Software License, Version 2.0 |
| `androidx.exifinterface:exifinterface:1.4.1` | The Apache Software License, Version 2.0 |
| `androidx.fragment:fragment:1.7.1` | The Apache Software License, Version 2.0 |
| `androidx.interpolator:interpolator:1.0.0` | The Apache Software License, Version 2.0 |
| `androidx.lifecycle:lifecycle-common-java8:2.7.0` | The Apache Software License, Version 2.0 |
| `androidx.lifecycle:lifecycle-common:2.7.0` | The Apache Software License, Version 2.0 |
| `androidx.lifecycle:lifecycle-livedata-core-ktx:2.7.0` | The Apache Software License, Version 2.0 |
| `androidx.lifecycle:lifecycle-livedata-core:2.7.0` | The Apache Software License, Version 2.0 |
| `androidx.lifecycle:lifecycle-livedata:2.7.0` | The Apache Software License, Version 2.0 |
| `androidx.lifecycle:lifecycle-process:2.7.0` | The Apache Software License, Version 2.0 |
| `androidx.lifecycle:lifecycle-runtime:2.7.0` | The Apache Software License, Version 2.0 |
| `androidx.lifecycle:lifecycle-viewmodel-savedstate:2.7.0` | The Apache Software License, Version 2.0 |
| `androidx.lifecycle:lifecycle-viewmodel:2.7.0` | The Apache Software License, Version 2.0 |
| `androidx.loader:loader:1.0.0` | The Apache Software License, Version 2.0 |
| `androidx.profileinstaller:profileinstaller:1.3.1` | The Apache Software License, Version 2.0 |
| `androidx.savedstate:savedstate:1.2.1` | The Apache Software License, Version 2.0 |
| `androidx.startup:startup-runtime:1.1.1` | The Apache Software License, Version 2.0 |
| `androidx.tracing:tracing:1.2.0` | The Apache Software License, Version 2.0 |
| `androidx.versionedparcelable:versionedparcelable:1.1.1` | The Apache Software License, Version 2.0 |
| `androidx.viewpager:viewpager:1.0.0` | The Apache Software License, Version 2.0 |
| `androidx.window.extensions.core:core:1.0.0` | The Apache Software License, Version 2.0 |
| `androidx.window:window-java:1.2.0` | The Apache Software License, Version 2.0 |
| `androidx.window:window:1.2.0` | The Apache Software License, Version 2.0 |
| `com.getkeepsafe.relinker:relinker:1.4.5` | The Apache Software License, Version 2.0 |
| `com.google.guava:listenablefuture:1.0` | Apache-2.0 (guava-parent 26.0-android inherited) |
| `io.flutter:arm64_v8a_debug:1.0.0-c416acfeb8126e097f758c664aaa3da929e27da0` | BSD-3-Clause (Flutter engine; framework/engine notice, not vendored) |
| `io.flutter:armeabi_v7a_debug:1.0.0-c416acfeb8126e097f758c664aaa3da929e27da0` | BSD-3-Clause (Flutter engine; framework/engine notice, not vendored) |
| `io.flutter:flutter_embedding_debug:1.0.0-c416acfeb8126e097f758c664aaa3da929e27da0` | BSD-3-Clause (Flutter engine; framework/engine notice, not vendored) |
| `io.flutter:x86_64_debug:1.0.0-c416acfeb8126e097f758c664aaa3da929e27da0` | BSD-3-Clause (Flutter engine; framework/engine notice, not vendored) |
| `org.jetbrains.kotlin:kotlin-stdlib-common:2.3.20` | Apache-2.0 |
| `org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.8.20` | The Apache License, Version 2.0 |
| `org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.8.20` | The Apache License, Version 2.0 |
| `org.jetbrains.kotlin:kotlin-stdlib:2.3.20` | Apache-2.0 |
| `org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.1` | The Apache Software License, Version 2.0 |
| `org.jetbrains.kotlinx:kotlinx-coroutines-bom:1.7.1` | The Apache Software License, Version 2.0 |
| `org.jetbrains.kotlinx:kotlinx-coroutines-core-jvm:1.7.1` | The Apache Software License, Version 2.0 |
| `org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.1` | The Apache Software License, Version 2.0 |
| `org.jetbrains:annotations:23.0.0` | The Apache Software License, Version 2.0 |
| `org.jspecify:jspecify:1.0.0` | The Apache License, Version 2.0 |

Playwright test, playwright and playwright-core 1.60.0 are Apache-2.0 test-only
dependencies resolved by package-lock.json. Browsers, SDKs, JDKs and build caches
are not part of this source payload.
