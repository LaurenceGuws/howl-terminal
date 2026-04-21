# HT-002: First Core Copy Manifest

This manifest defines the smallest semantic terminal core slice for `HT-003` to copy and rename from the frozen Zide source. No code is moved in this ticket—this is the executable specification.

## First Copy Target: Minimal Semantic Core

The goal is to extract only the semantic terminal engine (VT parser, model, core state machine) without any host, rendering, session, or app integration logic.

## Include: Grouped by Purpose

### 1. Model Layer (960 lines total)
Core data structures for terminal state. No app/UI dependencies.

```
frozen source: /home/home/personal/zide/src/terminal/model/

target files to copy:
  model/types.zig
  model/screen/screen.zig
  model/screen/grid.zig
  model/screen/tabstops.zig
  model/screen/key_mode.zig
  model/selection_semantics.zig
  model/selection.zig
  model/scrollback.zig
  model/scrollback_buffer.zig
  model/scrollback_view.zig
  model/history.zig
  model/metrics.zig
```

### 2. Parser & Input (670 lines)
VT sequence parser and input stream primitives. Only logs (replaceable with no-op).

```
frozen source: /home/home/personal/zide/src/terminal/parser/

target files to copy:
  parser/parser.zig        (11.5 KB, imports: std, stream.zig, csi.zig, esc_effects.zig)
  parser/stream.zig        (755 B)
  parser/utf8.zig          (1.5 KB)
  parser/csi.zig           (4.7 KB)
```

### 3. Core Semantics & Modes (small, portable)
Terminal mode state and selection semantics. No runtime coupling.

```
frozen source: /home/home/personal/zide/src/terminal/core/

target files to copy:
  core/semantic_prompt.zig           (397 B, pure enum)
  core/terminal_core_modes.zig       (1.4 KB, pure semantics)
  core/terminal_core_selection.zig   (5.9 KB)
  core/hyperlink_table.zig           (1.1 KB, only app_logger dep)
```

### 4. Scrolling & Reflow (portable with stubs)
Cell reflow, scrolling, selection logic. Depends on semantics-level callbacks.

```
frozen source: /home/home/personal/zide/src/terminal/core/

target files to copy:
  core/scrolling.zig         (4.4 KB)
  core/resize_reflow.zig     (25.3 KB)
  core/selection.zig         (6.5 KB)
```

### 5. First Test Fixtures
Portable unit tests exercising parser, reflow, and mode semantics. No FFI, workspace, or renderer coupling.

```
frozen source: /home/home/personal/zide/tests/

target tests to copy (from test_presentation_runtime.zig and terminal_* test files):
  - Parser input stream tests (feed bytes → verify parse state)
  - CSI sequence tests (escape codes → semantic mutations)
  - Reflow tests (resize → cell repositioning)
  - Input mode tests (mode flags → sanitization)
  - Selection tests (selection bounds → visible cells)
  - Hyperlink table tests (URL storage → retrieval)
  - Scrolling tests (scroll ops → viewport changes)
```

## Defer: Explicit Deferral List

**FFI & C Integration**
- `ffi/` (c_api.zig, core_api.zig, bridge.zig, shared.zig, renderer_metadata.zig)
  - Reason: Host/renderer boundary. Defer until Howl Terminal defines its public API.

**Session & Runtime Infrastructure**
- `core/session/` (host_types.zig, protocol_execution.zig, config.zig)
- `core/publication/` (snapshot.zig, publication_flow.zig)
- `core/terminal_core.zig` (1603 lines, 58 KB—**central hub tightly coupled to session/publication**)
  - Reason: Depends on session lifecycle, host callbacks, publication pipeline. Defer until HT defines semantics/runtime boundary.

**PTY Host Adapter**
- `byo_pty_host.zig`
  - Reason: Host-specific. Howl Terminal owns only the semantic core, not the PTY bridge.

**Presentation & Rendering**
- `presentation_runtime.zig`
- `presentation_bridge.zig`
- `surface_contract.zig`
- `surface_attachment_contract.zig`
- `replay_harness.zig`
  - Reason: Rendering, GUI lifecycle, host attachment. Out of scope for semantic core.

**Workspace & Editor Integration**
- `core/workspace.zig`, `core/workspace_host.zig`, `core/workspace_polling.zig`
  - Reason: Editor/IDE workspace concepts. Howl Terminal is not an IDE.

**Protocol Layer (deferred, not all)**
- High-level protocol handlers: `protocol/osc_*.zig` (11 of 17 files)
  - These import `app_logger`, `protocol_runtime`, `session/config.zig`
  - Reason: Session-level semantics. Defer until core protocol execution is designed.
  - Exception: `protocol/csi.zig` is already in parser; `protocol/osc.zig` is dispatcher.

**Android & Graphics**
- `kitty/` (graphics ops)
- Any Android-specific code
  - Reason: Host-specific. Defer.

**Generated & Old Docs**
- Any files with "zide" brand strings or legacy ABI names
- Old process/build history

## First Proof Test for HT-003

Once code is copied and renamed, the first test should be:

### Test: "Initialize terminal and assert cell state after feeding bytes"

```
1. Create a TerminalScreen (or equiv Howl-named struct) with default dimensions (80×24)
2. Feed a sequence: "Hello\r\n" (printable + CRLF)
3. Assert:
   - Visible cells at (0,0) contain "H e l l o"
   - Cursor is at (0,2) post-CRLF (column 0, row 2)
   - Cell attributes (color, style) are default
4. Feed escape sequence: "\x1b[31mRed\x1b[0m"
5. Assert:
   - Cells contain text "Red" at current cursor
   - Cells have color attribute set to red
   - After `\x1b[0m`, subsequent cells are default
6. Feed: "\x1b[2J" (clear screen)
7. Assert:
   - All cells are blank
   - Cursor is at (0,0)
```

This validates parser, cell model, cursor state, and reflow in one integrated test.

## Stop Conditions for HT-003

Stop copying and investigate before proceeding if:

1. **Any copied file imports**:
   - `app/`, `editor/`, `android/`, `ffi/`, `session/`, `publication/`, `presentation_*`, `workspace`
   
2. **Any legacy brand string appears**:
   - `zide`, `Zide`, `ZIDE`, `zide_terminal`, `ZideTerminal`
   
3. **Any compatibility/fallback logic is needed**:
   - `// compat`, `// workaround`, `if (zide_mode)`, etc.
   
4. **Copied slice balloons beyond semantic core**:
   - If you've copied > 3 KB of non-core code, audit against this manifest.

If any stop condition is hit, pause and file a blocker comment in the ticket.

## Validation Commands for HT-003

After copying & renaming all files in this manifest:

```bash
# Ensure build succeeds
zig build

# Ensure tests compile and pass
zig build test

# Check for any legacy brand strings
rg -n "zide|Zide|ZIDE|zide_terminal|ZideTerminal" .

# Expected: no matches, exit 0
```

## Dependencies to Stub/Mock for Portability

During HT-003 copy, these will need local shims or removal:

| Dependency | Frozen Usage | Howl Shim |
| --- | --- | --- |
| `app_logger` | Logging | Replace with no-op or Howl logger |
| `publication_flow` | Mutation callbacks | Replace with simple callback interface |
| `terminal_transport` | PTY size notification | Replace with callback stub |
| `engine_core_face` | Session coordination | Replace with simpler interface |

## Summary

**Slice size**: ~4-5 KB of semantic core files + ~7 test files.
**Complexity**: Parser, model, mode logic, selection, reflow—no session, rendering, or host coupling.
**Exit criterion for HT-003**: `zig build test` passes; first test validates parser/model/cursor behavior.
