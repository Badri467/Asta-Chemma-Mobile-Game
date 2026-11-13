# Ashta Chemma (అష్టా చెమ్మా)

Android-first traditional 5×5 board game for 2–4 players, using four cowrie shells and four pawns per player. The project currently contains the Flutter Android starter and planning documents.

## Planned modes
- Pass & Play: friends share one phone; no network required.
- Offline Multiplayer: separate phones share local Wi-Fi or a hotspot; no internet required.
- Online Multiplayer: friends connect over the internet through an authoritative server.

Offline and Pass & Play must remain independent of the online backend. The current project contains only Ashta Chemma. Other games are future work requiring separate approval.

## Read in this order
1. [Build plan](docs/BUILD_PLAN.md): phases, learning goals, and acceptance tests.
2. [Architecture](docs/ARCHITECTURE.md): how the parts will work together.
3. [Rules](docs/ASHTA_CHEMMA_RULES.md): confirmed choices and open questions.
4. [Progress](docs/PROGRESS.md): what is done and what needs review.

## Current milestone
Phases 1 and 2 are complete. The user verified two-phone messaging without internet and recovery after Wi-Fi loss, host restart, and a wrong port on RMX3771 and Vivo T4 5G, both Android 15. Read [the network test guide](docs/NETWORK_TEST.md) for evidence and repeatable steps. No game code exists yet.

## Review instructions
Phase 3 — Ashta Chemma Rules Finalization — awaits explicit approval. The user's selected gavva animation image references are recorded in the progress document for Phase 4.

## Future command location
To work with the app, open PowerShell and enter:

```powershell
Set-Location 'C:\Users\badri\Downloads\Offline Games APP\ashta_chemma'
```

Checks include `dart format lib test` (consistent code layout), `flutter analyze` (find code problems), `flutter test` (automated checks), and `flutter run` (launch on a selected phone).
