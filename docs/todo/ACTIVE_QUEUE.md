# Howl Terminal Active Queue

This is the active planning surface for `howl-terminal`. Keep it short,
executable, and code-facing.

## Goal

Build `howl-terminal` into a standalone, portable VT engine that can eventually
stand beside serious terminal cores such as Ghostty's VT layer: small public
surface, deterministic behavior, replayable tests, and no dependency on the old
monolithic IDE.

The frozen source repo is a copybook, not authority. We copy ideas and proven
tests only after checking that they fit Howl.

## Naming Rules

- Product/repo/binary: `howl-terminal`
- Zig package/import where needed: `howl_terminal`
- Human name: `Howl Terminal`
- Forbidden in this repo: legacy brand strings, legacy ABI names, and
  compatibility aliases

## Milestones

| ID | Target | Exit |
| --- | --- | --- |
| `HT-M1` | Clean package skeleton and project authority | `zig build` / `zig build test` pass; docs name the goal and first queue |
| `HT-M2` | Minimal semantic VT core builds standalone | Parser/model/screen/protocol/core slice compiles under `howl_terminal`; no host/UI/FFI/JNI imports |
| `HT-M3` | Core behavior tests ported | Small unit/reflow/protocol tests pass from copied fixtures with Howl names |
| `HT-M4` | Replay harness proof | Deterministic replay fixture runner exists with at least smoke/cursor/reflow fixtures |
| `HT-M5` | Public package API | `src/root.zig` exposes a narrow Howl Terminal API without leaking internal layout |
| `HT-M6` | Host API boundary | PTY/FFI/host adapter shape is designed from Howl needs, not copied legacy ABI compatibility |

## Current Work

| ID | Status | Intent | Primary files | Exit |
| --- | --- | --- | --- | --- |
| `HT-001` | `done` | Replace `zig init` scaffold with Howl Terminal project authority and active queue. | `README.md`, `docs/todo/ACTIVE_QUEUE.md`, `build.zig.zon` | Project names are correct; `zig build` and `zig build test` pass. |
| `HT-002` | `done` | Prepare first core-copy manifest from frozen source without moving code yet. | `docs/todo/HT_002_CORE_COPY_MANIFEST.md` | Manifest names the smallest source/test set for `HT-M2`; excludes FFI, UI, Android, editor, and host packaging. |
| `HT-003` | `ready` | Copy parser/model heartbeat and add first proof test. | `src/**`, one test | Parser/model compiles and first test validates tokenization or cell storage. |

## First Core-Copy Default

Start with the smallest semantic engine slice, not the full old terminal stack:

- likely include: parser, protocol, model, `TerminalCore`, core-owned selection,
  scrolling, resize/reflow, semantic prompt, hyperlink table
- likely defer: FFI, BYO PTY host, Android bridge, app terminal widgets,
  renderer/presentation paths, workspace tabs, editor integration

If a copied file imports old app/editor/platform code, stop and shrink the slice
or replace the dependency with a local Howl-owned boundary.

## Validation

For each implementation commit:

- `zig build`
- `zig build test`
- `rg -n "<legacy-brand-pattern>" .`

Expected grep result: no matches.
