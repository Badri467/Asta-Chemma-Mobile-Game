# Phase 1 setup guide

The installed tools are Flutter 3.44.4, Dart 3.12.2, Git 2.45.1, Android Studio and Android SDK 36.0.0 on Windows 11. Dart comes with Flutter. The SDK is the toolbox used to build Android applications.

## Finish Android setup manually
1. Open Android Studio. On its welcome screen choose More Actions > SDK Manager (inside a project: Tools > SDK Manager).
2. Select SDK Tools, check Android SDK Command-line Tools (latest), click Apply, review the installation dialog and finish installation.
3. Open PowerShell. Run `flutter doctor --android-licenses`. Read each license and accept if you agree.
4. Run `flutter doctor -v` to recheck the Android toolchain. The Visual Studio warning concerns Windows desktop development and is not required for this Android project.

Official guide: https://docs.flutter.dev/platform-integration/android/setup

## Connect your phone
1. On the phone, open Settings > About phone and tap Build number seven times. Some brands put Build number inside Software information. Enter the phone PIN if prompted.
2. Open Developer options and enable USB debugging.
3. Connect the phone with a USB data cable, unlock it, and accept the USB debugging prompt for your computer.
4. In PowerShell run `flutter devices`. An Android device should appear. If absent, try a data-capable cable, another USB port, and the manufacturer's Windows USB driver as appropriate.

## Run and check the starter
In PowerShell:

```powershell
Set-Location 'C:\Users\badri\Downloads\Offline Games APP\ashta_chemma'
flutter doctor -v
flutter devices
flutter analyze
flutter test
flutter run
```

Doctor checks installed tools; devices lists available targets; analyze checks source code; test runs the starter counter test; run builds and launches the app. If asked to select a device, select your Android phone. Initial builds require internet to download build dependencies even though the future game supports offline play.

On the phone, verify the title is Ashta Chemma, the counter starts at 0, and tapping + twice shows 2. Check the launcher display name is Ashta Chemma. Report your phone model, Android version, whether this worked, and any full error output. Press q in the run terminal when finished.

## Main files
- lib/main.dart: standard Flutter counter screen; setState tells Flutter to redraw after the number changes.
- test/widget_test.dart: automatically taps the counter and checks its result.
- android/app/src/main/AndroidManifest.xml: Android app declaration and launcher name.
- pubspec.yaml: package name and standard Flutter dependencies.

The default com.example.ashta_chemma application ID is for development; choose a permanent release ID before publishing. No game or networking features exist yet.

## New Android CLI warning
If the license command says sdkmanager is deprecated and --licenses is no longer needed, do not repeat it. Flutter 3.44.4 still parses the older license messages and may report status unknown. The command-line tools installation is now detected. Connect the phone next; an actual Android build is still required to verify readiness. This warning alone does not prove all build dependencies or licenses are ready.
