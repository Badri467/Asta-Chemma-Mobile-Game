# Planned architecture

This is a design, not implemented code. Create each component only in its approved phase.

## Responsibilities
1. UI: Flutter widgets/CustomPainter show the board, legal choices, turns and connection feedback. Start with setState/ValueNotifier.
2. Rules: pure Dart takes an immutable state, an action, and a confirmed rules profile; returns a new state or a validation error. It does not access widgets, sockets, or random generators.
3. Session: controller owns players, match lifecycle and turns; generates authoritative shell outcomes, calls rules, and distributes accepted state.
4. Transport: moves versioned messages over local WebSockets, then internet WebSockets. It does not decide legal moves.

Think of UI as the board you see, rules as the rulebook, session as the referee, and transport as the messenger. Pass & Play calls the same rules locally without a server connection.

## Proposed folders (future, not scaffolded)
```text
ashta_chemma/
  README.md
  AGENTS.md
  docs/
  android/                 # Phase 1 generated Android configuration
  lib/
    main.dart              # Phase 1 starter entry point
    game/                  # Phase 3 model; Phase 4 pure Dart rules
    session/               # Local controller in Phase 4; network session in Phase 5
    networking/            # Phase 2 prototype, refined in Phase 5
    ui/                    # Screens/widgets as their phases require
    settings/              # Preferences when settings are introduced
  test/                    # Tests added with relevant behavior
  integration_test/        # Device flow tests when needed
  server/                  # Phase 6 only, after backend decision
  assets/                  # Licensed/original art/audio when used
```

If a Dart backend is selected, extract the proven pure Dart rules/protocol into a shared package during Phase 6. Do not duplicate rule implementations. Avoid premature package scaffolding.

## State and rules profile
Plan stable player/pawn identifiers, pawn progress along explicit player paths, active player, turn/throw stage, current shell result, finish status and profile version. The final model and legal action set depend on Phase 3 choices. Configurable data will describe safe cells, paths, release costs, extra throws, captures, inner entry and winning rules. Unknown choices stay unresolved, not defaulted silently.

## Local multiplayer plan
In Phase 2 the user manually enables a hotspot or joins an existing local Wi-Fi network. The host starts dart:io HttpServer/WebSocket handling, shows its actual local address and selected port, and guests enter that address. Handle multiple interfaces and unreachable addresses clearly; do not hardcode a hotspot IP. Automatic discovery and hotspot creation are not initial requirements.

In Phase 5 the host validates membership, readiness, capacity, turn ownership and every action. Only the host generates cowrie outcomes. Guests send intent (for example, request throw or select pawn), never an asserted winning state or trusted shell result. UI animations follow accepted state.

## Proposed shared protocol
Versioned JSON envelopes will carry message type, room/session identity, action ID where applicable, and state revision. Authenticate a connection to a server-assigned player identity; do not trust a player ID simply because it appears in JSON.

Planned message categories: join/welcome, ready/start, action request, accepted state snapshot, rejection, heartbeat, reconnect, leave and rematch. Refine concrete schemas in Phase 5 after the Phase 2 proof. Start with complete snapshots because this game's state is small.

Authority processes requests serially, checks expected revision, rejects invalid/stale actions with recovery guidance, and increments revision for accepted state changes. Scope action IDs to a match/session and retain enough deduplication history for retries. Repeated accepted requests must not roll or move twice. Clients ignore older snapshots and request authoritative state when needed.

Rejoin uses a session-scoped credential and restores authoritative state, not a guest's cached board. Bound message size, parse defensively, and validate schema/protocol versions. Timeout/rejoin windows are configurable decisions for integration. Define guest absence/pause behavior before Phase 5 acceptance. Host departure safely pauses or ends the match; no host migration is promised.

## Online plan
Phase 6 will select the simplest suitable backend after reviewing current options and costs. Prefer a Dart authoritative server to reuse the tested rules. Use secure internet WebSockets, unpredictable room/rejoin credentials, input/rate limits, idle room cleanup, connection timeouts and controlled capacity. Room codes locate rooms; they must not allow a guest to impersonate another player. Document development startup and public hosting separately. Test reconnect guarantees explicitly; server restart persistence is a decision to document, not an assumed capability.

Offline and local controllers must not depend on login, online room availability, or backend startup. Nearby Connections is a later investigation, not current implementation.
