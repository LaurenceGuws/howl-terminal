//! Responsibility: define model value types and constants.
//! Ownership: model core data-shape authority.
//! Reason: keep runtime/parser shared representations deterministic.

pub const CursorPos = struct {
    row: usize,
    col: usize,
};

pub const CursorShape = enum {
    block,
    underline,
    bar,
};

pub const CursorStyle = struct {
    shape: CursorShape,
    blink: bool,
};

pub const default_cursor_style = CursorStyle{ .shape = .block, .blink = true };

const selection_mod = @import("selection.zig");

pub const SelectionPos = selection_mod.SelectionPos;

pub const TerminalSelection = selection_mod.TerminalSelection;

pub const Cell = struct {
    codepoint: u32,
    combining_len: u8 = 0,
    combining: [2]u32 = .{ 0, 0 },
    width: u8 = 1,
    height: u8 = 1,
    x: u8 = 0,
    y: u8 = 0,
    attrs: CellAttrs,
};

pub fn isCellContinuation(cell: Cell) bool {
    return cell.x != 0 or cell.y != 0;
}

pub fn isMultiRowCellRoot(cell: Cell) bool {
    return cell.height > 1 and cell.x == 0 and cell.y == 0;
}

pub const CellAttrs = struct {
    fg: Color,
    bg: Color,
    bold: bool,
    blink: bool,
    blink_fast: bool,
    reverse: bool,
    underline: bool,
    underline_color: Color,
    link_id: u32,
};

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8 = 255,
};

pub const Key = u32;

pub const Modifier = u8;

pub const PhysicalKey = u32;

pub const KeyboardAlternateMetadata = struct {
    physical_key: ?PhysicalKey = null,

    produced_text_utf8: ?[]const u8 = null,

    base_codepoint: ?u32 = null,
    shifted_codepoint: ?u32 = null,
    alternate_layout_codepoint: ?u32 = null,

    text_is_composed: bool = false,
};

pub const MouseButton = enum(u8) {
    none = 0,
    left = 1,
    middle = 2,
    right = 3,
    wheel_up = 4,
    wheel_down = 5,
};

pub const MouseEventKind = enum(u8) {
    press,
    release,
    move,
    wheel,
};

pub const MouseEvent = struct {
    kind: MouseEventKind,
    button: MouseButton,
    row: i32,
    col: u16,
    pixel_x: ?u32 = null,
    pixel_y: ?u32 = null,
    mod: Modifier,
    buttons_down: u8,
};

pub const VTERM_KEY_NONE: Key = 0;

pub const VTERM_KEY_ENTER: Key = 1;

pub const VTERM_KEY_TAB: Key = 2;

pub const VTERM_KEY_BACKSPACE: Key = 3;

pub const VTERM_KEY_ESCAPE: Key = 4;

pub const VTERM_KEY_UP: Key = 5;

pub const VTERM_KEY_DOWN: Key = 6;

pub const VTERM_KEY_LEFT: Key = 7;

pub const VTERM_KEY_RIGHT: Key = 8;

pub const VTERM_KEY_INS: Key = 9;

pub const VTERM_KEY_DEL: Key = 10;

pub const VTERM_KEY_HOME: Key = 11;

pub const VTERM_KEY_END: Key = 12;

pub const VTERM_KEY_PAGEUP: Key = 13;

pub const VTERM_KEY_PAGEDOWN: Key = 14;

pub const VTERM_KEY_LEFT_SHIFT: Key = 15;

pub const VTERM_KEY_RIGHT_SHIFT: Key = 16;

pub const VTERM_KEY_LEFT_CTRL: Key = 17;

pub const VTERM_KEY_RIGHT_CTRL: Key = 18;

pub const VTERM_KEY_LEFT_ALT: Key = 19;

pub const VTERM_KEY_RIGHT_ALT: Key = 20;

pub const VTERM_KEY_LEFT_SUPER: Key = 21;

pub const VTERM_KEY_RIGHT_SUPER: Key = 22;

pub const VTERM_KEY_F1: Key = 23;

pub const VTERM_KEY_F2: Key = 24;

pub const VTERM_KEY_F3: Key = 25;

pub const VTERM_KEY_F4: Key = 26;

pub const VTERM_KEY_F5: Key = 27;

pub const VTERM_KEY_F6: Key = 28;

pub const VTERM_KEY_F7: Key = 29;

pub const VTERM_KEY_F8: Key = 30;

pub const VTERM_KEY_F9: Key = 31;

pub const VTERM_KEY_F10: Key = 32;

pub const VTERM_KEY_F11: Key = 33;

pub const VTERM_KEY_F12: Key = 34;

pub const VTERM_MOD_NONE: Modifier = 0;

pub const VTERM_MOD_SHIFT: Modifier = 1;

pub const VTERM_MOD_ALT: Modifier = 2;

pub const VTERM_MOD_CTRL: Modifier = 4;

pub fn defaultCell() Cell {
    return Cell{
        .codepoint = 0,
        .width = 1,
        .attrs = CellAttrs{
            .fg = default_fg,
            .bg = default_bg,
            .bold = false,
            .blink = false,
            .blink_fast = false,
            .reverse = false,
            .underline = false,
            .underline_color = default_fg,
            .link_id = 0,
        },
    };
}

pub const default_fg = Color{ .r = 220, .g = 220, .b = 220 };

pub const default_bg = Color{ .r = 24, .g = 25, .b = 33 };

pub const default_underline_color = Color{ .r = 0, .g = 0, .b = 0, .a = 0 };

pub const default_cell_attrs = CellAttrs{
    .fg = default_fg,
    .bg = default_bg,
    .bold = false,
    .blink = false,
    .blink_fast = false,
    .reverse = false,
    .underline = false,
    .underline_color = default_underline_color,
    .link_id = 0,
};

pub const default_cell = Cell{
    .codepoint = 0,
    .attrs = default_cell_attrs,
};
