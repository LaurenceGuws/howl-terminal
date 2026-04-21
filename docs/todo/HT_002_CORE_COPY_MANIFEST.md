# HT-002: First Core Copy Manifest

Minimal parser/model heartbeat for the first Howl Terminal code migration.

## Goal

Copy the smallest viable parser and model files to prove the semantic core compiles and runs under Howl naming. No stubs, no integration, no old brand strings in code.

## Include: Parser + Model Only

### Parser
Core VT sequence parsing and input primitives:

```
parser/parser.zig    (tokenization and sequence dispatch)
parser/stream.zig    (byte stream handling)
parser/utf8.zig      (UTF-8 validation)
parser/csi.zig       (CSI sequence dispatch)
```

### Model
Core data structures for terminal state:

```
model/types.zig                    (base types)
model/screen/grid.zig              (cell storage)
model/metrics.zig                  (dimensions)
```

Do not include selection, scrollback, history, or reflow in the first slice. Add them once parser/model heartbeat compiles.

## Defer

- Host/session integration (session, publication, terminal_core)
- Rendering and presentation (presentation_*, surface_*)
- FFI and Android bindings
- Protocol handlers beyond CSI dispatch
- Workspace and editor concepts
- Selection, scrolling, or reflow logic
- Files importing app/, editor/, platform/, or workspace code

## First Proof Test

Add one test demonstrating parser tokenization or cell storage:

### Option A: Parser tokenization
```
Feed: "AB\x1b[31mC"
Assert: Tokenizer produces:
  - TEXT("AB")
  - CSI_START
  - COLOR_PARAM(31)
  - CSI_END
  - TEXT("C")
```

### Option B: Cell storage
```
Store cell 'X' at grid(0,0) with color red
Assert: grid(0,0) returns cell with char='X' and color=red
```

Choose the simpler one that requires no additional dependencies.

## Stop Conditions

Stop and shrink if:

1. Any import from: app/, editor/, platform/, workspace, session, publication, ffi, presentation_*
2. Any reference to old brand strings in code (comments only may be acceptable for clarity)
3. Need to write any stub or fallback logic—remove the dependency instead
4. Compiled size > 100 KB (code only, not tests)

## Validation

```bash
zig build
zig build test
rg -n "stub|shim|fallback|workaround|compat" src docs README.md build.zig

# Expected: no matches in code
```

## Commit Target

One clean commit with renamed parser and model files, plus one focused test.
