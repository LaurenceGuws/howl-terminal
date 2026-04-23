# M9 Fixture Set

Canonical fixture classes for `M9` cross-host conformance evidence.

## Fixture Inventory

- `M9-FX-001` text baseline:
  - plain ASCII writes, CR/LF, cursor progression
- `M9-FX-002` utf8 text baseline:
  - mixed ASCII/UTF-8 codepoints
- `M9-FX-003` cursor/erase baseline:
  - CSI cursor movement + ED/EL classes
- `M9-FX-004` mode baseline:
  - DEC private mode toggles `?25` and `?7`
- `M9-FX-005` history baseline:
  - scroll-producing stream with bounded history wrap pressure
- `M9-FX-006` selection baseline:
  - selection start/update/finish/clear across viewport/history rows
- `M9-FX-007` reset boundary baseline:
  - interleavings of `clear`, `reset`, `resetScreen`
- `M9-FX-008` encode interleave baseline:
  - `encodeKey`/`encodeMouse` calls mixed with feed/apply and state checks
- `M9-FX-009` snapshot stability baseline:
  - repeated snapshot capture across mixed operations

## Fixture Maintenance

- fixture ids are stable and never reused.
- additions append new ids; existing ids are immutable.
- fixture definitions must remain contract-visible and host-neutral.
