const std = @import("std");

pub const SelectionPos = struct {
    row: i32,
    col: u16,
};

pub const TerminalSelection = struct {
    active: bool,
    selecting: bool,
    start: SelectionPos,
    end: SelectionPos,
};

pub const SelectionState = struct {
    selection: TerminalSelection,

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

    pub fn clear(self: *SelectionState) void {
        self.selection.active = false;
        self.selection.selecting = false;
    }

    pub fn start(self: *SelectionState, row: i32, col: u16) void {
        self.selection.active = true;
        self.selection.selecting = true;
        self.selection.start = .{ .row = row, .col = col };
        self.selection.end = .{ .row = row, .col = col };
    }

    pub fn update(self: *SelectionState, row: i32, col: u16) void {
        if (!self.selection.active) return;
        self.selection.end = .{ .row = row, .col = col };
    }

    pub fn finish(self: *SelectionState) void {
        if (!self.selection.active) return;
        self.selection.selecting = false;
    }

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
