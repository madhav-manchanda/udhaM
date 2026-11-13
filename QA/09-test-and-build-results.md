# 09 — Test and build results

Date: 2026-11-14
Workspace: `/home/madhav/Downloads/udhaM-main`

## Toolchain

- Flutter 3.50.0 stable, Dart 3.14.0.
- Android SDK at `~/Android/Sdk`.
- Installed during this pass: platform 36, build-tools 36.0.0, CMake 3.22.1.
- NDK 28.2.13676358 was downloaded by the Gradle build.
- `android/gradle.properties` JVM heap reduced from 8 GB to 4 GB with two
  workers, because the original setting was killed on an 11 GB machine.

## Commands and results

### Static analysis

```bash
flutter analyze
```

Result:

```
No issues found!
```

### Automated tests

```bash
flutter test
```

Result:

```
All tests passed!
+103
```

New test file: `test/unit/sync_engine_test.dart` (6 tests) covering the
coordinator, crash recovery, retry/conflict states, offline behavior and the
new mutation type.

### Debug APK

```bash
ANDROID_HOME="$HOME/Android/Sdk" flutter build apk --debug
```

Result:

```
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

Artifact: `build/app/outputs/flutter-apk/app-debug.apk` (171 MB on disk).

### Release APK

```bash
ANDROID_HOME="$HOME/Android/Sdk" flutter build apk --release
```

Result:

```
✓ Built build/app/outputs/flutter-apk/app-release.apk (73.4MB)
```

Artifact: `build/app/outputs/flutter-apk/app-release.apk` (71 MB on disk).
Signed with the debug key by project configuration. Icon fonts were tree-shaken.

## Build warning

Flutter reports that Android Gradle Plugin 9.2.1 will soon be unsupported and
suggests 9.3.1 or newer. The build succeeds today; upgrading AGP is a separate,
riskier dependency update and was not attempted.

## What the tests do not prove

- No physical Android device was attached.
- No live Supabase project or `.env` was available.
- No two-device convergence, realtime, RLS or storage upload test was run.
- No iOS or Linux build was attempted.
