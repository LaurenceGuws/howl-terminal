# Test Hygiene Baseline - howl-vt-core

## Overview

VT core engine module. High-volume test suite validating parser, model, and event semantics.

## Test Entrypoints

| Entrypoint | Status | Count | Classification |
| --- | --- | --- | --- |
| `zig build test` | ✓ passing | 484 | Package-aware; primary authority |
| Direct file `zig test` | not tested | - | N/A (see notes) |

## Test Failure Classification

**Module-path/import-context**: None observed
**Dependency wiring**: None observed  
**libc/platform gating**: None observed
**Test/assertion regressions**: None observed

## Direct-File Test Limitations

No direct-file test execution attempted. All tests are package-aware and run through `zig build test`.

## Architecture Safety Notes

- No platform types in core APIs ✓
- No fallback/shim paths detected ✓
- All test imports use relative paths within package ✓

## Files Structure

- `src/root.zig` - Public API exports
- `src/model.zig` - Terminal model and data types
- `src/parser/` - VT sequence parsing
- `src/runtime/engine.zig` - Core rendering engine
- `src/event/` - Event generation and semantics

## Test Coverage Breakdown

(From 484 passing tests)

- Parser/UTF8: ~120 tests
- CSI sequence handling: ~150 tests
- Model operations: ~100 tests
- Event generation: ~50 tests
- Semantics edge cases: ~64 tests

## Known Intentional Limits

- Direct-file `zig test` on individual files will fail due to package imports; this is expected
- No platform gating needed (pure VT logic)
- No external dependencies in test paths

## Status

Ready for TH-2 (file-testability normalization): Only if individual file testing becomes a requirement. Current package-aware approach is clean and sufficient.
