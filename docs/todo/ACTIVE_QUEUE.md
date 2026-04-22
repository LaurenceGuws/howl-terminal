# Howl Terminal Active Queue

Execution-only queue for `howl-terminal`.

## Goal

Build `howl-terminal` into a standalone, portable VT engine with deterministic
behavior, replayable tests, and no dependency on app/editor/platform code.

## Active / Next

| ID | Status | Intent |
| --- | --- | --- |
| `HT-051A` | `ready` | Queue reset: slim scope for 256-color work. |
| `HT-051B` | `ready` | SGR 256-color semantic mapping. |
| `HT-051C` | `ready` | Screen apply for 256-color style state. |
| `HT-051D` | `ready` | Relay fixtures for 256-color integration. |
| `HT-051E` | `ready` | Contract + queue sync for 256-color support. |

## Guardrails

- Frozen legacy source is copybook, not authority.
- No compatibility/fallback/workaround paths.
- No app/editor/platform/session/publication imports in core parser/model lanes.
- Ticket metadata stays out of Zig source comments.
- Doc-only tickets must not touch source files.
- No `terminal_`, `core_`, or noisy prefix names in module file names or imports.
- All unit tests inline; integration tests in `src/test/relay.zig` only.

## Layout reference

```
src/parser/{parser,stream,utf8,csi}.zig   — parser primitives
src/event/{bridge,pipeline,semantic}.zig  — event layer
src/screen/state.zig                       — screen state
src/test/relay.zig                         — integration replay tests
src/root.zig                               — public API surface
app_architecture/terminal/
  EVENT_BRIDGE_CONTRACT.md
  SEMANTIC_SCREEN_CONTRACT.md
  MODEL_API_CONTRACT.md
  PARSER_API_CONTRACT.md
```
