const std = @import("std");
const parser_mod = @import("parser/parser.zig");
const bridge_mod = @import("event/bridge.zig");

test "parser_core_event_bridge: maps ASCII text to core text event" {
    const gpa = std.testing.allocator;
    var bridge = bridge_mod.ParserCoreBridge.init(gpa);
    defer bridge.deinit();

    var parser = try parser_mod.Parser.init(gpa, bridge.toSink());
    defer parser.deinit();

    parser.handleSlice("hello");

    try std.testing.expectEqual(@as(usize, 1), bridge.events.items.len);
    try std.testing.expect(bridge.events.items[0] == .text);
    try std.testing.expectEqualSlices(u8, "hello", bridge.events.items[0].text);
}

test "parser_core_event_bridge: maps UTF-8 codepoint to core codepoint event" {
    const gpa = std.testing.allocator;
    var bridge = bridge_mod.ParserCoreBridge.init(gpa);
    defer bridge.deinit();

    var parser = try parser_mod.Parser.init(gpa, bridge.toSink());
    defer parser.deinit();

    parser.handleSlice("\xC3\xA9");

    try std.testing.expectEqual(@as(usize, 1), bridge.events.items.len);
    try std.testing.expect(bridge.events.items[0] == .codepoint);
    try std.testing.expectEqual(@as(u21, 0xE9), bridge.events.items[0].codepoint);
}

test "parser_core_event_bridge: maps control byte to core control event" {
    const gpa = std.testing.allocator;
    var bridge = bridge_mod.ParserCoreBridge.init(gpa);
    defer bridge.deinit();

    var parser = try parser_mod.Parser.init(gpa, bridge.toSink());
    defer parser.deinit();

    parser.handleByte(0x07);

    try std.testing.expectEqual(@as(usize, 1), bridge.events.items.len);
    try std.testing.expect(bridge.events.items[0] == .control);
    try std.testing.expectEqual(@as(u8, 0x07), bridge.events.items[0].control);
}

test "parser_core_event_bridge: maps CSI sequence to core style_change event" {
    const gpa = std.testing.allocator;
    var bridge = bridge_mod.ParserCoreBridge.init(gpa);
    defer bridge.deinit();

    var parser = try parser_mod.Parser.init(gpa, bridge.toSink());
    defer parser.deinit();

    parser.handleSlice("\x1b[31m");

    try std.testing.expectEqual(@as(usize, 1), bridge.events.items.len);
    try std.testing.expect(bridge.events.items[0] == .style_change);
    try std.testing.expectEqual(@as(u8, 'm'), bridge.events.items[0].style_change.final);
    try std.testing.expectEqual(@as(i32, 31), bridge.events.items[0].style_change.params[0]);
    try std.testing.expectEqual(@as(u8, 0), bridge.events.items[0].style_change.param_count);
}

test "parser_core_event_bridge: maps OSC to core title_set event" {
    const gpa = std.testing.allocator;
    var bridge = bridge_mod.ParserCoreBridge.init(gpa);
    defer bridge.deinit();

    var parser = try parser_mod.Parser.init(gpa, bridge.toSink());
    defer parser.deinit();

    parser.handleSlice("\x1b]My Window\x07");

    try std.testing.expectEqual(@as(usize, 1), bridge.events.items.len);
    try std.testing.expect(bridge.events.items[0] == .title_set);
    try std.testing.expectEqualSlices(u8, "My Window", bridge.events.items[0].title_set);
}

test "parser_core_event_bridge: mixed sequence produces ordered events" {
    const gpa = std.testing.allocator;
    var bridge = bridge_mod.ParserCoreBridge.init(gpa);
    defer bridge.deinit();

    var parser = try parser_mod.Parser.init(gpa, bridge.toSink());
    defer parser.deinit();

    parser.handleSlice("text\x1b[1m");

    try std.testing.expectEqual(@as(usize, 2), bridge.events.items.len);
    try std.testing.expect(bridge.events.items[0] == .text);
    try std.testing.expectEqualSlices(u8, "text", bridge.events.items[0].text);
    try std.testing.expect(bridge.events.items[1] == .style_change);
    try std.testing.expectEqual(@as(u8, 'm'), bridge.events.items[1].style_change.final);
}

test "parser_core_event_bridge: multi-param CSI captures all params up to count" {
    const gpa = std.testing.allocator;
    var bridge = bridge_mod.ParserCoreBridge.init(gpa);
    defer bridge.deinit();

    var parser = try parser_mod.Parser.init(gpa, bridge.toSink());
    defer parser.deinit();

    parser.handleSlice("\x1b[1;31;40m");

    try std.testing.expectEqual(@as(usize, 1), bridge.events.items.len);
    try std.testing.expect(bridge.events.items[0] == .style_change);
    try std.testing.expectEqual(@as(i32, 1), bridge.events.items[0].style_change.params[0]);
    try std.testing.expectEqual(@as(i32, 31), bridge.events.items[0].style_change.params[1]);
    try std.testing.expectEqual(@as(i32, 40), bridge.events.items[0].style_change.params[2]);
    try std.testing.expectEqual(@as(u8, 2), bridge.events.items[0].style_change.param_count);
}
