# First Host Handoff (Howl-Hosts)

This handoff defines the real next lane after `howl-terminal` freeze.

## Current Truth

- `howl-terminal` is frozen through `M10` with explicit contracts and evidence.
- `zide` remains the only place where real host runtime behavior currently exists.
- `howl-hosts` is the next delivery lane and must become the owner of host logic.

## Lane Goal

Stand up the first production host in `howl-hosts` as a thin adapter over the
frozen `howl-terminal` runtime/model surfaces.

## Non-Negotiable Constraints

- Do not reopen `howl-terminal` semantics for host convenience.
- No compatibility shims preserving Zide naming/ABI/package history.
- No editor scope in this lane.
- Keep host code host-owned; keep terminal behavior terminal-owned.

## Source of Prior Art (Read-Only)

Use `zide` only for extraction reference:

- `src/platform/*`
- `src/android_bridge_exports*`
- `src/app/terminal/*`
- `src/terminal/byo_pty_host.zig`

Everything moved must be renamed and re-owned for Howl architecture.

## Bounded Execution Sequence

### H0: Host Authority Closure (Architect)

Publish `H0` authority in `howl-hosts`:

- host lifecycle ownership
- input/feed/apply/render loop ownership
- resize and surface metrics seam
- PTY/session transport seam
- stop conditions and validation matrix

Exit check:

- authority is explicit enough to publish execution-only tickets.

### H1: Host Skeleton Bring-Up (Engineer)

Implement minimal running host skeleton with:

- window/surface init
- terminal engine init/deinit
- host loop that feeds terminal and applies updates
- basic render proof (not full UX)

Exit check:

- minimal host boots and drives terminal state without contract violations.

### H2: Input + Resize Seams (Engineer)

Implement bounded host translation:

- key input to runtime feed/encode paths
- resize path to terminal dimensions
- deterministic loop boundaries around apply/present

Exit check:

- conformance checks pass for fixed fixture scripts.

### H3: PTY + Session Loop (Engineer)

Add first transport seam:

- attach PTY/session bytes to feed/apply cycle
- preserve host ownership of transport/lifecycle
- preserve terminal ownership of parsing/semantics/state

Exit check:

- end-to-end shell interaction works through host without terminal API churn.

### H4: Freeze + Next Scope (Architect)

- freeze first-host authority and evidence
- publish next bounded host slice

## Stop Conditions

Stop and escalate immediately if any occurs:

- host requirement demands terminal semantic change
- proposed change mixes host policy into terminal core
- API change cannot be justified as multi-host contract improvement

## Validation Baseline

For host lane tickets, require:

- host build pass
- `howl-terminal` pinned baseline build/test pass
- explicit contract trace from host claim -> terminal contract surface

## Immediate Next Action

Start in `howl-hosts` with architect-owned `H0` authority publication before
any engineer queue.
