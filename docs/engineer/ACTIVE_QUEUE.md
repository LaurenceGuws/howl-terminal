# Howl Terminal Active Queue

Execution-only queue for the current engineer loop.

## Ownership

- Architect writes and replaces this file every loop.
- Engineer executes only listed tickets.
- Engineer does not redesign scope during execution.

## Scope Anchor

- Milestone authority: `app_architecture/authorities/MILESTONE.md`
- M6 authority: `app_architecture/authorities/M6_FOUNDATION.md`
- Runtime contract: `app_architecture/contracts/RUNTIME_API.md`
- Model contract: `app_architecture/contracts/MODEL_API.md`
- Architect workflow: `docs/architect/WORKFLOW.md`

## Current Loop

**Status:** M6-A complete. Execute M6-B and M6-C.

M1-M5 are frozen. Do not reopen parser/screen/history/selection/input/runtime
semantics unless an M6 test exposes a direct regression.

M6-A: Contract closure and snapshot surface baseline are complete.
- SNAPSHOT_REPLAY.md published with payload scope, replay framing, non-goals, breakage rules.
- Snapshot API implemented: src/model/snapshot.zig + Engine.snapshot().
- Parity and split-feed tests included in src/test/relay.zig.

## M6-B and M6-C Execution Order (Do Not Reorder)

### M6-B: Snapshot Surface Hardening

- Target files:
  - `src/model/snapshot.zig`
  - `src/runtime/engine.zig`
  - `app_architecture/contracts/SNAPSHOT_REPLAY.md` (docstring references only)
- Allowed change type: additive docstrings and API clarity only.
- Required output:
  - add comprehensive docstrings to EngineSnapshot methods aligned to M6-A contract.
  - ensure snapshot() method documentation covers determinism guarantees.
  - ensure all public snapshot API is documented with contract references.
- Non-goals:
  - no API signature changes.
  - no new tests (test coverage added in M6-A2).
  - no persistence/restore logic.
- Stop conditions:
  - if docstrings suggest API changes needed, pause and flag for M6-C design review.

### M6-C: Replay Evidence Matrix

- Target files:
  - `src/test/relay.zig`
  - `app_architecture/contracts/SNAPSHOT_REPLAY.md` (validation notes only)
- Allowed change type: additive tests for replay/parity scenarios.
- Required output:
  - add tests validating reset/clear/snapshot boundary behavior (M6-A contract section).
  - add tests for snapshot/replay invariants across history eviction scenarios.
  - add cross-scenario parity tests (direct pipeline vs runtime engine vs split-feed).
  - validate snapshot determinism across mode changes (cursor_visible, auto_wrap toggle).
- Non-goals:
  - no new snapshot API methods.
  - no persistence/file format.
  - no performance optimization.
- Stop conditions:
  - if tests reveal snapshot/replay divergence from M1-M5 contracts, stop and report root cause.

## Engineer Report Format

- `#DONE` ticket IDs
- `#OUTSTANDING` ticket IDs
- commit hash + subject
- validation results
- files changed

## Mandatory Validation Per Ticket

- `zig build`
- `zig build test`
- `rg -n "compat[^ib]|fallback|workaround|shim" --glob '*.zig' src`

### M6-D: Freeze Evidence and M7 Handoff

- Target files:
  - `app_architecture/authorities/MILESTONE.md` (M6 checklist final marks)
  - `app_architecture/authorities/M6_FOUNDATION.md` (freeze notes only)
  - `docs/architect/MILESTONE_PROGRESS.md` (M6 status to done, prepare M7 scope)
  - `docs/engineer/ACTIVE_QUEUE.md` (replace with M7 planning queue)
- Allowed change type: status documentation and M7 planning queue only.
- Required output:
  - mark M6-B and M6-C complete in checklist.
  - mark M6 done in milestone progress.
  - document M6 freeze state in M6_FOUNDATION.md notes.
  - publish M7 planning queue with M7 scope definition.
- Non-goals:
  - no code changes.
  - no M7 implementation (planning tickets only).

## Guardrails

- No compatibility/fallback/workaround/shim paths.
- No host/platform/renderer lifecycle imports in runtime/model/event/screen lanes.
- No scope expansion into M6-D during M6-B/M6-C execution.
