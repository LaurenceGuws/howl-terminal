# M9 Multi-Host Confidence Foundation

`M9_FOUNDATION` is architect-owned authority for `M9`.

## Start Point (Locked Baseline)

`M9` starts from frozen `M1-M8` behavior and evidence.

Locked baseline:

- parser/event/screen/history/selection/input/runtime/snapshot contracts are frozen.
- `M8` host-readiness contract and seam audit are frozen.
- first-host readiness is accepted without expected API churn.

## End Point (M9 Done)

`M9` is done only when all are true:

- cross-host conformance expectations are explicit and bounded.
- host-agnostic behavioral evidence can be reproduced across at least two host integrations.
- drift detection and regression gates are explicit for host-facing runtime/model surfaces.
- no frozen milestone semantics (`M1-M8`) are reopened.

## M9 Scope

- define cross-host conformance matrix for frozen runtime/model contracts.
- define evidence protocol for host-to-host equivalence checks.
- define acceptance gates for multi-host reproducibility claims.

## M9-A Contract Authority (Closed)

Conformance contract authority is published in:

- `app_architecture/contracts/HOST_CONFORMANCE.md`

M9-A closure condition:

- host-equivalence claim vocabulary and required observable surfaces are explicit.

## Non-Goals

- no host implementation in this repository.
- no platform-specific policy in core/runtime/model contracts.
- no API redesign work under M9 without explicit breaking-change review.

## Stop Conditions

Stop and escalate if any occur:

- conformance requirement conflicts with frozen `M1-M8` contract behavior.
- host-specific behavior is proposed as core contract truth.
- evidence protocol cannot be executed without undocumented external assumptions.

## Validation Baseline

Every `M9` slice must pass:

- `zig build`
- `zig build test`
- `rg -n "compat[^ib]|fallback|workaround|shim" --glob '*.zig' src`

## Phase Plan

### M9-A: Conformance Contract Closure (Architect)

- define host-to-host equivalence vocabulary and required observable surfaces.

### M9-B: Evidence Protocol and Fixture Strategy (Architect)

- define reproducible cross-host validation procedure and fixture set ownership.

### M9-C: Execution Queue Publication (Architect)

- publish bounded engineer tickets only after M9-A/B closure.

### M9-D: Freeze and M10 Handoff (Architect)

- freeze conformance authority and publish M10 handoff.
