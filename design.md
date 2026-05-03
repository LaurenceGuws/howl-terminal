# Design

Shared rules: [`../design/design-rules.md`](../design/design-rules.md)

## Purpose
`howl-vt-core` owns the host-neutral terminal model.

It parses terminal input streams, interprets them into semantic actions, applies them to grid state, tracks selection and snapshot state, and exposes a stable render-facing view.

## Public Surface
- `VtCore`: main runtime owner.
- `Input`: input domain owner.
- `ParserApi`: parser domain owner.
- `Interpret`: interpret domain owner.
- `Grid`: grid domain owner.
- `Selection`: selection domain owner.
- `Snapshot`: snapshot domain owner.

```mermaid
classDiagram
    class VtCore {
      +init()
      +initWithCells()
      +initWithCellsAndHistory()
      +feedByte()
      +feedSlice()
      +apply()
      +resize()
      +renderView()
      +historyCount()
      +selectionState()
    }
    class Input
    class ParserApi
    class Interpret
    class Grid
    class Selection
    class Snapshot

    VtCore --> Input : key/modifier vocabulary
    VtCore --> Interpret : pipeline
    VtCore --> Grid : screen state
    VtCore --> Selection : selection state
    VtCore --> Snapshot : external snapshot contract
```

## Ownership Rules
- `VtCore` owns lifecycle, parser pipeline ownership, grid state, and selection state.
- `Input` owns key, modifier, mouse, and input codec vocabulary.
- `ParserApi` owns byte-stream parsing contracts.
- `Interpret` owns parser-to-grid translation flow.
- `Grid` owns screen, cursor, and scrollback model state.
- `Selection` owns selection state and validity against grid mutations.
- `Snapshot` owns exported snapshot shapes only.

## Lifecycle
```mermaid
stateDiagram-v2
    [*] --> Uninitialized
    Uninitialized --> Ready: init/initWithCells/initWithCellsAndHistory
    Ready --> Ready: feedByte/feedSlice
    Ready --> Ready: apply
    Ready --> Ready: resize
    Ready --> Ready: reset/resetScreen/clear
    Ready --> Destroyed: deinit
    Destroyed --> [*]
```

## Main Flows
### Parse And Apply
```mermaid
sequenceDiagram
    participant Host
    participant V as VtCore
    participant P as Interpret.Pipeline
    participant G as GridModel
    participant S as SelectionState

    Host->>V: feedSlice(bytes)
    V->>P: feedSlice(bytes)
    Host->>V: apply()
    V->>P: applyToScreen(&state)
    P->>G: mutate screen/cursor/history
    V->>S: clearIfInvalidatedByGrid(&state)
    V-->>Host: renderView()/screen()/historyCount()
```

### Resize
```mermaid
sequenceDiagram
    participant Host
    participant V as VtCore
    participant G as GridModel
    participant S as SelectionState

    Host->>V: resize(rows, cols)
    V->>G: resize(allocator, rows, cols)
    V->>S: clearIfInvalidatedByGrid(&state)
```

## API Contracts
- `init*` returns an owned `VtCore`; caller must later call `deinit`.
- `feedByte` and `feedSlice` queue parser work only; they do not apply it to the grid.
- `apply` is the boundary that mutates screen state.
- `renderView` returns a stable read-only projection for rendering.
- `resize` preserves terminal semantics while updating visible geometry.
- Selection validity is rechecked after grid-affecting operations.

## Non-Goals
- PTY ownership.
- Host windowing.
- GPU rendering.
- Font loading or rasterization.

## Change Rules
- New visible-state concepts should either live on `VtCore` or in a clearly named sibling domain owner.
- Parser and interpret internals may change freely if the `VtCore` contract stays stable.
- Hosts should depend on `VtCore`, not deep parser/grid leaves.
