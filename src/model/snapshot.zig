//! Responsibility: capture and represent engine observable state snapshots.
//! Ownership: snapshot contract authority.
//! Reason: provide host-neutral read-only snapshots for replay and diagnostic access.

const std = @import("std");
const model_mod = @import("../model.zig");
const screen_mod = @import("../screen/state.zig");

/// Snapshot of engine observable state at a point in time.
pub const EngineSnapshot = struct {
    allocator: std.mem.Allocator,
    rows: u16,
    cols: u16,
    cursor_row: u16,
    cursor_col: u16,
    cursor_visible: bool,
    auto_wrap: bool,
    cells: ?[]u21,
    history: ?[]u21,
    history_count: u16,
    history_capacity: u16,
    history_write_idx: u16,
    selection: ?model_mod.TerminalSelection,

    /// Capture snapshot from engine observable state; allocates owned buffers.
    pub fn captureFromScreen(allocator: std.mem.Allocator, screen: *const screen_mod.ScreenState, selection: ?model_mod.TerminalSelection) !EngineSnapshot {
        var snapshot = EngineSnapshot{
            .allocator = allocator,
            .rows = screen.rows,
            .cols = screen.cols,
            .cursor_row = screen.cursor_row,
            .cursor_col = screen.cursor_col,
            .cursor_visible = screen.cursor_visible,
            .auto_wrap = screen.auto_wrap,
            .cells = null,
            .history = null,
            .history_count = screen.history_count,
            .history_capacity = screen.history_capacity,
            .history_write_idx = screen.history_write_idx,
            .selection = selection,
        };

        // Copy visible screen cells if present.
        if (screen.cells) |cells| {
            const size = @as(usize, screen.rows) * @as(usize, screen.cols);
            const owned_cells = try allocator.alloc(u21, size);
            @memcpy(owned_cells, cells);
            snapshot.cells = owned_cells;
        }

        // Copy history buffer if present.
        if (screen.history) |history| {
            const size = @as(usize, screen.history_capacity) * @as(usize, screen.cols);
            const owned_history = try allocator.alloc(u21, size);
            @memcpy(owned_history, history);
            snapshot.history = owned_history;
        }

        return snapshot;
    }

    /// Release owned buffers.
    pub fn deinit(self: *EngineSnapshot) void {
        if (self.cells) |c| self.allocator.free(c);
        self.cells = null;
        if (self.history) |h| self.allocator.free(h);
        self.history = null;
    }

    /// Return visible cell value by row and column.
    pub fn cellAt(self: *const EngineSnapshot, row: u16, col: u16) u21 {
        const c = self.cells orelse return 0;
        if (row >= self.rows or col >= self.cols) return 0;
        return c[@as(usize, row) * self.cols + col];
    }

    /// Return history cell by recency index and column.
    pub fn historyRowAt(self: *const EngineSnapshot, history_idx: u16, col: u16) u21 {
        const h = self.history orelse return 0;
        if (history_idx >= self.history_count or col >= self.cols) return 0;
        const cap = @as(usize, self.history_capacity);
        const newest_slot = (@as(usize, self.history_write_idx) + cap - 1) % cap;
        const logical_slot = (newest_slot + cap - @as(usize, history_idx)) % cap;
        return h[logical_slot * @as(usize, self.cols) + @as(usize, col)];
    }
};
