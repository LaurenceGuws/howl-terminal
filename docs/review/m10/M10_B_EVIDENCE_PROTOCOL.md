# M10-B Evidence Expansion Protocol

Architect-owned protocol for M10 quality evidence expansion.

## Purpose

Define reproducible procedure for stress, soak, and drift evidence that extends
frozen M1-M9 correctness and M10 doctrine requirements.

## Required Inputs

- `app_architecture/contracts/QUALITY_DOCTRINE.md`
- `app_architecture/contracts/HOST_CONFORMANCE.md`
- `app_architecture/contracts/RUNTIME_API.md`
- `app_architecture/contracts/SNAPSHOT_REPLAY.md`
- `docs/review/m10/M10_STRESS_FIXTURES.md`

## Evidence Classes

M10 evidence runs must declare one or more classes:

- `E1` stress: bounded high-intensity deterministic operation bursts
- `E2` soak: long-run repeatability over stable fixture loops
- `E3` drift: repeated checkpoint comparison over time for state stability

## Fixture Ownership

- fixture catalog is architect-owned.
- fixture ids are immutable.
- additions are additive only.
- fixture removal requires explicit breakage decision.

## Procedure

1. Choose evidence class (`E1`/`E2`/`E3`) and fixture ids.
2. Execute fixture loop with declared iteration count/checkpoint cadence.
3. Capture contract-visible checkpoints only.
4. Compare checkpoints against declared invariants.
5. Classify outcome:
   - `pass`
   - `regression`
   - `insufficient fixture`

## Required Checkpoint Fields

- `rows`, `cols`
- `cursor_row`, `cursor_col`
- `cursor_visible`, `auto_wrap`
- visible-cell state representation
- `history_count`, `history_capacity`
- `selection`
- `queued_event_count` at boundary checkpoints

## Reproducibility Rules

- every run declares iteration count and fixture set.
- every claim ties to exact commit hash.
- no host timing/frame assumptions in quality pass/fail criteria.
- no hidden environment switches allowed for evidence validity.

## Mandatory Validation Baseline

Every evidence slice must include:

- `zig build`
- `zig build test`
- `rg -n "compat[^ib]|fallback|workaround|shim" --glob '*.zig' src`

## Report Format

- evidence class (`E1`/`E2`/`E3`)
- fixture ids
- iteration/checkpoint config
- pass/fail table by checkpoint invariant
- mismatch classification (if any)
- commit hash

## Stop Conditions

Stop and escalate if any occur:

- evidence run requires runtime/model API changes to observe required fields.
- stress/soak result is not reproducible from repo-local procedure.
- drift mismatch cannot be mapped to contract-visible invariants.
