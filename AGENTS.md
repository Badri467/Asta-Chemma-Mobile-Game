# Project instructions

Read this file and docs/PROGRESS.md at the start of every session, before changes.

The user's latest request replaces the earlier Offline Multiplayer Games roadmap. Build only Ashta Chemma, project name ashta_chemma, Android first, Flutter/Dart. Follow the exact phases in docs/BUILD_PLAN.md.

## Phase gates
- Work on exactly one approved phase. Roadmap entries are not approval.
- Announce `STARTING PHASE X: [PHASE NAME]`, objectives, learning topics, files, and verification before work.
- Explain small steps and report their completion. Modify files directly when possible.
- Create only current-phase files and essential shared configuration. Future architecture below is a plan, not authorization to scaffold it.
- Run applicable checks and fix reproduced failures. Never claim device tests passed without evidence and user confirmation.
- If mandatory checks or user review remain pending, report `PHASE X — AWAITING VERIFICATION`.
- Only after verification, report `PHASE X COMPLETED SUCCESSFULLY`, implemented features, files, tests/results, manual results, issues, limitations, and lessons.
- Update docs/PROGRESS.md, preview the next phase, ask `Phase X is complete. Shall I start Phase X+1?`, and stop. Explicit user approval is required.
- Phase 0 is documentation only. Do not install Flutter, generate the app, or implement game/network code in Phase 0.

## Implementation constraints
- Standard Flutter widgets/CustomPainter; pure Dart rules independent of UI and networking.
- Initially use setState/ValueNotifier, dart:io WebSockets; add shared_preferences only when needed.
- No Flame, Firebase, complex state management, or cloud infrastructure without a current-phase need.
- Authoritative controller generates shell results and validates actions. Host is authority offline; server is authority online.
- Version JSON messages; validate identity, legal actions, duplicates, and state revisions.
- Keep offline modes independent of online services. Reuse rules and protocol where practical.
- Confirm disputed rules with the user in Phase 3; never substitute Ludo rules. Chemma releases one pawn; Ashta releases two.
- Explain costs before introducing hosting or publishing services. Use original or appropriately licensed assets.
- No other games, automatic host migration, or Nearby Connections implementation in the current roadmap.

## Teaching and verification
Use simple language. Give Windows PowerShell commands and exact working directories; explain what commands do. Identify manual steps clearly. Relevant code phases use dart format, flutter analyze, flutter test, and flutter run when appropriate. Preserve physical test evidence separately from automated results. Never describe untested features as production-ready.

Maintain README.md, this file, docs/BUILD_PLAN.md, docs/ARCHITECTURE.md, docs/PROGRESS.md, and docs/ASHTA_CHEMMA_RULES.md. Create docs/NETWORK_TEST.md when Phase 2 begins. Record current phase, completed work, checks, verification, issues, manual tasks, next phase, and explicit approval status.
