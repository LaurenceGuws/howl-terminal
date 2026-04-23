# Howl Terminal Active Queue

Execution-only queue for the current engineer loop.

## Ownership

- Architect writes and replaces this file every loop.
- Engineer executes only listed tickets.
- Engineer does not redesign scope during execution.

## Scope Anchor

- Milestone authority: `app_architecture/authorities/MILESTONE.md`
- Runtime contract: `app_architecture/contracts/RUNTIME_API.md`
- Snapshot/Replay authority: `app_architecture/authorities/M6_FOUNDATION.md` (to be published)
- Architect workflow: `docs/architect/WORKFLOW.md`

## Current Loop

**Status:** M5 complete. M6 planning phase active.

M1-M5 are frozen. Do not reopen parser/screen/history/selection/input/runtime
behavior unless an M6 test exposes a direct regression.

## M6 Planning Phase

Before M6 execution queue is published, architect must:

1. **Scope M6 boundaries**
   - Define what "snapshot and replay contracts" means in howl-terminal context
   - Clarify whether M6 covers checkpoint/restore semantics, deterministic replay for testing, or both
   - Decide which M6 outputs (snapshot format, replay validation, metadata) are in scope

2. **Identify M6 dependencies**
   - Snapshot format: does it require encoding history buffer and selection state?
   - Replay validation: does it require comparing direct vs. runtime pipeline outputs?
   - Coverage: which M1-M5 contracts need snapshot/replay evidence?

3. **Draft M6_FOUNDATION.md**
   - Start point: M1-M5 frozen behavior
   - End point: snapshot/replay contracts frozen and test-backed
   - Execution gates: M6-A through M6-D (tentative)
   - Stop conditions: where snapshot/replay logic conflicts with frozen behavior

4. **Publish M6 execution queue**
   - Once M6_FOUNDATION is reviewed, post M6-A Batch 1 tickets to ACTIVE_QUEUE.md

## Gatekeeping: M5-D Final Checklist

Before M6 execution:

- [ ] M5 contracts (RUNTIME_API.md + M5_FOUNDATION.md) reviewed and frozen
- [ ] M5 tests (M5-A conformance + M5-B parity) pass validation
- [ ] M5 checklist updated (M5-A/B/C marked [x], M5-D pending)
- [ ] Working tree clean; all M5 commits on main
- [ ] M6_FOUNDATION.md drafted and ready for review

## Non-Execution Guidance

### Current State

- M1-M4 frozen with contracts and replay coverage.
- M5 runtime interface complete: contract closure + interface hardening + parity matrix.
- No M6 scope or execution authority yet published.

### Next Steps for Architect

1. Review M5 deliverables (RUNTIME_API.md contract matrix, docstrings, parity tests).
2. Decide M6 scope and boundaries (snapshot/replay semantics, coverage).
3. Draft M6_FOUNDATION.md authority document.
4. Publish M6-A batch and replace this queue with M6 execution tickets.

## Guardrails (M5 Complete)

- No compatibility/fallback/workaround/shim paths in M5 code.
- No host/platform/renderer imports in runtime/model/event/screen lanes.
- No code changes except in M5-A/B execution.
- Engineer does not plan M6; architect owns scope definition.
