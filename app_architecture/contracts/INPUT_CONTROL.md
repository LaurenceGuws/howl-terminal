# Input and Control Contract

`M4_INPUT_CONTROL_CONTRACT` — contract authority for input/control model and deterministic encoding.

Authority for host-neutral input event model, encoding ownership boundaries, and control byte generation.

Scope: keyboard input (logical key + modifiers), mouse events (position, button, modifiers), and control byte output for supported cases.

## Input Event Model

### Logical Key Representation

- **Key** (`u32`): abstract logical key identifier.
  - Mapping is platform-agnostic; no keycode tables or layout-dependent remapping within howl-terminal.
  - Host provides the logical key (e.g., VTERM_KEY_UP, VTERM_KEY_ENTER, or character codepoint).
  - Zig key constants defined in `src/model/types.zig` (VTERM_KEY_*).

### Modifiers

- **Modifier** (`u8`): bit flags for modifier state.
  - Bits: VTERM_MOD_SHIFT (1), VTERM_MOD_ALT (2), VTERM_MOD_CTRL (4).
  - VTERM_MOD_NONE = 0 (no modifiers).
  - Multiple modifiers can be combined (e.g., Ctrl+Alt = 6).
  - Host provides modifier state at the time of key press.

### Mouse Events

- **MouseButton** (enum): none, left, middle, right, wheel_up, wheel_down.
- **MouseEventKind** (enum): press, release, move, wheel.
- **MouseEvent** (struct):
  - kind: type of mouse event (press, release, move, wheel).
  - button: which button (or wheel direction for wheel events).
  - row, col: terminal cell position (0-based).
  - pixel_x, pixel_y: optional pixel offsets within cell (host-dependent, may be null).
  - mod: modifier state (shift, alt, ctrl bitmask).
  - buttons_down: bitmask of buttons currently held.

### Keyboard Metadata

- **KeyboardAlternateMetadata** (struct): optional extended keyboard event data.
  - physical_key: optional platform physical key identity (layout-aware, non-standard).
  - produced_text_utf8: optional UTF-8 text produced by the key event (useful for IME, compose sequences).
  - base_codepoint, shifted_codepoint, alternate_layout_codepoint: optional codepoints for kitty alternate-key reporting.
  - text_is_composed: boolean marking IME/compose output (when true, alternate inference may be suppressed).

## Encoding Ownership Boundary

### Host Responsibility

- Translate platform keyboard/mouse events to logical Key + Modifier representation.
- Provide keyboard metadata (physical key, produced text) if needed for alternate reporting.
- Manage IME, compose sequences, and layout-dependent input.
- Encode mouse events (click, move, wheel) from platform events to MouseEvent.
- Handle platform input dispatch (keyboard vs mouse, event ordering).

### Howl-Terminal Responsibility

- Accept logical Key + Modifier inputs only; no platform keycodes.
- Generate deterministic control byte sequences for supported key/modifier combinations.
- Emit mouse event reports in terminal protocol (SGR 1006, X11, etc.) if configured.
- Manage input interactions with terminal modes (paste mode, mouse mode, focus events).
- Preserve input determinism: equivalent logical key + modifier sequences produce identical output bytes.

### Non-Boundary (Out of Scope)

- Platform event schemas (X11 keysym, Win32 virtual keys, macOS keycodes).
- Keymap/layout tables (QWERTY, Dvorak, etc.).
- IME composition logic or input method frameworks.
- Clipboard, drag-drop, accessibility input.
- Platform-specific terminal mode negotiation.

## Control Byte Generation

### Supported Input Cases

- **Printable Characters** (via Key as codepoint): output the character as UTF-8.
- **Special Keys** (VTERM_KEY_ENTER, VTERM_KEY_BACKSPACE, VTERM_KEY_TAB, etc.): output canonical escape sequences.
- **Cursor Keys** with modifiers (Ctrl+Up, Alt+Down, Shift+Left, etc.): output modified escape sequences per terminal protocol.
- **Function Keys** (F1–F12, etc.): output function key escape sequences, modified by Shift/Alt/Ctrl.

### Determinism Rule (M4-B1 Closure)

**Encoding is deterministic and fully mode-agnostic for keyboard input:**

- For a given Key + Modifier combination, `encodeKey()` must output the same control byte sequence every time.
- No runtime mode state (paste mode, focus mode, etc.) affects keyboard encoding output.
- Keyboard output is independent of terminal screen state, cursor position, or any application mode.

**Mouse reporting is mode-aware but deterministic:**

- `encodeMouse()` output depends on current mouse-report mode (SGR 1006, X11, or disabled).
- Mode is read-only state during encoding (no side effects); output is deterministic for a given mode.
- If mouse mode changes between calls, output may differ; this is not "context-dependent" but "mode-dependent" (intentional).
- Mode state is configured orthogonally via existing SEMANTIC_SCREEN contracts, not INPUT_CONTROL.

**Implementation note:**
- Encoding does not consume mode state or trigger mode changes.
- Encoding functions never call `reset()`, `resetScreen()`, or mutate screen/parser/history.
- Determinism is validated by parity tests: same input (key/mod or event/mode) always produces same output.

### Unsupported Cases

- Platform-specific keycodes or layout-dependent remapping.
- Media keys, vendor-specific keys, or non-standard key codes.
- Compose sequence completion or IME event filtering.
- Clipboard paste encoding (paste data is handled separately, not as key input).

## Interaction with Frozen M1-M3 Contracts

### Mode Effects on Input Encoding (M4-B1)

**Keyboard encoding (`encodeKey`) is mode-independent:**
- Ignores all terminal modes (mouse mode, paste mode, focus mode, application keypad, etc.)
- Output is identical regardless of current mode state.
- Mode state does NOT control keyboard output.

**Mouse encoding (`encodeMouse`) is mode-dependent:**
- Reads current mouse-report mode (SGR 1006 vs X11 vs disabled) as read-only input.
- Returns different byte sequences depending on mode, but deterministically for a given mode.
- Mouse mode is configured via SEMANTIC_SCREEN.md mode contracts, not here.

**Reset and Mode State:**
- `reset()` (parser reset) resets parser state, does NOT reset terminal modes or affect input encoding.
- `resetScreen()` (screen reset) resets visible screen, does NOT reset terminal modes or affect input encoding.
- Input encoding functions never call `reset()` or `resetScreen()`.

**Mode Interactions NOT in M4 Scope:**
- Input does not trigger mode changes (e.g., auto-switching to mouse mode on key press).
- Input does not depend on focus state, selection mode, or application keypad mode.
- Paste mode affects how data is fed (not encoded by input functions).
- Input provides raw key/mouse events; mode interpretation is downstream (in parser/screen).

### Selection and History

- Input operations do **not** affect selection state or history retention.
- Mouse input may reference history (negative row indices) if selection mode is active, but does not directly modify history.

## Breaking Change Rule

A change is breaking if:

1. Key or Modifier representation changes.
2. Supported input cases change without explicit contract update.
3. Control byte generation becomes non-deterministic or context-dependent.
4. Mouse event structure changes.
5. Input operations begin mutating screen or parser state.
6. Input begins requiring platform-specific keycodes or layouts.

## Breaking Change Approval

Required for any breaking change:

- Explicit mention in commit message (`BREAKING: ...`).
- Rationale describing necessity.
- Update this contract document.
- Update MODEL_API.md and RUNTIME_API.md if method signatures change.
- Update M4 relay tests if control byte output changes.

## Implementation Coverage (M4-A2)

### Currently Covered

**Printable Characters**
- ASCII printable range (32-126): output single byte as-is.
- High codepoints (>127): encode as UTF-8 bytes.

**Special Keys**
- VTERM_KEY_ENTER: output `\r` (carriage return).
- VTERM_KEY_ESCAPE: output `\x1b` (escape).
- VTERM_KEY_TAB: output `\t`; with Shift output CSI Z (shift-tab).
- VTERM_KEY_BACKSPACE: output `\x7f` (delete).

**Cursor Keys**
- VTERM_KEY_UP, DOWN, LEFT, RIGHT: output CSI sequences (A, B, D, C).
- With any modifier (Shift, Alt, Ctrl): output CSI 1 ; (1+mod) letter format.
  - Modifier parameter: 1+shift=2, 1+alt=3, 1+ctrl=5, combinations add (e.g. 1+shift+alt=4).

**Extended Keys** (M4-B2)
- VTERM_KEY_HOME: output `CSI H`; with modifiers output `CSI 1 ; (1+mod) H`.
- VTERM_KEY_END: output `CSI F`; with modifiers output `CSI 1 ; (1+mod) F`.
- VTERM_KEY_INS: output `CSI 2 ~`; with modifiers output `CSI 2 ; (1+mod) ~`.
- VTERM_KEY_DEL: output `CSI 3 ~`; with modifiers output `CSI 3 ; (1+mod) ~`.
- VTERM_KEY_PAGEUP: output `CSI 5 ~`; with modifiers output `CSI 5 ; (1+mod) ~`.
- VTERM_KEY_PAGEDOWN: output `CSI 6 ~`; with modifiers output `CSI 6 ; (1+mod) ~`.

**Determinism Guarantees**
- encodeKey(key, mod) returns identical bytes for identical inputs.
- encodeMouse currently returns empty slice (placeholder for future mouse reporting).
- No context-dependent encoding; reset/resetScreen do not affect encoding output.
- Input operations do not mutate parser, screen, history, or selection state.

### Future Coverage (Post-M4-B2)

- Function keys (F1-F12) with modifiers (M4-B3).
- Mouse event reporting (SGR 1006, X11 formats).
- Mode-dependent behaviors (paste mode, application keypad).

## Non-Goals

- Grapheme clustering, combining marks, or Unicode normalization.
- Right-to-left (RTL) or complex script input handling.
- Voice input, eye-gaze, or gesture recognition.
- Accessibility event filtering or specialized input modes (e.g., switch access).
- Session recording, input playback, or macro recording infrastructure.
- IME pre-edit text or candidate list rendering.
