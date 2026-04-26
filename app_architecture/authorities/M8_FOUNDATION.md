# M8 Host Integration Readiness Foundation

`M8_FOUNDATION` is architect-owned authority for `M8`.

## Start Point (Locked Baseline)

`M8` starts from frozen `M1-M7` behavior and evidence.

Locked baseline:

- `M1-M6` behavioral/API contracts are frozen.
- `M7` performance and memory doctrine/audit/freeze evidence is frozen.
- engineer queue is closed until architect readiness closure is complete.

## End Point (M8 Done)

`M8` is done only when all are true:

- first-host integration boundary is explicit and stable.
- host-facing API churn risk is bounded and documented.
- integration acceptance gates are executable and evidence-backed.
- `M1-M7` frozen semantics remain unchanged.

## M8 Scope

- close host-readiness contract for first-host integration.
- audit API and integration boundaries against frozen `M1-M7` contracts.
- define integration validation matrix and gate conditions.
- publish implementation queue only after architect closure gates pass.

## Non-Goals

- no host app implementation work in this repository.
- no platform lifecycle/render policy logic in terminal core.
- no semantic feature expansion to satisfy one host at the expense of portability.
- no compatibility/fallback surfaces to preserve unstable APIs.

## Host-Readiness Contract (M8-A)

### Stable Integration Surface

First-host integration must use only frozen exported surfaces:

- root exports: `parser`, `pipeline`, `semantic`, `screen`, `model`, `runtime`
- runtime facade: `Engine` stable method families documented in
  `app_architecture/contracts/RUNTIME_API.md`
- model contracts: key/modifier/selection/snapshot types documented in
  `app_architecture/contracts/MODEL_API.md`

### Allowed vs Disallowed Change Types During M8

Allowed:

- additive internal hardening that does not change public signatures.
- additive tests/evidence proving existing contract behavior.
- documentation clarifications that reduce ambiguity without changing behavior.

Disallowed:

- renaming/removing stable runtime/model/root symbols.
- adding platform-specific logic to core/runtime/model layers.
- behavior changes to satisfy one host when portability would regress.

### Integration Ownership Boundaries

- host owns lifecycle orchestration, I/O transport, rendering policy, and UI policy.
- terminal engine owns deterministic parse/event/screen/history/selection/input-encode behavior.
- snapshot is read-only capture surface; persistence/transport/restore are out of scope.

## Integration Boundary Families (M8-B Audit Targets)

Audit and classify each boundary for first-host readiness:

1. lifecycle boundary: `init*`, `deinit`, `clear`, `reset`, `resetScreen`
2. input ingest boundary: `feedByte`, `feedSlice`, `apply`
3. state read boundary: `screen`, `queuedEventCount`
4. history/selection boundary: `history*`, `selection*`
5. control output boundary: `encodeKey`, `encodeMouse`
6. snapshot boundary: `snapshot` read surface and parity guarantees

Canonical audit artifact:

- `docs/review/m8/M8_SEAM_AUDIT.md`

## Readiness Gates (Before Engineer Queue Opens)

All gates below must be true before publishing implementation tickets:

- `GATE-M8-A`: host-readiness contract closure is explicit in this file.
- `GATE-M8-B`: boundary audit is complete with per-boundary status and unresolved risks.
- `GATE-M8-C`: integration validation matrix is documented with exact commands and pass criteria.
- `GATE-M8-C2`: stop conditions are explicit for any future implementation slice.

### M8-C Gate Matrix (Authoritative)

| Gate | Requirement | Evidence Source | Status |
| --- | --- | --- | --- |
| `GATE-M8-A` | contract boundary, change policy, ownership boundary are explicit | this file | `pass` |
| `GATE-M8-B` | boundary audit classification complete with bounded follow-up | `docs/review/m8/M8_SEAM_AUDIT.md` | `pass` |
| `GATE-M8-C` | executable validation matrix and acceptance checks are explicit | this file + `docs/engineer/ACTIVE_QUEUE.md` | `pass` |
| `GATE-M8-C2` | stop conditions are explicit for implementation slices | this file + queue ticket stop conditions | `pass` |

Gate closure note:

- `encodeMouse` remains an explicit M8 non-goal placeholder and must be treated as
  deterministic empty output for first-host readiness. No ticket may overclaim mouse
  reporting completeness at M8.

## Validation Matrix (M8-C)

Mandatory commands per ticket:

- `zig build`
- `zig build test`
- `rg -n "compat[^ib]|fallback|workaround|shim" --glob '*.zig' src`

Mandatory acceptance checks per ticket:

- claims match `git show --name-status` and actual diff.
- no platform-specific logic added to `src/runtime`, `src/model`, `src/screen`, `src/event`, `src/parser`.
- no public API signature churn without explicit architect approval.
- host-readiness assertions are backed by tests or contract references, not prose alone.

## Stop Conditions

Stop and escalate if any occur:

- proposed readiness requirement conflicts with frozen `M1-M7` semantics.
- required host-readiness change introduces platform-specific behavior into core.
- API change cannot be justified against multi-host portability.
- boundary audit exposes ambiguity that cannot be resolved from existing contract authority.

## M8 Phases

### M8-A: Contract Closure

- publish host-readiness contract boundary and change policy.
- lock first-host integration ownership boundaries.

Exit check:

- contract is explicit enough that another architect can derive the same gate decisions.

### M8-B: Boundary Audit

- audit lifecycle, feed/apply, state read, history/selection, encode, and snapshot boundaries.
- classify each boundary as `ready`, `needs-hardening`, or `blocked`.

Exit check:

- one review artifact exists with bounded follow-up actions.

### M8-C: Validation Gates

- define integration readiness matrix and acceptance bar.
- ensure gate commands and evidence format are explicit.

Exit check:

- future execution queue can be enforced without re-planning.

### M8-D: Freeze and Handoff

- freeze M8 findings and acceptance state.
- publish M9 handoff only after M8 gates are closed.

Exit check:

- first-host integration can start without expected API churn.
