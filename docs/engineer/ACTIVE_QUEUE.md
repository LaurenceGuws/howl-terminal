# Howl Terminal Active Queue

Execution-only queue for the current engineer loop.

## Ownership

- Architect writes and replaces this file every loop.
- Engineer executes only listed tickets.
- Engineer does not redesign scope during execution.

## Scope Anchor

- Milestone authority: `app_architecture/authorities/MILESTONE.md`
- M5 authority: `app_architecture/authorities/M5_FOUNDATION.md`
- Runtime contract: `app_architecture/contracts/RUNTIME_API.md`
- Architect workflow: `docs/architect/WORKFLOW.md`

## Current Loop

**Status:** M4 frozen. M5 active.

M1-M4 are frozen. Do not reopen parser/screen/history/selection/input behavior
unless an M5 parity test exposes a direct runtime-related regression.

## M5 Execution Order (Do Not Reorder)

1. **M5-A: Contract Closure**
   - Align runtime lifecycle + mutation-boundary language across authorities/contracts.
   - Exit check: no ambiguity in reset/clear/resetScreen/apply behavior.

2. **M5-B: Interface Hardening**
   - Align `src/runtime/engine.zig` public API to contract text.
   - Exit check: host-neutral, deterministic surface; no mutable escapes.

3. **M5-C: Runtime Parity Matrix**
   - Add mixed host-loop parity/runtime tests.
   - Exit check: direct pipeline/screen and runtime facade behavior match.

4. **M5-D: Freeze Handoff**
   - Update authority/progress docs and repoint queue to M6 planning.
   - Exit check: M5 marked done with closeout evidence.

## Engineer Handoff: M5-A Batch 1

Execute these tickets in order, commit per ticket, and report with:
`#DONE`, `#OUTSTANDING`, commit hash + subject, validation output, files changed.

### M5-A1: Runtime Lifecycle Contract Matrix

- Target files:
  - `app_architecture/contracts/RUNTIME_API.md`
  - `app_architecture/contracts/SEMANTIC_SCREEN.md` (only if cross-reference required)
  - `app_architecture/contracts/INPUT_CONTROL.md` (only if cross-reference required)
- Allowed change type: contract clarification only (no code changes).
- Required output:
  - single unambiguous lifecycle matrix for `feed*`, `apply`, `clear`, `reset`, `resetScreen`, `screen`, history/selection reads, and `encode*`.
  - explicit mutation vs non-mutation boundaries per method.
- Non-goals:
  - no signature changes
  - no behavior changes
  - no milestone/queue rewrites beyond M5-A references
- Stop conditions:
  - if clarification implies breaking frozen M1-M4 semantics, stop and report exact conflict.

### M5-A2: Runtime Contract Conformance Audit (Code + Tests)

- Target files:
  - `src/runtime/engine.zig`
  - `src/test/relay.zig`
- Allowed change type: conformance-only hardening to match M5-A1 contract text.
- Required output:
  - add or tighten tests that prove method-boundary invariants from M5-A1.
  - keep facade host-neutral; no platform types/imports.
- Non-goals:
  - no new host features
  - no parser/screen semantic expansion
  - no mutable escapes from runtime facade
- Stop conditions:
  - if parity indicates underlying parser/screen mismatch not runtime-owned, stop and report failing scenario + expected/actual.

### M5-A3: M5-A Closeout + Queue Advance

- Target files:
  - `docs/architect/MILESTONE_PROGRESS.md`
  - `docs/engineer/ACTIVE_QUEUE.md`
- Allowed change type: status and queue handoff update only.
- Required output:
  - mark M5-A complete in progress notes.
  - replace handoff block with M5-B batch starter tickets.
- Non-goals:
  - no code changes
  - no reopening completed milestones

## Mandatory Validation Per Ticket

- `zig build`
- `zig build test`
- `rg -n "compat[^ib]|fallback|workaround|shim" --glob '*.zig' src`

## Guardrails

- No compatibility/fallback/workaround/shim paths.
- No host/platform/renderer lifecycle imports in runtime/model/event/screen lanes.
- No scope expansion into M6+ during M5 execution.
