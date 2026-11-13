# Phase 2 — Offline network verification

## What this build does
One phone hosts a dart:io WebSocket server on port 4040. A second phone connects to the host's displayed IPv4 address. Both can send text, stop, and reconnect. This is a transport experiment, not game multiplayer. No new dependencies were added.

The service is in lib/networking/local_link.dart; Flutter controls are in lib/ui/network_test_screen.dart. main.dart opens the test screen. JSON messages have version 1, type text, and a text field. Input is validated; logs retain at most 100 entries. Send means locally queued, not acknowledged delivery. Verify Received on the other phone.

## Install on both phones
Use PowerShell in:

```powershell
Set-Location 'C:\Users\badri\Downloads\Offline Games APP\ashta_chemma'
flutter devices
```

Connect each phone by USB with debugging authorized. Run `flutter run -d DEVICE_ID`, replacing DEVICE_ID with that phone's ID from the list. Alternatively transfer build/app/outputs/flutter-apk/app-debug.apk to the second phone and open it to install, allowing that transfer app to install the APK if Android asks. This is a development APK. Installation/downloads may use internet; the actual test below must not.

## Test A — No-internet hotspot (mandatory)
1. Record both phone models and Android versions below.
2. Turn mobile data OFF on both phones. On Phone A, turn off any upstream Wi-Fi connection/Wi-Fi sharing, then enable its hotspot. Do not use airplane mode if it prevents hotspot operation. Disconnect USB cables for the offline test.
3. Connect Phone B to Phone A's hotspot. Accept Keep connected/Use without internet if prompted. Disable any automatic switch to mobile data. Check neither phone can load a new, uncached webpage.
4. Keep both apps open and screens awake. On A tap Start host on this phone. Note port 4040 and the listed IP addresses. These come from real network interfaces, not a fixed hotspot assumption.
5. On B enter A's hotspot IPv4 address (numbers only, no ws:// prefix) and matching port. Tap Connect / reconnect to host. If A shows multiple addresses, use the hotspot interface; try the other listed address if uncertain. Never enter B's own address or 127.0.0.1.
6. Both should show Connected. Send `Hello from A` on A and verify Received on B. Send `Hello from B` on B and verify Received on A.
7. On B tap Stop / disconnect. A should report guest disconnected while remaining available. On B tap Connect / reconnect to host and repeat both messages.
8. Turn B's Wi-Fi off. Allow about 10–15 seconds for heartbeat timeout (longer if Android suspends the app). Restore Wi-Fi, reconnect to A's hotspot, and tap Connect / reconnect. Verify both directions again.
9. Stop hosting on A. B should show disconnected. Restart host, check the current IP/port, and reconnect B.

## Test B — Errors and alternate Wi-Fi
- While disconnected, enter `not-an-ip`: the app must show an error and stay usable.
- Enter the correct host IP but an unused port: connection should fail, normally within 10 seconds. Restore the real port and retry successfully.
- If hotspot clients cannot reach the host, reverse host/guest phone roles. Then optionally try a Wi-Fi router with its internet uplink unplugged. Record each result separately; a router pass does not prove hotspot support.
- Try backgrounding/locking the host and record actual behavior; uninterrupted background hosting is not promised.

## Evidence record
Status: VERIFIED for the Phase 2 milestone by user on 2026-11-13. Both-way messaging without internet and all four final failure-recovery checks passed. Device coverage is limited to this pair.

| Item | Result |
|---|---|
| Phone A model / Android | RMX3771 / Android 15 (previous device verification) |
| Phone B model / Android | Vivo T4 5G / Android 15 |
| Hotspot provider and app host | Phone A (RMX3771); Phone B joins its hotspot |
| Host IP / port | IP not recorded; port 4040 confirmed through final test |
| Mobile data off on both | PASS — user confirmed |
| No Wi-Fi/internet uplink on hotspot provider | PASS — user confirmed Phone A Wi-Fi off, hotspot on, mobile data off on both |
| A → B message | PASS — user confirmed |
| B → A message | PASS — user confirmed |
| Manual disconnect/reconnect + messages | PASS — initial reconnect and subsequent recovery/message checks confirmed |
| Wi-Fi loss detected + reconnect | PASS — user confirmed disconnect detection, reconnect and message delivery |
| Host stop/restart + reconnect | PASS — user confirmed restart, reconnect and message delivery |
| Incorrect address/port + recovery | Wrong port 4041 failed; restoring 4040 and sending passed. Malformed address covered by automated test only |
| Tester confirmation | User confirmed initial test and all four final checks worked as expected on 2026-11-13 |

## Automated coverage
Tests use real loopback sockets on the development computer for bidirectional text, disconnect/reconnect, host stop, invalid address, refused connection, malformed JSON, invalid outgoing text, and extra guest rejection. A widget test checks initial controls. These do not prove Android hotspot behavior or Wi-Fi-loss timing.

## Platform and security scope
The installed Flutter targets API 36. Android INTERNET permission is in the main manifest for all build modes. Cleartext traffic is allowed for this local ws:// experiment. This is an unauthenticated, unencrypted, two-phone test on a trusted local network. Do not expose its port to the internet. Session authentication, action IDs/revisions and game authority belong to Phase 5; online secure transport to Phase 6.

Android 17 apps targeting API 37 introduce mandatory local-network permission handling; revisit that before raising the target SDK. No automatic hotspot setup/discovery, host migration, message history replay, or automatic reconnect is promised. Guest reconnect is manual; use the refreshed IP if the hotspot changes address. Background suspension and client isolation vary by device.

References checked during implementation:
- https://api.dart.dev/dart-io/WebSocket-class.html
- https://developer.android.com/privacy-and-security/local-network-permission
