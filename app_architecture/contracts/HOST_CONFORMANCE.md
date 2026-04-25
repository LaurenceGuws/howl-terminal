# Multi-Host Conformance Contract

`HOST_CONFORMANCE_CONTRACT` — introduced for `M9`.

Authority for cross-host confidence claims against frozen `M1-M8` behavior.

## Purpose

Define what may be claimed as host-equivalent behavior, how it is measured,
and what is explicitly out of scope.

This contract does not add new terminal behavior. It defines evidence rules for
comparing host integrations that consume the frozen `howl-vt-core` surfaces.

## Conformance Claim Levels

### C0: Contract Surface Conformance

Host integration claims only that it uses frozen API surfaces without mutation of
contract boundaries.

Required:

- uses frozen root exports and runtime/model API methods as documented.
- no host-specific behavior is represented as core contract behavior.

### C1: Observable State Conformance

For equivalent input fixture streams, hosts produce equivalent runtime-observable
state snapshots.

Required equivalence surfaces:

- screen dimensions and cursor
- visible cell content
- mode state (`cursor_visible`, `auto_wrap`)
- history retention semantics
- selection state semantics
- queued-event phase boundaries where observable through runtime methods

### C2: Interaction Conformance

Hosts preserve equivalence across mixed interaction sequences.

Required sequence classes:

- split feed/apply chunking equivalence
- reset/clear/resetScreen boundary behavior
- encode interleaving non-mutation guarantees
- snapshot stability under mixed feed/encode/selection flows

## Canonical Input Fixtures

Fixtures used for host-to-host comparison must include representative coverage of:

- plain text and UTF-8 text
- CSI cursor movement and erase sequences
- mode toggles (`?25`, `?7`)
- history-producing scroll streams
- selection start/update/finish/clear sequences
- input encode coverage for frozen key classes

Fixture definitions are owned by `M9` authority and may only expand additively.

## Comparison Rules

- compare observable runtime state only; do not compare renderer internals.
- compare deterministic outputs at declared checkpoints, not continuously.
- host transport timing and frame scheduling are not conformance surfaces.
- if a mismatch occurs, classify as:
  - `contract regression` (core behavior drift)
  - `host integration defect` (host misuse or policy issue)
  - `insufficient fixture` (coverage gap; requires fixture expansion)

## Non-Goals

- no claim of pixel/render equivalence.
- no claim of equal throughput/latency across host UI stacks.
- no host-specific feature completeness claims outside frozen core contracts.

## Breaking Change Rule

A change is breaking if it:

1. redefines C0/C1/C2 equivalence requirements without authority update,
2. removes required comparison surfaces,
3. reclassifies out-of-scope timing/render details as mandatory conformance.

## Required References

- `app_architecture/authorities/M9_FOUNDATION.md`
- `app_architecture/contracts/RUNTIME_API.md`
- `app_architecture/contracts/MODEL_API.md`
- `app_architecture/contracts/SNAPSHOT_REPLAY.md`
