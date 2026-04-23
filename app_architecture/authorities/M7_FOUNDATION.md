# M7 Performance and Memory Discipline Foundation

`M7_FOUNDATION` — active authority for M7 execution.

This document bounds M7 scope so performance and memory work stays measurable,
contract-safe, and reviewable.

## Start Point (Locked Baseline)

M7 starts from frozen M1-M6 behavior:

- M1-M3 parser/pipeline/screen/history/selection semantics are frozen.
- M4 input/control encoding contracts are frozen.
- M5 runtime lifecycle boundaries are frozen.
- M6 snapshot/replay contracts and evidence are frozen.

Known planning gap at M7 start:

- no single authority defines performance budget targets, allocation discipline,
  and execution gates for optimization work.

## End Point (M7 Done)

M7 is done only when all are true:

- performance/memory scope is frozen in authority and contract text.
- hot paths are identified with baseline measurements and acceptance targets.
- allocation ownership and bounds are explicit for runtime-critical surfaces.
- optimization changes are test-backed and do not reopen frozen M1-M6 semantics.

## Execution Gates (Ordered)

### M7-A: Scope and Budget Closure

- define baseline performance and memory metrics to track.
- define bounded-allocation policy for runtime/model/parser/event/screen lanes.
- define measurement protocol (inputs, runs, and reporting format).

Exit check:

- M7 scope, targets, and non-goals are unambiguous.

### M7-B: Hot-Path Audit and Allocation Inventory

- inventory top hot paths and allocation sites in core runtime flow.
- classify allocations by ownership, lifetime, and maximum bound.
- identify unsafe or unbounded paths requiring correction.

Exit check:

- audited queue exists with ranked, bounded implementation tickets.

### M7-C: Bounded Allocation and Throughput Hardening

- implement highest-impact bounded-allocation fixes from M7-B queue.
- preserve external behavior and frozen contract semantics.
- add targeted tests/bench evidence for changed hot paths.

Exit check:

- bounded-allocation guarantees are enforced for covered surfaces.

### M7-D: Freeze and Handoff

- freeze M7 authority/progress and queue state.
- publish next milestone handoff scope.

Exit check:

- M7 marked done with evidence links and clean queue transition.

## Non-Goals (M7)

- no semantic expansion of VT behavior.
- no host/platform integration work.
- no compatibility/fallback/shim layers.
- no benchmark theater: changes must link to bounded contract outcomes.

## Stop Conditions

Stop and escalate if any occur:

- proposed M7 optimization requires changing frozen M1-M6 behavior.
- bounded-allocation requirement conflicts with existing contract guarantees.
- measurement evidence is non-reproducible under defined protocol.

## Validation Baseline

Every M7 execution slice must pass:

- `zig build`
- `zig build test`
- `rg -n "compat[^ib]|fallback|workaround|shim" --glob '*.zig' src`
