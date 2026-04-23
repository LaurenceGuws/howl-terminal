# Howl Terminal Active Queue

Execution-only queue for the current engineer loop.

## Ownership

- Architect writes and replaces this file every loop.
- Engineer executes only listed tickets.
- Engineer does not plan, redesign, or expand scope.

## Scope Anchor

- Scope authority: `app_architecture/authorities/SCOPE.md`
- Milestone authority: `app_architecture/authorities/MILESTONE.md`
- Architect workflow: `docs/architect/WORKFLOW.md`

## Current Loop

**Status:** M4 complete and frozen. Entering post-M4 validation loop.

M1/M2/M3/M4 are frozen. Do not reopen parser/screen/history/selection/input behavior unless a regression test exposes a direct bug.

## Post-M4 Validation Checklist

### M4 Freeze Evidence

Before proceeding to M5 planning, validate:

1. **Build and Test Baseline**
   - `zig build` completes without warnings
   - `zig build test` passes all tests
   - `rg -n "compat[^ib]|fallback|workaround|shim" --glob '*.zig' src` returns clean
   - Working tree is clean (no uncommitted changes)

2. **M4 Contract Alignment**
   - INPUT_CONTROL.md: documents all implemented keyboard encoding (printable, special, cursor, extended, function keys) and modifier support
   - MODEL_API.md: documents Key/Modifier constants including F1-F12
   - RUNTIME_API.md: encodeKey and encodeMouse signatures and guarantees documented
   - Closeout tests exist in src/test/relay.zig demonstrating representative M4 coverage

3. **Milestone State**
   - MILESTONE.md: M4 checklist fully marked [x]
   - MILESTONE_PROGRESS.md: M4 marked `done` with descriptive scope summary
   - Commit history: M4-A, M4-B1, M4-B2, M4-B3, M4-B4 commits clean and tagged

4. **No Overclaims**
   - Mouse event reporting: explicitly documented as future (not implemented)
   - Mode-dependent behaviors (paste mode, application keypad): explicitly out of M4 scope
   - Function key compatibility matrix: explicitly documented as post-M4
   - Host integration: documented as M5+ scope

## Next Phase Handoff

After M4 freeze validation passes, architect reviews:

1. Whether M5 (Runtime Interface) scope is clear from MILESTONE.md and ready to queue
2. Whether any M1-M4 contracts need refresh before opening M5
3. Whether infrastructure/test patterns established in M4 are sufficient for M5 expansion

## Guardrails

- No compatibility/fallback/workaround paths.
- No app/editor/platform/session/publication imports in parser/event/screen/model/runtime lanes.
- No enhancements, optimizations, or refactors outside the milestone queue.
- Engineer does not plan or propose tickets; architect controls queue content.
