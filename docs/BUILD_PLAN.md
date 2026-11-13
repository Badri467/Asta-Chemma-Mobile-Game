# Development and learning plan

## Scope
Build a complete Ashta Chemma app gradually: 5×5 board, four shells, four pawns each, 2–4 players, Pass & Play, offline rooms, and private online rooms. Confirm family/regional rules before implementing them. Prioritize correct gameplay before visual polish.

Every phase ends with evidence, updated progress, user review where required, and an explicit approval gate. A failed mandatory test keeps that phase open. Do not implement future phases early.

| Phase | Deliverables | Verification and acceptance | What you learn |
|---|---|---|---|
| 0 — Complete Project Planning | These six documents; requirements, architecture, risks, rules questions | Document consistency checks plus user confirmation that the plan is understood and accepted | How a project is broken into small milestones |
| 1 — Development Environment Setup | Inspect Windows and Flutter/Dart/Git/Android Studio/SDK; explain missing installations; configure SDK; create Android Flutter project and display name Ashta Chemma; connect phone | flutter doctor; format/analyze/test starter app; flutter run on Android; user confirms starter app works | SDKs are toolboxes; Flutter builds the screen; Dart supplies instructions; Git tracks changes |
| 2 — Offline Networking Proof of Concept | Host/client test UI; dart:io server; actual local IP and port; manual address entry; bidirectional messages; status, failure, disconnect/reconnect handling; NETWORK_TEST.md | Automated transport/error checks and two real phones exchanging messages with mobile data off and no internet uplink; record device/network setup and reconnect results | A hotspot is a local meeting place; the host address tells guests where to connect |
| 3 — Ashta Chemma Rules Finalization | Confirm all open rules; explicit paths and safe cells; complete configurable rules specification; testable state model | User approves every rule and example; paths checked for all players; model checks where code is introduced; no invented disputed behavior | A precise rule must have an unambiguous expected result |
| 4 — Build the Pass & Play Game | 5×5 board, setup for 2–4 people, scoring, release, legal moves, captures, turns, finish, results, restart/rematch; basic shell/pawn animation after correctness | Unit tests for rules and invalid actions; widget checks; format/analyze/test; physical full matches at 2, 3, and 4 players with no network | State is a match snapshot; an action proposes a change |
| 5 — Offline Multiplayer Integration | Create/join/lobby, names/colors/readiness, host start/roll/action validation, sync, duplicate protection, reconnection/state recovery, rematch/exit | Transport/session tests; 2-, 3-, and 4-phone full matches without internet; wrong identity, stale/duplicate/invalid actions; disconnect/rejoin; safe host-loss behavior | One referee prevents phones disagreeing |
| 6 — Online Multiplayer | Explain backend options/costs; prefer Dart rules reuse; authoritative server, private room codes, timeouts/security, reconnection, cleanup, rematches, backend run instructions | Full match across different internet connections; server validation and cleanup tests; reconnect/duplicate tests; offline and Pass & Play regression tests | A hosted server is a referee reachable from other networks |
| 7 — UI/UX Improvements | Home/mode flows, board/shell/pawn polish, sound, optional vibration, Telugu/English, tutorial, connection/errors/results, accessibility, performance; dark/light if practical | Widget/localization checks; small/large screens and text sizes; accessibility and animation/performance review on phones; all three modes still playable | Clear feedback helps players understand every action |
| 8 — Testing and Android Release | Device/version matrix, bug fixes, signed release APK, AAB explanation, install guide, optional Play Store preparation | Full automated suite and analysis; release-build installation; gameplay/invalid moves/shells/disconnect/reconnect across modes, phone brands and Android versions; no major untested feature labeled ready | Debug and release builds differ; signing identifies the publisher |

## Planned screens, introduced only when needed
Phase 2: temporary connectivity test screen.
Phase 4: minimal home, player/pass-and-play setup, board, pause/resume, results, restart/rematch.
Phase 5: mode selection extensions, offline create/join/lobby, connection-loss/reconnect UI.
Phase 6: online create/join/lobby and online recovery.
Phase 7: splash/welcome polish, How to Play, settings, language/audio/haptic controls and refined existing screens.

## Testing strategy
For Dart/Flutter changes, format changed code, run flutter analyze and flutter test, then run the app when meaningful. Test rules independently of screens: scoring 0→8, 1→1, 2→2, 3→3, 4→4; releases; legal/illegal moves; captures; safe cells; extra turns; finishing. Expected disputed outcomes must come from the approved profile. Inject deterministic shell outcomes in tests.

Test protocol parsing, unsupported versions, identity, turn ownership, duplicate actions, stale revisions, malformed messages, timeouts, reconnection and snapshot recovery. Compare all clients' revisions/state after each action. Unit tests cannot prove Android hotspot behavior.

Physical test records must include device models, Android versions, connection topology, internet/mobile-data status, steps, expected/actual outcomes, and tester confirmation. Mark unavailable devices and untested combinations as limitations. Test online players on genuinely different internet connections. Release testing repeats essential checks on the signed build.

## Risks and planned responses
- Rule variations: obtain explicit choices in Phase 3 and preserve a versioned profile.
- Hotspot routing/client isolation and device differences: test early in Phase 2; document supported setups and manual Wi-Fi alternatives.
- Android network permission/security behavior varies by target SDK: verify current official guidance during implementation and test release builds too.
- Android may suspend a background host: define pause/disconnect behavior and test lock/background transitions; do not promise uninterrupted hosting.
- Host loss: preserve a safe paused/ended state; automatic host migration is out of scope.
- Duplicate/delayed requests: authority, action IDs, revisions, and reconnect snapshots.
- Local networks are not inherently trusted: validate all input and use session-scoped rejoin credentials; choose transport protection based on current platform constraints.
- Online service availability/cost: explain hosting and publishing costs before adoption; no paid service commitment in planning. Public online play needs reachable infrastructure.
- Limited physical devices: keep corresponding acceptance checks pending until tested.
- Telugu readability, color vision and small screens: test labels, text scaling, contrasting pawn markers and touch targets.
- Assets: track licenses and attribution; use original art/audio where possible.

## Beginner workflow
For every approved phase: explain the goal and files, implement a small step, check it, explain the result, provide exact manual instructions, record evidence, then stop for approval. No installation or terminal command is needed to review Phase 0.
