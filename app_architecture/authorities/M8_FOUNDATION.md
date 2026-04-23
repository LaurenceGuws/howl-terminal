# M8 Host Integration Readiness Foundation

`M8_FOUNDATION` is architect-owned authority for `M8`.

## Start Point (Locked Baseline)

`M8` starts from frozen `M1-M7` behavior and evidence.

Current gap:

- host-readiness requirements are not yet consolidated into one bounded
  authority covering API stability, integration seams, and acceptance gates.

## End Point (M8 Done)

`M8` is done only when all are true:

- host integration boundary is explicit and stable.
- API churn risk is bounded and documented.
- first-host readiness criteria are testable and evidence-backed.
- no frozen milestone semantics (`M1-M7`) are reopened.

## M8 Scope

- define readiness contract for first host integration.
- define required host-facing API stability and non-goals.
- define integration validation matrix and gate conditions.

## Non-Goals

- no host app implementation work in this repository.
- no platform lifecycle/render policy logic in terminal core.
- no semantic feature expansion to satisfy one host at the expense of portability.

## Stop Conditions

Stop and escalate if any occur:

- proposed readiness requirement conflicts with frozen `M1-M7` semantics.
- required host-readiness change introduces platform-specific behavior into core.
- API change cannot be justified against multi-host portability.

## Validation Baseline

Every `M8` slice must still pass:

- `zig build`
- `zig build test`
- `rg -n "compat[^ib]|fallback|workaround|shim" --glob '*.zig' src`
