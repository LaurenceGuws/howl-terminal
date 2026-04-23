# Howl Terminal Active Queue

Execution-only queue for the current engineer loop.

## Ownership

- Architect writes and replaces this file every loop.
- Engineer executes only listed tickets.
- Engineer does not plan, redesign, or expand scope.

## Scope Anchor

- Scope authority: `app_architecture/authorities/SCOPE.md`
- Milestone authority: `app_architecture/authorities/MILESTONE.md`
- Architect workflow: `docs/architect/WORKFLOW.md`

## Current Loop

**Status:** M3 opened. Execute M3-A: history/selection contract and first
implementation slice.

M2 is frozen. Do not reopen wrap, tab, mode, reset, or cursor-alias semantics
unless an M3 test exposes a direct regression.

## M3-A Tickets

### M3-A1: History/Selection Contract Authority

- `ID`: M3-A1
- `Target files`: `app_architecture/contracts/MODEL_API.md`, `app_architecture/contracts/RUNTIME_API.md`, `app_architecture/contracts/SEMANTIC_SCREEN.md`, optionally new `app_architecture/contracts/HISTORY_SELECTION.md`
- `Allowed change type`: documentation-only authority update
- `Intent`: define M3 coordinate terms and behavior boundaries before source changes
- `Required content`:
  - viewport coordinates vs history coordinates
  - bounded history ownership and capacity policy
  - selection endpoint representation across viewport/history
  - reset/clear/DECSTR/history truncation invalidation rules
  - explicit non-goals for host UI, renderer selection painting, clipboard, mouse gestures, and platform integration
- `Non-goals`: no Zig source changes; no API invention beyond documented requirements; no renderer or host policy
- `Validation`: `zig build`; `zig build test`; `rg -n "compat[^ib]|fallback|workaround|shim" --glob '*.zig' src`
- `Stop conditions`: stop if a required rule conflicts with frozen M2 contracts or requires changing existing public method signatures without an explicit BREAKING section

### M3-A2: Bounded History Storage

- `ID`: M3-A2
- `Target files`: `src/screen/state.zig`, `src/model.zig`, `src/model/types.zig`, new `src/model/history.zig` if useful, `src/test/relay.zig`
- `Allowed change type`: add bounded history model/storage and integrate only with existing visible-screen scroll paths
- `Intent`: preserve rows scrolled off the top during bottom scroll while keeping visible screen behavior identical to M2
- `Required behavior`:
  - history capacity is explicit and allocator-owned
  - line feed at bottom and pending-wrap bottom scroll capture the outgoing top row when cells exist
  - zero-capacity or no-cell screens preserve M2 behavior and do not allocate hidden history
  - zero-dimension screens remain safe and deterministic
  - existing `ScreenState.init` behavior remains valid for cursor-only/no-history use
- `Non-goals`: no resize/reflow; no alternate screen; no style expansion; no hyperlink behavior; no host-facing mutable history access
- `Validation`: `zig build`; `zig build test`; shim grep above
- `Stop conditions`: stop if preserving history requires changing M2 visible grid outcomes, existing `ScreenState.init` semantics, or runtime facade transparency

### M3-A3: History Runtime Read Surface

- `ID`: M3-A3
- `Target files`: `src/runtime/engine.zig`, `src/root.zig`, `app_architecture/contracts/RUNTIME_API.md`, `src/test/relay.zig`
- `Allowed change type`: add minimal const history read access through runtime facade
- `Intent`: let hosts inspect history without gaining mutable access or importing parser/pipeline internals
- `Required behavior`:
  - runtime history view matches direct `ScreenState` history state
  - feed/apply ordering and queued-event semantics remain unchanged
  - chunked feed parity holds for history-producing streams
- `Non-goals`: no mutable screen/history accessor; no host/platform types; no renderer snapshots; no clipboard surface
- `Validation`: `zig build`; `zig build test`; shim grep above
- `Stop conditions`: stop if the API shape cannot stay const, host-neutral, and transparent relative to direct screen state

### M3-A4: Selection Coordinate Model Integration

- `ID`: M3-A4
- `Target files`: `src/model/selection.zig`, `src/model/types.zig`, `src/model.zig`, `app_architecture/contracts/MODEL_API.md`, `src/test/relay.zig`
- `Allowed change type`: evolve selection primitives to use the documented M3 coordinate model
- `Intent`: support deterministic selection over viewport and history coordinates without adding UI policy
- `Required behavior`:
  - start/update/finish/clear lifecycle remains simple and host-neutral
  - selection endpoints can represent visible rows and retained history rows
  - history truncation/reset invalidation follows M3-A1 contract
  - inactive selection still returns `null`
- `Non-goals`: no mouse event interpretation; no clipboard extraction; no text normalization; no renderer highlight policy
- `Validation`: `zig build`; `zig build test`; shim grep above
- `Stop conditions`: stop if selection needs renderer/host ownership, text extraction policy, or resize/reflow decisions to pass tests

## Report Format

Engineer report must include:

- `#DONE`
- `#OUTSTANDING`
- commit hash and subject for each ticket
- validation commands and results
- files changed per commit
- exact stop-condition details if blocked

## Guardrails

- No compatibility/fallback/workaround paths.
- No app/editor/platform/session/publication imports in parser/event/screen/model/runtime lanes.
- Ticket metadata stays out of Zig source comments.
- Doc-only tickets must not touch source files.
- Unit tests stay inline; integration tests stay in `src/test/relay.zig`.
