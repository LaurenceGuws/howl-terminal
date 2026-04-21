const std = @import("std");
const screen_mod = @import("terminal/terminal_screen_state.zig");
const semantic_mod = @import("terminal/parser_core_semantic_consumer.zig");

const ScreenState = screen_mod.ScreenState;
const SemanticEvent = semantic_mod.SemanticEvent;

test "screen_state: initial cursor is at origin" {
    const s = ScreenState.init(24, 80);
    try std.testing.expectEqual(@as(u16, 0), s.cursor_row);
    try std.testing.expectEqual(@as(u16, 0), s.cursor_col);
}

test "screen_state: cursor_up moves row up" {
    var s = ScreenState.init(24, 80);
    s.cursor_row = 5;
    s.apply(SemanticEvent{ .cursor_up = 3 });
    try std.testing.expectEqual(@as(u16, 2), s.cursor_row);
}

test "screen_state: cursor_up clamped at row 0" {
    var s = ScreenState.init(24, 80);
    s.cursor_row = 1;
    s.apply(SemanticEvent{ .cursor_up = 5 });
    try std.testing.expectEqual(@as(u16, 0), s.cursor_row);
}

test "screen_state: cursor_down moves row down" {
    var s = ScreenState.init(24, 80);
    s.cursor_row = 2;
    s.apply(SemanticEvent{ .cursor_down = 3 });
    try std.testing.expectEqual(@as(u16, 5), s.cursor_row);
}

test "screen_state: cursor_down clamped at last row" {
    var s = ScreenState.init(24, 80);
    s.cursor_row = 20;
    s.apply(SemanticEvent{ .cursor_down = 10 });
    try std.testing.expectEqual(@as(u16, 23), s.cursor_row);
}

test "screen_state: cursor_forward moves col right" {
    var s = ScreenState.init(24, 80);
    s.cursor_col = 10;
    s.apply(SemanticEvent{ .cursor_forward = 5 });
    try std.testing.expectEqual(@as(u16, 15), s.cursor_col);
}

test "screen_state: cursor_forward clamped at last col" {
    var s = ScreenState.init(24, 80);
    s.cursor_col = 75;
    s.apply(SemanticEvent{ .cursor_forward = 10 });
    try std.testing.expectEqual(@as(u16, 79), s.cursor_col);
}

test "screen_state: cursor_back moves col left" {
    var s = ScreenState.init(24, 80);
    s.cursor_col = 8;
    s.apply(SemanticEvent{ .cursor_back = 3 });
    try std.testing.expectEqual(@as(u16, 5), s.cursor_col);
}

test "screen_state: cursor_back clamped at col 0" {
    var s = ScreenState.init(24, 80);
    s.cursor_col = 2;
    s.apply(SemanticEvent{ .cursor_back = 10 });
    try std.testing.expectEqual(@as(u16, 0), s.cursor_col);
}

test "screen_state: cursor_position moves to absolute position" {
    var s = ScreenState.init(24, 80);
    s.apply(SemanticEvent{ .cursor_position = .{ .row = 10, .col = 40 } });
    try std.testing.expectEqual(@as(u16, 10), s.cursor_row);
    try std.testing.expectEqual(@as(u16, 40), s.cursor_col);
}

test "screen_state: cursor_position clamped when out of bounds" {
    var s = ScreenState.init(24, 80);
    s.apply(SemanticEvent{ .cursor_position = .{ .row = 100, .col = 200 } });
    try std.testing.expectEqual(@as(u16, 23), s.cursor_row);
    try std.testing.expectEqual(@as(u16, 79), s.cursor_col);
}

test "screen_state: cursor_up does not move col" {
    var s = ScreenState.init(24, 80);
    s.cursor_row = 5;
    s.cursor_col = 20;
    s.apply(SemanticEvent{ .cursor_up = 2 });
    try std.testing.expectEqual(@as(u16, 20), s.cursor_col);
}

test "screen_state: zero rows and cols do not panic" {
    var s = ScreenState.init(0, 0);
    s.apply(SemanticEvent{ .cursor_down = 5 });
    s.apply(SemanticEvent{ .cursor_forward = 5 });
    s.apply(SemanticEvent{ .cursor_position = .{ .row = 10, .col = 10 } });
    try std.testing.expectEqual(@as(u16, 0), s.cursor_row);
    try std.testing.expectEqual(@as(u16, 0), s.cursor_col);
}

test "screen_state: single-row single-col screen clamps all movement" {
    var s = ScreenState.init(1, 1);
    s.apply(SemanticEvent{ .cursor_down = 5 });
    s.apply(SemanticEvent{ .cursor_forward = 5 });
    try std.testing.expectEqual(@as(u16, 0), s.cursor_row);
    try std.testing.expectEqual(@as(u16, 0), s.cursor_col);
}
