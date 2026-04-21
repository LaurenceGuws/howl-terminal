const std = @import("std");
const pipeline_mod = @import("terminal/parser_core_event_pipeline.zig");
const screen_mod = @import("terminal/terminal_screen_state.zig");

fn feed(pl: *pipeline_mod.Pipeline, screen: *screen_mod.ScreenState, bytes: []const u8) void {
    pl.feedSlice(bytes);
    pl.applyToScreen(screen);
}

fn feedByte(pl: *pipeline_mod.Pipeline, screen: *screen_mod.ScreenState, byte: u8) void {
    pl.feedByte(byte);
    pl.applyToScreen(screen);
}

test "replay: CUU moves cursor up" {
    const gpa = std.testing.allocator;
    var pl = try pipeline_mod.Pipeline.init(gpa);
    defer pl.deinit();
    var screen = screen_mod.ScreenState.init(24, 80);
    screen.cursor_row = 10;

    feed(&pl, &screen, "\x1b[3A");

    try std.testing.expectEqual(@as(u16, 7), screen.cursor_row);
}

test "replay: CUD moves cursor down" {
    const gpa = std.testing.allocator;
    var pl = try pipeline_mod.Pipeline.init(gpa);
    defer pl.deinit();
    var screen = screen_mod.ScreenState.init(24, 80);
    screen.cursor_row = 5;

    feed(&pl, &screen, "\x1b[4B");

    try std.testing.expectEqual(@as(u16, 9), screen.cursor_row);
}

test "replay: CUF moves cursor forward" {
    const gpa = std.testing.allocator;
    var pl = try pipeline_mod.Pipeline.init(gpa);
    defer pl.deinit();
    var screen = screen_mod.ScreenState.init(24, 80);
    screen.cursor_col = 10;

    feed(&pl, &screen, "\x1b[5C");

    try std.testing.expectEqual(@as(u16, 15), screen.cursor_col);
}

test "replay: CUB moves cursor back" {
    const gpa = std.testing.allocator;
    var pl = try pipeline_mod.Pipeline.init(gpa);
    defer pl.deinit();
    var screen = screen_mod.ScreenState.init(24, 80);
    screen.cursor_col = 20;

    feed(&pl, &screen, "\x1b[6D");

    try std.testing.expectEqual(@as(u16, 14), screen.cursor_col);
}

test "replay: CUP absolute move" {
    const gpa = std.testing.allocator;
    var pl = try pipeline_mod.Pipeline.init(gpa);
    defer pl.deinit();
    var screen = screen_mod.ScreenState.init(24, 80);

    feed(&pl, &screen, "\x1b[5;20H");

    try std.testing.expectEqual(@as(u16, 4), screen.cursor_row);
    try std.testing.expectEqual(@as(u16, 19), screen.cursor_col);
}

test "replay: CUP no params moves to origin" {
    const gpa = std.testing.allocator;
    var pl = try pipeline_mod.Pipeline.init(gpa);
    defer pl.deinit();
    var screen = screen_mod.ScreenState.init(24, 80);
    screen.cursor_row = 10;
    screen.cursor_col = 40;

    feed(&pl, &screen, "\x1b[H");

    try std.testing.expectEqual(@as(u16, 0), screen.cursor_row);
    try std.testing.expectEqual(@as(u16, 0), screen.cursor_col);
}

test "replay: split CSI across multiple feeds" {
    const gpa = std.testing.allocator;
    var pl = try pipeline_mod.Pipeline.init(gpa);
    defer pl.deinit();
    var screen = screen_mod.ScreenState.init(24, 80);
    screen.cursor_row = 10;

    pl.feedSlice("\x1b[");
    pl.feedSlice("2");
    pl.feedSlice("A");
    pl.applyToScreen(&screen);

    try std.testing.expectEqual(@as(u16, 8), screen.cursor_row);
}

test "replay: reset clears events and screen reflects only post-reset input" {
    const gpa = std.testing.allocator;
    var pl = try pipeline_mod.Pipeline.init(gpa);
    defer pl.deinit();
    var screen = screen_mod.ScreenState.init(24, 80);
    screen.cursor_row = 10;

    pl.feedSlice("\x1b[5A");
    pl.reset();
    pl.applyToScreen(&screen);

    try std.testing.expectEqual(@as(u16, 10), screen.cursor_row);

    feed(&pl, &screen, "\x1b[2B");
    try std.testing.expectEqual(@as(u16, 12), screen.cursor_row);
}

test "replay: invalid UTF-8 does not corrupt cursor state" {
    const gpa = std.testing.allocator;
    var pl = try pipeline_mod.Pipeline.init(gpa);
    defer pl.deinit();
    var screen = screen_mod.ScreenState.init(24, 80);
    screen.cursor_row = 5;
    screen.cursor_col = 10;

    feed(&pl, &screen, "\x80\xFE");

    try std.testing.expectEqual(@as(u16, 5), screen.cursor_row);
    try std.testing.expectEqual(@as(u16, 10), screen.cursor_col);
}

test "replay: unsupported CSI does not corrupt cursor state" {
    const gpa = std.testing.allocator;
    var pl = try pipeline_mod.Pipeline.init(gpa);
    defer pl.deinit();
    var screen = screen_mod.ScreenState.init(24, 80);
    screen.cursor_row = 5;
    screen.cursor_col = 10;

    feed(&pl, &screen, "\x1b[1m\x1b[0m");

    try std.testing.expectEqual(@as(u16, 5), screen.cursor_row);
    try std.testing.expectEqual(@as(u16, 10), screen.cursor_col);
}

test "replay: clamping at screen boundaries" {
    const gpa = std.testing.allocator;
    var pl = try pipeline_mod.Pipeline.init(gpa);
    defer pl.deinit();
    var screen = screen_mod.ScreenState.init(24, 80);

    feed(&pl, &screen, "\x1b[999A");
    try std.testing.expectEqual(@as(u16, 0), screen.cursor_row);

    feed(&pl, &screen, "\x1b[999B");
    try std.testing.expectEqual(@as(u16, 23), screen.cursor_row);

    feed(&pl, &screen, "\x1b[999D");
    try std.testing.expectEqual(@as(u16, 0), screen.cursor_col);

    feed(&pl, &screen, "\x1b[999C");
    try std.testing.expectEqual(@as(u16, 79), screen.cursor_col);
}

test "replay: sequence of moves composes correctly" {
    const gpa = std.testing.allocator;
    var pl = try pipeline_mod.Pipeline.init(gpa);
    defer pl.deinit();
    var screen = screen_mod.ScreenState.init(24, 80);

    feed(&pl, &screen, "\x1b[10;10H");
    try std.testing.expectEqual(@as(u16, 9), screen.cursor_row);
    try std.testing.expectEqual(@as(u16, 9), screen.cursor_col);

    feed(&pl, &screen, "\x1b[2A");
    try std.testing.expectEqual(@as(u16, 7), screen.cursor_row);

    feed(&pl, &screen, "\x1b[5C");
    try std.testing.expectEqual(@as(u16, 14), screen.cursor_col);

    feed(&pl, &screen, "\x1b[H");
    try std.testing.expectEqual(@as(u16, 0), screen.cursor_row);
    try std.testing.expectEqual(@as(u16, 0), screen.cursor_col);
}
