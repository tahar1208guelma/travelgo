---
name: production-deployment
description: Production release builds, CI/CD pipelines, and post-deployment verification. Use this skill when preparing production releases (Android App Bundle, iOS IPA, Web builds), configuring code signing and build flavors, building automated GitHub Actions or Fastlane pipelines, and executing smoke-test verification.
---

# Production Release Builds, CI/CD & Deployment Verification

This skill provides an end-to-end operational guide for compiling release binaries, configuring automated CI/CD deployment pipelines, managing signing keys securely, and executing post-deployment verification.

---

## 1. Objectives & Scope

- **Reproducible Release Builds**: Generate optimized, signed release artifacts (Android AAB/APK, iOS IPA, Web) with code obfuscation and debug symbol splitting.
- **Automated CI/CD Workflows**: Enforce strict continuous integration gating (analysis, linting, tests) before publishing artifacts.
- **Secure Code Signing**: Protect production release keys, keystores, and provisioning profiles using encrypted CI vault secrets.
- **Phased Rollout Management**: Execute staged rollouts (10% -> 25% -> 50% -> 100%) to mitigate sudden regressions.
- **Post-Deploy Smoke Testing**: Verify application health, network connectivity, authentication, and error telemetry immediately after release.

---

## 2. Execution Instructions

### Step 1: Pre-Release Versioning & Changelog
1. Update `pubspec.yaml` following Semantic Versioning (`MAJOR.MINOR.PATCH+BUILD_NUMBER`):
   ```yaml
   version: 1.4.0+45
   ```
2. Update `CHANGELOG.md` with release notes categorized into Features, Bug Fixes, and Security Updates.
3. Ensure git working tree is clean and create a signed release tag:
   ```bash
   git tag -a v1.4.0 -m "Release version 1.4.0 (Build 45)"
   ```

### Step 2: Environment Configuration & Dart Defines
1. Pass environment configurations securely at compile time using `--dart-define`:
   ```bash
   flutter build appbundle --release \
     --dart-define=APP_ENV=production \
     --dart-define=API_GATEWAY_URL=https://api.travelgo.app \
     --obfuscate \
     --split-debug-info=build/symbols
   ```
2. Archive the `build/symbols` directory securely to enable stack trace de-obfuscation in crash reporting tools (e.g., Sentry, Firebase Crashlytics).

### Step 3: Android Release Signing
1. Store keystore outside of git tracking.
2. In `android/key.properties` (ignored in `.gitignore`):
   ```properties
   storePassword=STORE_PASSWORD_HERE
   keyPassword=KEY_PASSWORD_HERE
   keyAlias=travelgo_upload_key
   storeFile=/path/to/upload-keystore.jks
   ```
3. Reference `key.properties` in `android/app/build.gradle`:
   ```groovy
   signingConfigs {
       release {
           storeFile file(keyProperties['storeFile'])
           storePassword keyProperties['storePassword']
           keyAlias keyProperties['keyAlias']
           keyPassword keyProperties['keyPassword']
       }
   }
   ```

### Step 4: iOS Release & Fastlane Deployment
1. Build signed iOS archive:
   ```bash
   flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
   ```
2. Deploy to TestFlight or App Store via Fastlane:
   ```ruby
   lane :beta do
     increment_build_number(xcodeproj: "Runner.xcodeproj")
     build_app(workspace: "Runner.xcworkspace", scheme: "Runner")
     upload_to_testflight
   end
   ```

### Step 5: Web & Desktop Builds
1. For Web production deployments:
   ```bash
   flutter build web --release --web-renderer canvaskit --pwa-strategy=offline-first
   ```
2. Deploy output (`build/web/`) to hosting CDN (Firebase Hosting, Cloudflare Pages).

### Step 6: Post-Deployment Smoke Testing & Telemetry
1. **Synthetic Health Probe**: Run automated smoke test on release candidate:
   - App launches within 2.5 seconds.
   - Core search query executes and returns results.
   - User login and token refresh succeed.
   - Offline screen displays appropriate fallback.
2. **Telemetry Monitoring**:
   - Monitor Crashlytics crash-free user rate (must exceed 99.5%).
   - Check API gateway error rate (< 0.1% 5xx responses).

---

## 3. Practical Checklists

### Pre-Build Checklist
- [ ] Version and build numbers bumped in `pubspec.yaml`.
- [ ] All unit and widget tests pass (`flutter test`).
- [ ] Static analysis clean of errors and warnings (`flutter analyze`).
- [ ] Production `.env` or `--dart-define` variables verified against backend gateway.

### Build & Signing Checklist
- [ ] Code obfuscation active (`--obfuscate --split-debug-info`).
- [ ] Android AAB built with upload keystore.
- [ ] iOS IPA signed with valid distribution certificate and provisioning profile.
- [ ] Debug symbols archived for crash de-obfuscation.

### Post-Deployment Checklist
- [ ] Production smoke tests verified on physical device.
- [ ] Staged rollout initialized (e.g., 10% on Google Play Console).
- [ ] Sentry / Crashlytics actively reporting without crash spikes.
- [ ] Rollback binary ready if crash-free rate drops below 99.0%.

---

## 4. Error-Handling & Deployment Troubleshooting

| Deployment Failure | Root Cause | Remediation Procedure |
| :--- | :--- | :--- |
| **Gradle Signing Failure** | Missing or invalid keystore password or path | Verify `key.properties` exists and points to valid keystore file; check CI secret decoding. |
| **CocoaPods Podfile Lock Mismatch** | Podfile modified without running `pod update` | Run `cd ios && pod repo update && pod install` and commit resulting `Podfile.lock`. |
| **Obfuscated Stack Traces Unreadable** | Missing symbol map file in Crashlytics | Upload `build/symbols` map directory to Firebase Console or Sentry CLI. |
| **Post-Release Crash Spike** | Regression introduced in live release | Immediately halt staged rollout in Play Console / App Store Connect; promote previous stable build or deploy hotfix tag. |

---

## 5. Security Guardrails

- **Zero Keystores in Git**: Keystore files (`*.jks`, `*.keystore`), provisioning profiles, and `.env` files must **never** be committed.
- **CI Secrets Isolation**: Use protected CI environment secrets (GitHub Actions Secrets, Vault) with strict branch restrictions (`main` only).
- **Code Obfuscation**: Enforce obfuscation on all public production binaries to raise the bar against reverse engineering and decompilation.

---

## 6. Examples & CI/CD Pipeline

### Complete GitHub Actions Release Workflow (`.github/workflows/release.yml`)
```yaml
name: Production Release

on:
  push:
    tags:
      - 'v*.*.*'

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v3

      - name: Set up Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
          cache: true

      - name: Install Dependencies
        run: flutter pub get

      - name: Run Static Analysis & Tests
        run: |
          flutter analyze
          flutter test

      - name: Decode Android Keystore
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 --decode > android/app/upload-keystore.jks
          echo "${{ secrets.ANDROID_KEY_PROPERTIES }}" > android/key.properties

      - name: Build Android App Bundle (AAB)
        run: |
          flutter build appbundle --release \
            --obfuscate --split-debug-info=build/symbols \
            --dart-define=APP_ENV=production

      - name: Upload Build Artifacts
        uses: actions/upload-artifact@v3
        with:
          name: app-bundle
          path: build/app/outputs/bundle/release/app-release.aab
```
