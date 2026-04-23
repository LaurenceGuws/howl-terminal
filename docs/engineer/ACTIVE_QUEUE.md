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

**Status:** M5-A complete and accepted. Execute M5-B.

M1-M4 and M5-A are frozen. Do not reopen parser/screen/history/selection/input
or M5-A contract/test work unless an M5-B parity test exposes a direct regression.

## M5-B Execution Order (Do Not Reorder)

### M5-B1: Runtime API Docstrings and Ownership Headers

- Target files:
  - `src/runtime/engine.zig`
- Allowed change type: docstring additions only (no signature or behavior changes).
- Required output:
  - Top-level `//!` ownership header for Engine struct
  - `///` docstrings on all stable public methods aligning to RUNTIME_API.md contract
  - Docstrings document behavior, not implementation
- Non-goals:
  - no code changes beyond docstrings
  - no internal function documentation
  - no parameter-by-parameter method docs (reference RUNTIME_API.md for details)
- Stop conditions:
  - if docstring wording conflicts with RUNTIME_API.md contract text, stop and report exact discrepancy.

### M5-B2: Runtime Parity Matrix (Mixed Host-Loop Tests)

- Target files:
  - `src/test/relay.zig`
- Allowed change type: parity test additions only.
- Required output:
  - add 4-5 parity tests covering mixed feed/apply/reset/encode sequences
  - include at least one split-feed scenario where chunking boundary affects parser/queue
  - one scenario with selection/history interaction during apply
  - prove runtime facade behavior matches direct pipeline+screen for same bytes
- Non-goals:
  - no new runtime API surface
  - no refactor of existing tests
  - no performance/stress testing
- Stop conditions:
  - if parity test indicates runtime behavior diverges from underlying pipeline/screen contracts for same byte stream, stop and report exact failing scenario + expected/actual state.

### M5-B3: M5-B Closeout + M5 Freeze Handoff

- Target files:
  - `docs/architect/MILESTONE_PROGRESS.md`
  - `docs/engineer/ACTIVE_QUEUE.md`
  - `app_architecture/authorities/MILESTONE.md` (checkpoint only)
- Allowed change type: status, queue, and minimal checklist updates.
- Required output:
  - mark M5-A and M5-B complete in progress notes
  - mark M5 checklist items M5-B1/M5-B2 as [x]
  - replace queue with M6 planning scope
- Non-goals:
  - no code changes
  - no contracts reopened

## Engineer Handoff: M5-B Batch 1

Commit per ticket:
- `#DONE` ticket ID
- `#OUTSTANDING` remaining tickets
- commit hash + subject
- validation output (zig build, zig build test, shim grep)
- files changed

## Mandatory Validation Per Ticket

- `zig build`
- `zig build test`
- `rg -n "compat[^ib]|fallback|workaround|shim" --glob '*.zig' src`

## Guardrails

- No compatibility/fallback/workaround/shim paths.
- No host/platform/renderer lifecycle imports in runtime/model/event/screen lanes.
- No scope expansion into M5-C/M5-D during M5-B execution.
- Docstring-only commits have zero runtime diff.
- Parity tests use existing test framework, no new testing libraries.
