//! Responsibility: hold terminal selection state and transitions.
//! Ownership: terminal model selection primitive.
//! Reason: keep selection behavior explicit and independent from UI/runtime layers.

const std = @import("std");

/// Row/column position used by selection endpoints.
/// Row is signed to support history coordinates (negative = history, non-negative = viewport).
/// Col is always in viewport range [0, cols-1].
pub const SelectionPos = struct {
    row: i32,
    col: u16,
};

/// Active selection bounds and lifecycle flags.
pub const TerminalSelection = struct {
    active: bool,
    selecting: bool,
    start: SelectionPos,
    end: SelectionPos,
};

/// Selection lifecycle operations for begin/update/finish/clear flows.
pub const SelectionState = struct {
    selection: TerminalSelection,

    /// Create an inactive selection state at origin.
    pub fn init() SelectionState {
        return .{
            .selection = .{
                .active = false,
                .selecting = false,
                .start = .{ .row = 0, .col = 0 },
                .end = .{ .row = 0, .col = 0 },
            },
        };
    }

    /// Clear current selection and mark selection as inactive.
    pub fn clear(self: *SelectionState) void {
        self.selection.active = false;
        self.selection.selecting = false;
    }

    /// Begin a new selection at `row`/`col`.
    /// Row can be negative (history) or non-negative (viewport).
    /// Col is always in viewport range.
    pub fn start(self: *SelectionState, row: i32, col: u16) void {
        self.selection.active = true;
        self.selection.selecting = true;
        self.selection.start = .{ .row = row, .col = col };
        self.selection.end = .{ .row = row, .col = col };
    }

    /// Update the selection end position while selection is active.
    /// Row can be negative (history) or non-negative (viewport).
    /// Col is always in viewport range.
    pub fn update(self: *SelectionState, row: i32, col: u16) void {
        if (!self.selection.active) return;
        self.selection.end = .{ .row = row, .col = col };
    }

    /// Mark active selection as finished.
    pub fn finish(self: *SelectionState) void {
        if (!self.selection.active) return;
        self.selection.selecting = false;
    }

    /// Return current selection when active; otherwise return `null`.
    pub fn state(self: *const SelectionState) ?TerminalSelection {
        if (!self.selection.active) return null;
        return self.selection;
    }
};

test "selection: start in viewport coordinates" {
    var s = SelectionState.init();
    s.start(5, 10);
    const sel = s.state().?;
    try std.testing.expectEqual(@as(i32, 5), sel.start.row);
    try std.testing.expectEqual(@as(u16, 10), sel.start.col);
    try std.testing.expect(sel.active);
    try std.testing.expect(sel.selecting);
}

test "selection: start in history coordinates" {
    var s = SelectionState.init();
    s.start(-3, 7);
    const sel = s.state().?;
    try std.testing.expectEqual(@as(i32, -3), sel.start.row);
    try std.testing.expectEqual(@as(u16, 7), sel.start.col);
}

test "selection: update spanning viewport and history" {
    var s = SelectionState.init();
    s.start(-1, 0);
    s.update(5, 20);
    const sel = s.state().?;
    try std.testing.expectEqual(@as(i32, -1), sel.start.row);
    try std.testing.expectEqual(@as(i32, 5), sel.end.row);
    try std.testing.expectEqual(@as(u16, 20), sel.end.col);
}

test "selection: inactive returns null" {
    var s = SelectionState.init();
    try std.testing.expectEqual(@as(?TerminalSelection, null), s.state());
}
