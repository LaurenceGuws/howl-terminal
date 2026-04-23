# Howl Terminal Active Queue

Mode: dual-engineer execution.

Milestone lane: `M8` Host Integration Readiness.

This queue is execution-only. No planning/scoping reprioritization.

## Read Order

1. `app_architecture/authorities/M8_FOUNDATION.md`
2. `docs/review/m8/M8_SEAM_AUDIT.md`
3. `app_architecture/contracts/RUNTIME_API.md`
4. `app_architecture/contracts/MODEL_API.md`
5. `app_architecture/contracts/SNAPSHOT_REPLAY.md`

## Ticket M8-E1: Runtime API Freeze Guard Matrix

Status: `ready`

Target files:

- `src/test/relay.zig`
- `src/root.zig` (tests only)

Allowed change type:

- add or tighten tests only.
- lock first-host integration surface and non-mutation guarantees.

Required coverage:

- root runtime export and stable method-family presence checks.
- signature/const-read guarantees for `screen`, `history*`, `selectionState`, `snapshot`.
- `encodeMouse` placeholder behavior asserted as deterministic empty output and non-mutating.

Explicit non-goals:

- no runtime/model/parser/event/screen behavior changes.
- no API renames/removals/signature changes.
- no contract/authority rewrites in this ticket.

Validation commands:

- `zig build`
- `zig build test`
- `rg -n "compat[^ib]|fallback|workaround|shim" --glob '*.zig' src`

Stop conditions:

- any test expectation requires API or behavior change to pass.
- any gap found that cannot be closed with tests-only changes.

## Ticket M8-E2: Mixed Host-Loop Readiness Evidence

Status: `ready`

Target files:

- `src/test/relay.zig`

Allowed change type:

- add integration/parity tests only for first-host usage patterns.

Required coverage:

- feed/apply/reset/resetScreen interleavings preserve frozen boundaries.
- selection/history/snapshot read seams remain stable under mixed host-loop sequences.
- encode operations interleaved with runtime mutation paths show zero side effects.

Explicit non-goals:

- no production code changes.
- no platform-specific behavior or host lifecycle policy.
- no new queueing/mode semantics.

Validation commands:

- `zig build`
- `zig build test`
- `rg -n "compat[^ib]|fallback|workaround|shim" --glob '*.zig' src`

Stop conditions:

- test indicates real contract ambiguity between `M8_FOUNDATION` and runtime contracts.
- proof requires changing frozen `M1-M7` behavior.

## Reporting Contract

Each response must include:

- `#DONE`
- `#OUTSTANDING`
- commits (hash + subject)
- validation results
- files changed (`git show --name-status`)

## Guardrail

Do not execute closeout/freeze work from this queue.

`M8-D` freeze evidence and `M9` handoff remain architect-owned.
