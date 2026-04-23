# Howl Terminal Active Queue

Mode: dual-engineer execution.

Milestone lane: `M9` Multi-Host Confidence.

This queue is execution-only. No planning/scoping reprioritization.

## Read Order

1. `app_architecture/authorities/M9_FOUNDATION.md`
2. `app_architecture/contracts/HOST_CONFORMANCE.md`
3. `docs/review/m9/M9_B_EVIDENCE_PROTOCOL.md`
4. `docs/review/m9/M9_FIXTURES.md`
5. `app_architecture/contracts/RUNTIME_API.md`
6. `app_architecture/contracts/SNAPSHOT_REPLAY.md`

## Ticket M9-E1: Conformance Capture Helper + Checkpoint Tests

Status: `ready`

Target files:

- `src/test/relay.zig`

Allowed change type:

- add test helper(s) and tests only.
- helper must capture contract-visible fields used in M9 protocol checkpoints.

Required coverage:

- deterministic capture of required observable fields (`rows`, `cols`, cursor,
  mode flags, history count/capacity, selection).
- assertions proving encode interleaving does not alter capture state.
- assertions proving feed/apply checkpoint boundaries are captured correctly.

Explicit non-goals:

- no production code changes.
- no API signature changes.
- no host/platform policy logic.

Validation commands:

- `zig build`
- `zig build test`
- `rg -n "compat[^ib]|fallback|workaround|shim" --glob '*.zig' src`

Stop conditions:

- any capture requirement needs runtime/model API expansion.
- helper design requires modifying frozen `M1-M8` behavior.

## Ticket M9-E2: Fixture-Class Conformance Evidence Tests

Status: `ready`

Target files:

- `src/test/relay.zig`

Allowed change type:

- add integration tests only, mapped to `M9-FX-001..009` classes.

Required coverage:

- representative tests for text/utf8, cursor+erase, mode toggles,
  history, selection, reset boundaries, encode interleave, snapshot stability.
- test naming includes fixture ids for traceability.
- each added test asserts checkpoint fields defined by M9 protocol.

Explicit non-goals:

- no production code changes.
- no new runtime semantics.
- no contract rewrites.

Validation commands:

- `zig build`
- `zig build test`
- `rg -n "compat[^ib]|fallback|workaround|shim" --glob '*.zig' src`

Stop conditions:

- fixture class cannot be represented without changing frozen behavior.
- mismatch indicates contract ambiguity between `HOST_CONFORMANCE.md` and runtime contracts.

## Reporting Contract

Each response must include:

- `#DONE`
- `#OUTSTANDING`
- commits (hash + subject)
- validation results
- files changed (`git show --name-status`)

## Guardrail

Do not execute M9 freeze/handoff work from this queue.

`M9-D` freeze and `M10` handoff remain architect-owned.
