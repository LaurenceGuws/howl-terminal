# M10 Stress Fixture Catalog

Canonical fixture catalog for M10 evidence expansion protocol.

## Fixture Inventory

- `M10-FX-001` burst feed/apply stress:
  - repeated short feed bursts with apply boundaries
- `M10-FX-002` mixed reset boundary stress:
  - interleavings of clear/reset/resetScreen under load
- `M10-FX-003` selection/history drift loop:
  - repeated selection and history-producing streams
- `M10-FX-004` encode interleave stress:
  - encodeKey/encodeMouse mixed with feed/apply loops
- `M10-FX-005` snapshot drift loop:
  - repeated checkpoints and snapshot parity checks
- `M10-FX-006` mode toggle soak:
  - repeated DEC private mode toggles with state assertions

## Maintenance Rules

- fixture ids are stable and never reused.
- fixture definitions are contract-visible and host-neutral.
- additions append only; no silent mutation of existing fixture intent.
