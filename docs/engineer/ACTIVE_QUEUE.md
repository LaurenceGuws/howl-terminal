# Howl Terminal Active Queue

Mode: dual-engineer execution.

Milestone lane: `M10` Best-in-Class Embedded Engine.

This queue is execution-only. No planning/scoping reprioritization.

## Read Order

1. `app_architecture/authorities/M10_FOUNDATION.md`
2. `app_architecture/contracts/QUALITY_DOCTRINE.md`
3. `docs/review/m10/M10_B_EVIDENCE_PROTOCOL.md`
4. `docs/review/m10/M10_STRESS_FIXTURES.md`
5. `app_architecture/contracts/HOST_CONFORMANCE.md`
6. `app_architecture/contracts/RUNTIME_API.md`

## Ticket M10-E1: Stress/Soak Evidence Matrix Tests

Status: `ready`

Target files:

- `src/test/relay.zig`

Allowed change type:

- add test helper(s) and tests only.
- implement bounded stress/soak loops aligned to `M10-FX-001..006` classes.

Required coverage:

- deterministic stress loops for feed/apply and reset boundaries.
- soak-style repeated checkpoint assertions (stable invariants over many iterations).
- explicit evidence-class tags in test names (`E1`, `E2`).

Explicit non-goals:

- no production code changes.
- no API signature changes.
- no host/platform policy logic.

Validation commands:

- `zig build`
- `zig build test`
- `rg -n "compat[^ib]|fallback|workaround|shim" --glob '*.zig' src`

Stop conditions:

- evidence run requires runtime/model API expansion.
- stress/soak loop cannot be made deterministic with frozen contracts.

## Ticket M10-E2: Drift Detection Regression Tests

Status: `ready`

Target files:

- `src/test/relay.zig`

Allowed change type:

- add integration tests only for drift checkpoints (`E3` class).

Required coverage:

- repeated checkpoint capture over mixed operations with strict invariants.
- drift checks across selection/history/mode/encode interleavings.
- mismatch assertions map to contract-visible fields only.

Explicit non-goals:

- no production code changes.
- no new runtime semantics.
- no contract rewrites.

Validation commands:

- `zig build`
- `zig build test`
- `rg -n "compat[^ib]|fallback|workaround|shim" --glob '*.zig' src`

Stop conditions:

- drift proof requires hidden/non-contract state.
- mismatch indicates unresolved contract ambiguity requiring architect decision.

## Reporting Contract

Each response must include:

- `#DONE`
- `#OUTSTANDING`
- commits (hash + subject)
- validation results
- files changed (`git show --name-status`)

## Guardrail

Do not execute M10 freeze-cadence or milestone handoff work from this queue.

`M10-D` remains architect-owned.
