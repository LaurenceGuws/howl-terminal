# M9-B Cross-Host Evidence Protocol

Architect-owned evidence protocol for `M9` multi-host confidence.

## Purpose

Define reproducible, host-agnostic procedure for proving `C1`/`C2`
conformance claims from `HOST_CONFORMANCE.md`.

## Required Inputs

- frozen contract set:
  - `app_architecture/contracts/HOST_CONFORMANCE.md`
  - `app_architecture/contracts/RUNTIME_API.md`
  - `app_architecture/contracts/MODEL_API.md`
  - `app_architecture/contracts/SNAPSHOT_REPLAY.md`
- canonical fixtures:
  - `docs/review/m9/M9_FIXTURES.md`

## Fixture Ownership Rules

- fixture list is architect-owned.
- fixture additions are additive only.
- fixture edits/removals require explicit breakage justification.

## Conformance Procedure

1. Select fixture set and declare target claim level (`C1` or `C2`).
2. Execute fixture feed/apply checkpoints on each host integration.
3. Capture runtime-observable state snapshots at declared checkpoints.
4. Normalize captures to contract-visible fields only.
5. Compare host A vs host B per fixture and checkpoint.
6. Classify any mismatch with one of:
   - `contract regression`
   - `host integration defect`
   - `insufficient fixture`

## Required Observable Fields

At each checkpoint, capture and compare:

- `rows`, `cols`
- `cursor_row`, `cursor_col`
- visible `cells`
- `cursor_visible`, `auto_wrap`
- `history_count`, `history_capacity`
- `selection` state

When queue boundary is in fixture scope, also capture:

- `queuedEventCount()` before/after apply checkpoints

## Normalization Rules

- compare codepoint/cell data only, not render pipeline state.
- compare deterministic checkpoint states only.
- do not compare host timing/frame cadence.
- do not include platform event-loop metadata.

## Mandatory Validation Baseline

Every conformance evidence slice must include:

- `zig build`
- `zig build test`
- `rg -n "compat[^ib]|fallback|workaround|shim" --glob '*.zig' src`

## Evidence Report Format

For each conformance run:

- fixture id(s)
- claim level (`C1`/`C2`)
- compared hosts
- checkpoint table (pass/fail per observable field)
- mismatch classification (if any)
- exact commit hashes used for both sides

## Stop Conditions

Stop and escalate if any occur:

- required comparison needs fields not exposed by frozen runtime/model contracts.
- mismatch cannot be classified within contract/regression/integration/fixture vocabulary.
- protocol step requires host-specific assumptions not documented here.
