const std = @import("std");
const semantic_mod = @import("../event/semantic.zig");

pub const SemanticEvent = semantic_mod.SemanticEvent;

pub const ScreenState = struct {
    rows: u16,
    cols: u16,
    cursor_row: u16,
    cursor_col: u16,
    cells: ?[]u21,

    pub fn init(rows: u16, cols: u16) ScreenState {
        return .{ .rows = rows, .cols = cols, .cursor_row = 0, .cursor_col = 0, .cells = null };
    }

    pub fn initWithCells(allocator: std.mem.Allocator, rows: u16, cols: u16) !ScreenState {
        const size = @as(usize, rows) * @as(usize, cols);
        const cells: ?[]u21 = if (size > 0) blk: {
            const buf = try allocator.alloc(u21, size);
            @memset(buf, 0);
            break :blk buf;
        } else null;
        return .{ .rows = rows, .cols = cols, .cursor_row = 0, .cursor_col = 0, .cells = cells };
    }

    pub fn deinit(self: *ScreenState, allocator: std.mem.Allocator) void {
        if (self.cells) |c| allocator.free(c);
        self.cells = null;
    }

    pub fn cellAt(self: *const ScreenState, row: u16, col: u16) u21 {
        const c = self.cells orelse return 0;
        if (row >= self.rows or col >= self.cols) return 0;
        return c[@as(usize, row) * self.cols + col];
    }

    pub fn apply(self: *ScreenState, event: SemanticEvent) void {
        switch (event) {
            .cursor_up => |n| self.cursor_row = self.cursor_row -| n,
            .cursor_down => |n| self.cursor_row = @min(self.cursor_row +| n, self.rows -| 1),
            .cursor_forward => |n| self.cursor_col = @min(self.cursor_col +| n, self.cols -| 1),
            .cursor_back => |n| self.cursor_col = self.cursor_col -| n,
            .cursor_position => |pos| {
                self.cursor_row = @min(pos.row, self.rows -| 1);
                self.cursor_col = @min(pos.col, self.cols -| 1);
            },
            .write_text => |s| {
                for (s) |byte| {
                    self.writeCell(@intCast(byte));
                }
            },
            .write_codepoint => |cp| self.writeCell(cp),
            .line_feed => self.cursor_row = @min(self.cursor_row +| 1, self.rows -| 1),
            .carriage_return => self.cursor_col = 0,
            .backspace => self.cursor_col = self.cursor_col -| 1,
        }
    }

    fn writeCell(self: *ScreenState, cp: u21) void {
        if (self.cols == 0 or self.rows == 0) return;
        if (self.cells) |c| {
            c[@as(usize, self.cursor_row) * self.cols + self.cursor_col] = cp;
        }
        if (self.cursor_col < self.cols - 1) {
            self.cursor_col += 1;
        }
    }
};
