//! Responsibility: collect parser callbacks into owned event records.
//! Ownership: event bridge seam between parser and semantic layers.
//! Reason: isolate parser sink mechanics from downstream processing.

const std = @import("std");
const parser_mod = @import("../parser/parser.zig");
const stream_mod = @import("../parser/stream.zig");
const csi_mod = @import("../parser/csi.zig");

/// Parser-facing bridge event union.
pub const Event = union(enum) {
    text: []const u8,
    codepoint: u21,
    control: u8,
    style_change: struct {
        final: u8,
        params: [16]i32,
        param_count: u8,
        leader: u8,
        private: bool,
        intermediates: [csi_mod.max_intermediates]u8,
        intermediates_len: u8,
    },
    title_set: []const u8,
    invalid_sequence,
};

/// Owned event queue bridge for parser sink callbacks.
pub const Bridge = struct {
    allocator: std.mem.Allocator,
    arena: std.heap.ArenaAllocator,
    events: std.ArrayList(Event),

    /// Initialize bridge queue.
    pub fn init(allocator: std.mem.Allocator) Bridge {
        const arena = std.heap.ArenaAllocator.init(allocator);
        return .{
            .allocator = allocator,
            .arena = arena,
            .events = std.ArrayList(Event).initCapacity(allocator, 32) catch unreachable,
        };
    }

    /// Release bridge queue storage.
    pub fn deinit(self: *Bridge) void {
        self.clear();
        self.events.deinit(self.allocator);
        self.arena.deinit();
    }

    /// Return queued event count.
    pub fn len(self: *const Bridge) usize {
        return self.events.items.len;
    }

    /// Return true when queue is empty.
    pub fn isEmpty(self: *const Bridge) bool {
        return self.events.items.len == 0;
    }

    /// Clear queued events and free owned payloads.
    pub fn clear(self: *Bridge) void {
        self.events.clearRetainingCapacity();
        _ = self.arena.reset(.retain_capacity);
    }

    /// Drain queued events into destination list.
    pub fn drainInto(self: *Bridge, dest: *std.ArrayList(Event), dest_allocator: std.mem.Allocator) !void {
        try dest.appendSlice(dest_allocator, self.events.items);
        self.events.clearRetainingCapacity();
    }

    /// Build parser sink bound to this bridge.
    pub fn toSink(self: *Bridge) parser_mod.Sink {
        return .{
            .ptr = self,
            .onStreamEventFn = onStreamEvent,
            .onAsciiSliceFn = onAsciiSlice,
            .onCsiFn = onCsi,
            .onOscFn = onOsc,
            .onApcFn = onApc,
            .onDcsFn = onDcs,
            .onEscFinalFn = onEscFinal,
        };
    }

    fn onStreamEvent(ptr: *anyopaque, event: stream_mod.StreamEvent) void {
        const self: *Bridge = @ptrCast(@alignCast(ptr));
        const ce = switch (event) {
            .codepoint => |cp| Event{ .codepoint = cp },
            .control => |ctrl| Event{ .control = ctrl },
            .invalid => Event.invalid_sequence,
        };
        self.events.append(self.allocator, ce) catch {};
    }

    fn onAsciiSlice(ptr: *anyopaque, bytes: []const u8) void {
        const self: *Bridge = @ptrCast(@alignCast(ptr));
        if (self.events.items.len > 0) {
            const last = &self.events.items[self.events.items.len - 1];
            if (last.* == .text) {
                const prev = last.text;
                const merged = self.arena.allocator().alloc(u8, prev.len + bytes.len) catch return;
                @memcpy(merged[0..prev.len], prev);
                @memcpy(merged[prev.len..], bytes);
                last.* = Event{ .text = merged };
                return;
            }
        }
        const owned = self.arena.allocator().dupe(u8, bytes) catch return;
        self.events.append(self.allocator, Event{ .text = owned }) catch {};
    }

    fn onCsi(ptr: *anyopaque, action: csi_mod.CsiAction) void {
        const self: *Bridge = @ptrCast(@alignCast(ptr));
        self.events.append(self.allocator, Event{
            .style_change = .{
                .final = action.final,
                .params = action.params,
                .param_count = action.count,
                .leader = action.leader,
                .private = action.private,
                .intermediates = action.intermediates,
                .intermediates_len = action.intermediates_len,
            },
        }) catch {};
    }

    fn onOsc(ptr: *anyopaque, data: []const u8, term: parser_mod.OscTerminator) void {
        const self: *Bridge = @ptrCast(@alignCast(ptr));
        _ = term;
        const owned = self.arena.allocator().dupe(u8, data) catch return;
        self.events.append(self.allocator, Event{ .title_set = owned }) catch {};
    }

    fn onApc(_: *anyopaque, _: []const u8) void {}
    fn onDcs(_: *anyopaque, _: []const u8) void {}
    fn onEscFinal(_: *anyopaque, _: u8) void {}
};
