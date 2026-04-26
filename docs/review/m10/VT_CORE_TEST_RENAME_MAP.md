# VT-Core Test Rename Map

Inventory of legacy milestone/ticket-tagged test names removed from `howl-vt-core` in this cleanup sprint.

## `src/root.zig`

| Old test name | New behavior-first test name |
| --- | --- |
| `test "root: exposes M1 host-neutral module surface" {` | `test "root: exposes host-neutral module surface" {` |
| `test "root: runtime Engine exposes frozen M1 facade methods" {` | `test "root: runtime Engine exposes stable facade methods" {` |
| `test "M8-E1: runtime Engine const-read methods (M3+ history/selection)" {` | `test "runtime: const-read history and selection accessors stay stable" {` |
| `test "M8-E1: runtime Engine M5+ lifecycle methods remain stable" {` | `test "runtime: lifecycle extension methods stay stable" {` |
| `test "M8-E1: runtime Engine snapshot surface and deterministic" {` | `test "runtime: snapshot surface remains deterministic" {` |
| `test "M8-E1: encodeKey and encodeMouse methods present and callable" {` | `test "runtime: encodeKey and encodeMouse methods are callable" {` |
| `test "M8-E1: encodeMouse placeholder returns empty output" {` | `test "runtime: encodeMouse returns empty output" {` |
| `test "M8-E1: encodeMouse does not mutate observable engine state" {` | `test "runtime: encodeMouse does not mutate observable engine state" {` |

## `src/test/relay.zig`

| Old test name | New behavior-first test name |
| --- | --- |
| `test "M4 closeout: keyboard input comprehensive coverage" {` | `test "input encoding: keyboard coverage across printable, control, cursor, and function keys" {` |
| `test "M4 closeout: modifier combinations are deterministic" {` | `test "input encoding: modifier combinations are deterministic" {` |
| `test "M4 closeout: encoding is reset-stable" {` | `test "input encoding: encoding survives reset and screen reset" {` |
| `test "M4 closeout: encoding does not mutate state" {` | `test "input encoding: encoding does not mutate state" {` |
| `test "M4 closeout: encoding covers extended keys with modifiers" {` | `test "input encoding: extended keys with modifiers" {` |
| `test "M4 closeout: encoding covers function keys with modifiers" {` | `test "input encoding: function keys with modifiers" {` |
| `test "M5-A2 conformance: clear() empties queue without mutating parser or screen" {` | `test "runtime contract: clear() empties queue without mutating parser or screen" {` |
| `test "M5-A2 conformance: reset() clears parser+queue but preserves screen modes" {` | `test "runtime contract: reset() clears parser and queue while preserving screen modes" {` |
| `test "M5-A2 conformance: resetScreen() clears screen but preserves parser+queue" {` | `test "runtime contract: resetScreen() clears screen while preserving parser and queue" {` |
| `test "M5-A2 conformance: multiple apply() calls without feed are no-ops" {` | `test "runtime contract: repeated apply() calls without feed are no-ops" {` |
| `test "M5-A2 conformance: feed operations queue events without applying" {` | `test "runtime contract: feed operations queue events before apply" {` |
| `test "M5-A2 conformance: encode operations have no observable state effects" {` | `test "runtime contract: encode operations have no observable state effects" {` |
| `test "M5-A2 conformance: screen() returns const reference only" {` | `test "runtime contract: screen() returns a const reference" {` |
| `test "M5-A2 conformance: feed/apply/reset ordering" {` | `test "runtime contract: feed/apply/reset ordering" {` |
| `test "M5-B2 parity: split-feed at CSI boundary preserves queue semantics" {` | `test "runtime parity: split-feed at CSI boundary preserves queue semantics" {` |
| `test "M5-B2 parity: feed/apply/reset/feed/apply preserves state isolation" {` | `test "runtime parity: feed/apply/reset/feed/apply preserves state isolation" {` |
| `test "M5-B2 parity: selection + history interaction during apply" {` | `test "runtime parity: selection and history remain stable during apply" {` |
| `test "M5-B2 parity: encode interleaved with feed/apply does not mutate state" {` | `test "runtime parity: encode interleaved with feed/apply does not mutate state" {` |
| `test "M5-B2 parity: complex state machine sequence" {` | `test "runtime parity: complex state machine sequence" {` |
| `test "M6-A snapshot: capture from simple text" {` | `test "snapshot: capture from simple text" {` |
| `test "M6-A snapshot: determinism - identical state produces identical snapshots" {` | `test "snapshot: determinism across identical state" {` |
| `test "M6-A snapshot: split-feed replay equivalence - atomic vs chunked" {` | `test "snapshot: split-feed replay equivalence" {` |
| `test "M6-A snapshot: history capture when history enabled" {` | `test "snapshot: history capture when history is enabled" {` |
| `test "M6-A snapshot: historyRowAt matches engine after wraparound" {` | `test "snapshot: historyRowAt matches engine after wraparound" {` |
| `test "M6-A snapshot: selection state included in snapshot" {` | `test "snapshot: selection state is included" {` |
| `test "M6-A snapshot: parity with direct screen state" {` | `test "snapshot: parity with direct screen state" {` |
| `test "M6-C replay evidence: clear does not change snapshot" {` | `test "replay: clear leaves snapshot unchanged" {` |
| `test "M6-C replay evidence: reset preserves screen state in snapshot" {` | `test "replay: reset preserves snapshot state" {` |
| `test "M6-C replay evidence: resetScreen clears cells but preserves history" {` | `test "replay: resetScreen clears cells while preserving history" {` |
| `test "M6-C replay evidence: snapshot determinism across feed sequence variations" {` | `test "replay: snapshot determinism across feed sequence variations" {` |
| `test "M6-C replay evidence: snapshot reflects mode changes" {` | `test "replay: snapshot reflects mode changes" {` |
| `test "M6-C replay evidence: snapshot includes active selection with endpoints" {` | `test "replay: snapshot includes active selection endpoints" {` |
| `test "M6-C replay evidence: snapshot parity across direct pipeline vs runtime" {` | `test "replay: snapshot parity across direct pipeline and runtime" {` |
| `test "M6-C replay evidence: snapshot wraparound history indices after eviction" {` | `test "replay: snapshot wraparound history indices after eviction" {` |
| `test "M8-E2: feed/apply/reset interleavings preserve frozen boundaries" {` | `test "runtime stability: feed/apply/reset interleavings preserve frozen boundaries" {` |
| `test "M8-E2: resetScreen clears cells without disrupting subsequent feed/apply" {` | `test "runtime stability: resetScreen clears cells without disrupting subsequent feed/apply" {` |
| `test "M8-E2: selection remains stable across feed/apply/reset cycles" {` | `test "runtime stability: selection remains stable across feed/apply/reset cycles" {` |
| `test "M8-E2: history preserved across clear/reset cycles" {` | `test "runtime stability: history remains preserved across clear/reset cycles" {` |
| `test "M8-E2: encodeKey does not affect screen or queued events" {` | `test "runtime stability: encodeKey does not affect screen or queued events" {` |
| `test "M8-E2: encodeMouse interleaved with mutations shows zero side effects" {` | `test "runtime stability: encodeMouse interleaved with mutations shows zero side effects" {` |
| `test "M8-E2: queuedEventCount reflects only feed phase, not encode calls" {` | `test "runtime stability: queuedEventCount reflects feed only, not encode calls" {` |
| `test "M8-E2: history read seam stable across concurrent selection operations" {` | `test "runtime stability: history read seam remains stable across concurrent selection operations" {` |
| `test "M8-E2: snapshot stable across mixed feed/encode/selection operations" {` | `test "runtime stability: snapshot remains stable across mixed feed/encode/selection operations" {` |
| `test "M9-E1: ConformanceCheckpoint captures contract-visible fields" {` | `test "conformance checkpoint: captures contract-visible fields" {` |
| `test "M9-E1: ConformanceCheckpoint determinism across repeated captures" {` | `test "conformance checkpoint: determinism across repeated captures" {` |
| `test "M9-E1: encode calls do not alter ConformanceCheckpoint state" {` | `test "conformance checkpoint: encode calls do not alter checkpoint state" {` |
| `test "M9-E1: feed/apply checkpoint boundaries captured correctly" {` | `test "conformance checkpoint: feed/apply boundaries are captured correctly" {` |
| `test "M9-FX-001: text baseline - ASCII writes and cursor progression" {` | `test "text baseline: ASCII writes and cursor progression" {` |
| `test "M9-FX-001: text baseline - CR/LF line wrapping" {` | `test "text baseline: CR/LF line wrapping" {` |
| `test "M9-FX-002: UTF-8 text baseline - mixed codepoints" {` | `test "text baseline: UTF-8 mixed codepoints" {` |
| `test "M9-FX-003: cursor/erase baseline - CSI H cursor movement" {` | `test "cursor baseline: CSI H cursor movement" {` |
| `test "M9-FX-003: cursor/erase baseline - ED erase display" {` | `test "cursor baseline: ED erase display" {` |
| `test "M9-FX-004: mode baseline - DEC private mode ?25 cursor visibility" {` | `test "mode baseline: DEC private mode ?25 cursor visibility" {` |
| `test "M9-FX-004: mode baseline - DEC private mode ?7 auto wrap" {` | `test "mode baseline: DEC private mode ?7 auto wrap" {` |
| `test "M9-FX-005: history baseline - scroll-producing stream" {` | `test "history baseline: scroll-producing stream" {` |
| `test "M9-FX-006: selection baseline - start/update/finish/clear" {` | `test "selection baseline: start/update/finish/clear" {` |
| `test "M9-FX-007: reset boundary - clear does not change screen" {` | `test "reset baseline: clear does not change screen" {` |
| `test "M9-FX-007: reset boundary - reset preserves screen" {` | `test "reset baseline: reset preserves screen" {` |
| `test "M9-FX-007: reset boundary - resetScreen clears screen" {` | `test "reset baseline: resetScreen clears screen" {` |
| `test "M9-FX-008: encode interleave - encodeKey mixed with feed/apply" {` | `test "encode interleave: encodeKey mixed with feed/apply" {` |
| `test "M9-FX-008: encode interleave - encodeMouse with state checks" {` | `test "encode interleave: encodeMouse with state checks" {` |
| `test "M9-FX-009: snapshot stability - repeated captures across mixed ops" {` | `test "snapshot stability: repeated captures across mixed operations" {` |
| `test "M10-E1: M10-FX-001 burst feed/apply stress loop" {` | `test "stress loop: burst feed/apply" {` |
| `test "M10-E1: M10-FX-002 mixed reset boundary stress under load" {` | `test "stress loop: mixed reset boundary under load" {` |
| `test "M10-E2: M10-FX-003 selection/history drift loop (soak)" {` | `test "stress loop: selection and history drift" {` |
| `test "M10-E1: M10-FX-004 encode interleave stress" {` | `test "stress loop: encode interleave" {` |
| `test "M10-E2: M10-FX-005 snapshot drift loop (soak)" {` | `test "stress loop: snapshot drift" {` |
| `test "M10-E2: M10-FX-006 mode toggle soak with assertions" {` | `test "stress loop: mode toggle assertions" {` |
| `test "M10-E3: drift detection - mixed selection/history operations (E3 class)" {` | `test "drift detection: mixed selection and history operations" {` |
| `test "M10-E3: drift detection - encode operations preserve state invariants (E3 class)" {` | `test "drift detection: encode operations preserve state invariants" {` |
| `test "M10-E3: drift detection - reset boundary invariants (E3 class)" {` | `test "drift detection: reset boundary invariants" {` |
