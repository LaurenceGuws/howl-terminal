const std = @import("std");

pub const parser = @import("parser/parser.zig");

pub const pipeline = @import("event/pipeline.zig");

pub const semantic = @import("event/semantic.zig");

pub const screen = @import("screen/state.zig");

pub const model = @import("model.zig");

pub const runtime = @import("runtime/engine.zig");

comptime {
    _ = @import("test/relay.zig");
}

test "root: exposes M1 host-neutral module surface" {
    try std.testing.expect(@hasDecl(@This(), "parser"));
    try std.testing.expect(@hasDecl(@This(), "pipeline"));
    try std.testing.expect(@hasDecl(@This(), "semantic"));
    try std.testing.expect(@hasDecl(@This(), "screen"));
    try std.testing.expect(@hasDecl(@This(), "model"));
    try std.testing.expect(@hasDecl(@This(), "runtime"));
}

test "root: runtime Engine exposes frozen M1 facade methods" {
    const Engine = runtime.Engine;
    try std.testing.expect(@hasDecl(Engine, "init"));
    try std.testing.expect(@hasDecl(Engine, "initWithCells"));
    try std.testing.expect(@hasDecl(Engine, "deinit"));
    try std.testing.expect(@hasDecl(Engine, "feedByte"));
    try std.testing.expect(@hasDecl(Engine, "feedSlice"));
    try std.testing.expect(@hasDecl(Engine, "apply"));
    try std.testing.expect(@hasDecl(Engine, "clear"));
    try std.testing.expect(@hasDecl(Engine, "reset"));
    try std.testing.expect(@hasDecl(Engine, "resetScreen"));
    try std.testing.expect(@hasDecl(Engine, "screen"));
    try std.testing.expect(@hasDecl(Engine, "queuedEventCount"));
}

test "root: runtime Engine method signatures remain host-facing" {
    const Engine = runtime.Engine;
    const Allocator = std.mem.Allocator;
    const ScreenState = screen.ScreenState;
    const init_fn: fn (Allocator, u16, u16) anyerror!Engine = Engine.init;
    const init_cells_fn: fn (Allocator, u16, u16) anyerror!Engine = Engine.initWithCells;
    const deinit_fn: fn (*Engine) void = Engine.deinit;
    const feed_byte_fn: fn (*Engine, u8) void = Engine.feedByte;
    const feed_slice_fn: fn (*Engine, []const u8) void = Engine.feedSlice;
    const apply_fn: fn (*Engine) void = Engine.apply;
    const clear_fn: fn (*Engine) void = Engine.clear;
    const reset_fn: fn (*Engine) void = Engine.reset;
    const reset_screen_fn: fn (*Engine) void = Engine.resetScreen;
    const screen_fn: fn (*const Engine) *const ScreenState = Engine.screen;
    const queue_fn: fn (*const Engine) usize = Engine.queuedEventCount;
    _ = .{ init_fn, init_cells_fn, deinit_fn, feed_byte_fn, feed_slice_fn, apply_fn, clear_fn, reset_fn, reset_screen_fn, screen_fn, queue_fn };
}
