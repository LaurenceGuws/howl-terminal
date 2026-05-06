//! Responsibility: provide the vt-core package entry owner.
//! Ownership: primary embeddable terminal boundary.
//! Reason: expose one host-neutral terminal object while keeping domain internals behind sibling owners.

const std = @import("std");
const grid_owner = @import("grid.zig");
const grid_model = @import("grid/model.zig");
const input_mod = @import("input.zig");
const interpret_owner = @import("interpret.zig");
const selection_owner = @import("selection.zig");
const snapshot_owner = @import("snapshot.zig");

const GridNs = grid_owner.Grid;
const Input = input_mod.Input;
const Interpret = interpret_owner.Interpret;
const Selection = selection_owner.Selection;
const Snapshot = snapshot_owner.Snapshot;
const Color = GridNs.Color;

const ClipboardRequest = struct {
    raw: []u8,
};

pub const KittyShellMark = struct {
    kind: u8 = 0,
    status: ?i32 = null,
    metadata: []u8 = &[_]u8{},
};

pub const KittyNotificationRequest = struct {
    metadata: []u8,
    payload: []u8,
};

const KittyPointerShape = enum {
    alias,
    cell,
    copy,
    crosshair,
    @"default",
    e_resize,
    ew_resize,
    grab,
    grabbing,
    help,
    move,
    n_resize,
    ne_resize,
    nesw_resize,
    no_drop,
    not_allowed,
    ns_resize,
    nw_resize,
    nwse_resize,
    pointer,
    progress,
    s_resize,
    se_resize,
    sw_resize,
    text,
    vertical_text,
    w_resize,
    wait,
    zoom_in,
    zoom_out,
};

const KittyPointerShapeStack = struct {
    stack: [16]KittyPointerShape = undefined,
    len: u8 = 0,
};

pub const TerminalColorState = struct {
    foreground: Color = GridNs.default_fg,
    background: Color = GridNs.default_bg,
    cursor: ?Color = null,
    cursor_text: ?Color = null,
    selection_background: ?Color = null,
    selection_foreground: ?Color = null,
    palette: [256]Color = defaultPalette(),
};

const TerminalColorStack = struct {
    stack: [16]TerminalColorState = undefined,
    len: u8 = 0,
};

const SpecialColorKey = enum { foreground, background, cursor, cursor_text, selection_background, selection_foreground };

const KittyGraphicsImage = struct {
    image_id: u32,
    image_number: u32,
    format: u16,
    width: u32,
    height: u32,
    base64_payload: []u8,
};

const KittyGraphicsPlacement = struct {
    image_id: u32,
    placement_id: u32,
    row: u16,
    col: u16,
    columns: u32,
    rows: u32,
    z_index: i32,
};

const KittyGraphicsFrame = struct {
    image_id: u32,
    frame_number: u32,
    format: u16,
    width: u32,
    height: u32,
    base64_payload: []u8,
};

const KittyGraphicsUpload = struct {
    image_id: u32,
    image_number: u32,
    action: u8,
    format: u16,
    width: u32,
    height: u32,
    frame_number: u32,
    data: std.ArrayList(u8),
};

const KittyKeyboardStack = struct {
    flags: u32 = 0,
    stack: [16]u32 = [_]u32{0} ** 16,
    len: u8 = 0,
};

/// Host-neutral terminal facade.
pub const VtCore = struct {
    pub const DirtyRows = grid_model.DirtyRows;
    /// Host control signals routed to transport/runtime owner.
    pub const ControlSignal = enum {
        hangup,
        interrupt,
        terminate,
        resize_notify,
    };

    /// Key type alias exported by vt-core facade.
    pub const Key = Input.Key;
    /// Modifier type alias exported by vt-core facade.
    pub const Modifier = Input.Modifier;
    /// Mouse button type alias exported by vt-core facade.
    pub const MouseButton = Input.MouseButton;
    /// Mouse event kind alias exported by vt-core facade.
    pub const MouseEventKind = Input.MouseEventKind;

    /// No modifiers set.
    pub const mod_none: Modifier = Input.mod_none;
    /// Shift modifier bit.
    pub const mod_shift: Modifier = Input.mod_shift;
    /// Alt modifier bit.
    pub const mod_alt: Modifier = Input.mod_alt;
    /// Control modifier bit.
    pub const mod_ctrl: Modifier = Input.mod_ctrl;

    /// Enter key alias.
    pub const key_enter: Key = Input.key_enter;
    /// Tab key alias.
    pub const key_tab: Key = Input.key_tab;
    /// Backspace key alias.
    pub const key_backspace: Key = Input.key_backspace;
    /// Escape key alias.
    pub const key_escape: Key = Input.key_escape;
    /// Arrow up key alias.
    pub const key_up: Key = Input.key_up;
    /// Arrow down key alias.
    pub const key_down: Key = Input.key_down;
    /// Arrow left key alias.
    pub const key_left: Key = Input.key_left;
    /// Arrow right key alias.
    pub const key_right: Key = Input.key_right;
    /// Insert key alias.
    pub const key_insert: Key = Input.key_insert;
    /// Delete key alias.
    pub const key_delete: Key = Input.key_delete;
    /// Home key alias.
    pub const key_home: Key = Input.key_home;
    /// End key alias.
    pub const key_end: Key = Input.key_end;
    /// Page-up key alias.
    pub const key_pageup: Key = Input.key_pageup;
    /// Page-down key alias.
    pub const key_pagedown: Key = Input.key_pagedown;
    /// F1 key alias.
    pub const key_f1: Key = Input.key_f1;
    /// F2 key alias.
    pub const key_f2: Key = Input.key_f2;
    /// F3 key alias.
    pub const key_f3: Key = Input.key_f3;
    /// F4 key alias.
    pub const key_f4: Key = Input.key_f4;
    /// F5 key alias.
    pub const key_f5: Key = Input.key_f5;
    /// F6 key alias.
    pub const key_f6: Key = Input.key_f6;
    /// F7 key alias.
    pub const key_f7: Key = Input.key_f7;
    /// F8 key alias.
    pub const key_f8: Key = Input.key_f8;
    /// F9 key alias.
    pub const key_f9: Key = Input.key_f9;
    /// F10 key alias.
    pub const key_f10: Key = Input.key_f10;
    /// F11 key alias.
    pub const key_f11: Key = Input.key_f11;
    /// F12 key alias.
    pub const key_f12: Key = Input.key_f12;
    pub const key_kp_0: Key = Input.key_kp_0;
    pub const key_kp_1: Key = Input.key_kp_1;
    pub const key_kp_2: Key = Input.key_kp_2;
    pub const key_kp_3: Key = Input.key_kp_3;
    pub const key_kp_4: Key = Input.key_kp_4;
    pub const key_kp_5: Key = Input.key_kp_5;
    pub const key_kp_6: Key = Input.key_kp_6;
    pub const key_kp_7: Key = Input.key_kp_7;
    pub const key_kp_8: Key = Input.key_kp_8;
    pub const key_kp_9: Key = Input.key_kp_9;
    pub const key_kp_decimal: Key = Input.key_kp_decimal;
    pub const key_kp_add: Key = Input.key_kp_add;
    pub const key_kp_subtract: Key = Input.key_kp_subtract;
    pub const key_kp_multiply: Key = Input.key_kp_multiply;
    pub const key_kp_divide: Key = Input.key_kp_divide;
    pub const key_kp_enter: Key = Input.key_kp_enter;

    pub const mouse_button_none: MouseButton = Input.MouseButton.none;
    pub const mouse_button_left: MouseButton = Input.MouseButton.left;
    pub const mouse_button_middle: MouseButton = Input.MouseButton.middle;
    pub const mouse_button_right: MouseButton = Input.MouseButton.right;
    pub const mouse_button_wheel_up: MouseButton = Input.MouseButton.wheel_up;
    pub const mouse_button_wheel_down: MouseButton = Input.MouseButton.wheel_down;

    pub const mouse_press: MouseEventKind = Input.MouseEventKind.press;
    pub const mouse_release: MouseEventKind = Input.MouseEventKind.release;
    pub const mouse_move: MouseEventKind = Input.MouseEventKind.move;
    pub const mouse_wheel: MouseEventKind = Input.MouseEventKind.wheel;

    /// Read-only render-facing view of visible terminal state.
    pub const RenderView = struct {
        rows: u16,
        cols: u16,
        cursor_row: u16,
        cursor_col: u16,
        cursor_visible: bool,
        cursor_shape: GridNs.CursorShape,
        is_alternate_screen: bool,
        screen: *const GridNs.GridModel,

        pub fn cellAt(self: RenderView, row: u16, col: u16) u21 {
            return self.screen.cellAt(row, col);
        }

        pub fn cellInfoAt(self: RenderView, row: u16, col: u16) GridNs.Cell {
            return self.screen.cellInfoAt(row, col);
        }
    };

    const SavedDecMode = struct {
        mode: u16,
        state: u8,
    };

    allocator: std.mem.Allocator,
    pipeline: Interpret.Pipeline,
    primary_state: GridNs.GridModel,
    alt_state: GridNs.GridModel,
    alt_active: bool,
    saved_primary_cursor: ?struct {
        row: u16,
        col: u16,
        wrap_pending: bool,
        cursor_visible: bool,
    } = null,
    selection: Selection.SelectionState,
    application_cursor_keys: bool = false,
    application_keypad: bool = false,
    modify_other_keys: i8 = 0,
    focus_reporting: bool = false,
    bracketed_paste: bool = false,
    kitty_keyboard_main: KittyKeyboardStack = .{},
    kitty_keyboard_alt: KittyKeyboardStack = .{},
    kitty_pointer_main: KittyPointerShapeStack = .{},
    kitty_pointer_alt: KittyPointerShapeStack = .{},
    mouse_tracking: Input.MouseTrackingMode = .off,
    mouse_protocol: Input.MouseProtocol = .none,
    saved_dec_modes: [16]SavedDecMode = [_]SavedDecMode{.{ .mode = 0, .state = 0 }} ** 16,
    saved_dec_mode_count: u8 = 0,
    pending_output: std.ArrayList(u8),
    hyperlink_targets: std.ArrayList([]u8),
    pending_clipboard: ?ClipboardRequest = null,
    kitty_shell_mark: KittyShellMark = .{},
    kitty_notifications: std.ArrayList(KittyNotificationRequest),
    kitty_color_stack_depth: u16 = 0,
    terminal_colors: TerminalColorState = .{},
    terminal_color_stack: TerminalColorStack = .{},
    kitty_graphics_images: std.ArrayList(KittyGraphicsImage),
    kitty_graphics_placements: std.ArrayList(KittyGraphicsPlacement),
    kitty_graphics_frames: std.ArrayList(KittyGraphicsFrame),
    kitty_graphics_upload: ?KittyGraphicsUpload = null,
    next_kitty_graphics_image_id: u32 = 1,
    encode_buf: [64]u8 = undefined,
    encode_len: usize = 0,

    /// Initialize vt_core without cell storage.
    pub fn init(allocator: std.mem.Allocator, rows: u16, cols: u16) !VtCore {
        var pipeline = try Interpret.Pipeline.init(allocator);
        errdefer pipeline.deinit();
        const state = Grid.GridModel.init(rows, cols);
        const alt_state = Grid.GridModel.init(rows, cols);
        return VtCore{
            .allocator = allocator,
            .pipeline = pipeline,
            .primary_state = state,
            .alt_state = alt_state,
            .alt_active = false,
            .selection = Selection.SelectionState.init(),
            .pending_output = std.ArrayList(u8).empty,
            .hyperlink_targets = std.ArrayList([]u8).empty,
            .kitty_notifications = std.ArrayList(KittyNotificationRequest).empty,
            .kitty_graphics_images = std.ArrayList(KittyGraphicsImage).empty,
            .kitty_graphics_placements = std.ArrayList(KittyGraphicsPlacement).empty,
            .kitty_graphics_frames = std.ArrayList(KittyGraphicsFrame).empty,
        };
    }

    /// Initialize vt_core with cell storage.
    pub fn initWithCells(allocator: std.mem.Allocator, rows: u16, cols: u16) !VtCore {
        var pipeline = try Interpret.Pipeline.init(allocator);
        errdefer pipeline.deinit();
        var state = try Grid.GridModel.initWithCells(allocator, rows, cols);
        errdefer state.deinit(allocator);
        var alt_state = try Grid.GridModel.initWithCells(allocator, rows, cols);
        errdefer alt_state.deinit(allocator);
        return VtCore{
            .allocator = allocator,
            .pipeline = pipeline,
            .primary_state = state,
            .alt_state = alt_state,
            .alt_active = false,
            .selection = Selection.SelectionState.init(),
            .pending_output = std.ArrayList(u8).empty,
            .hyperlink_targets = std.ArrayList([]u8).empty,
            .kitty_notifications = std.ArrayList(KittyNotificationRequest).empty,
            .kitty_graphics_images = std.ArrayList(KittyGraphicsImage).empty,
            .kitty_graphics_placements = std.ArrayList(KittyGraphicsPlacement).empty,
            .kitty_graphics_frames = std.ArrayList(KittyGraphicsFrame).empty,
        };
    }

    /// Initialize vt_core with cell and history storage.
    pub fn initWithCellsAndHistory(allocator: std.mem.Allocator, rows: u16, cols: u16, history_capacity: u16) !VtCore {
        var pipeline = try Interpret.Pipeline.init(allocator);
        errdefer pipeline.deinit();
        var state = try Grid.GridModel.initWithCellsAndHistory(allocator, rows, cols, history_capacity);
        errdefer state.deinit(allocator);
        var alt_state = try Grid.GridModel.initWithCells(allocator, rows, cols);
        errdefer alt_state.deinit(allocator);
        return VtCore{
            .allocator = allocator,
            .pipeline = pipeline,
            .primary_state = state,
            .alt_state = alt_state,
            .alt_active = false,
            .selection = Selection.SelectionState.init(),
            .pending_output = std.ArrayList(u8).empty,
            .hyperlink_targets = std.ArrayList([]u8).empty,
            .kitty_notifications = std.ArrayList(KittyNotificationRequest).empty,
            .kitty_graphics_images = std.ArrayList(KittyGraphicsImage).empty,
            .kitty_graphics_placements = std.ArrayList(KittyGraphicsPlacement).empty,
            .kitty_graphics_frames = std.ArrayList(KittyGraphicsFrame).empty,
        };
    }

    /// Release vt_core-owned resources.
    pub fn deinit(self: *VtCore) void {
        for (self.hyperlink_targets.items) |uri| self.allocator.free(uri);
        self.hyperlink_targets.deinit(self.allocator);
        if (self.pending_clipboard) |req| self.allocator.free(req.raw);
        self.allocator.free(self.kitty_shell_mark.metadata);
        for (self.kitty_notifications.items) |notification| {
            self.allocator.free(notification.metadata);
            self.allocator.free(notification.payload);
        }
        self.kitty_notifications.deinit(self.allocator);
        for (self.kitty_graphics_images.items) |image| self.allocator.free(image.base64_payload);
        self.kitty_graphics_images.deinit(self.allocator);
        self.kitty_graphics_placements.deinit(self.allocator);
        for (self.kitty_graphics_frames.items) |frame| self.allocator.free(frame.base64_payload);
        self.kitty_graphics_frames.deinit(self.allocator);
        if (self.kitty_graphics_upload) |*upload| upload.data.deinit(self.allocator);
        self.pending_output.deinit(self.allocator);
        self.primary_state.deinit(self.allocator);
        self.alt_state.deinit(self.allocator);
        self.pipeline.deinit();
    }

    /// Feed one input byte into parser state.
    pub fn feedByte(self: *VtCore, byte: u8) void {
        self.pipeline.feedByte(byte);
    }

    /// Feed a byte slice into parser state.
    pub fn feedSlice(self: *VtCore, bytes: []const u8) void {
        self.pipeline.feedSlice(bytes);
    }

    /// Apply queued events to the grid model.
    pub fn apply(self: *VtCore) void {
        for (self.pipeline.events()) |ev| {
            if (Interpret.process(ev)) |sem_ev| {
                self.applySemantic(sem_ev);
            }
        }
        self.pipeline.clear();
        self.selection.clearIfInvalidatedByGrid(self.activeState());
    }

    /// Clear queued events without applying.
    pub fn clear(self: *VtCore) void {
        self.pipeline.clear();
    }

    pub fn pendingOutput(self: *const VtCore) []const u8 {
        return self.pending_output.items;
    }

    pub fn clearPendingOutput(self: *VtCore) void {
        self.pending_output.clearRetainingCapacity();
    }

    pub fn hyperlinkUriForId(self: *const VtCore, link_id: u32) ?[]const u8 {
        if (link_id == 0) return null;
        const idx = link_id - 1;
        if (idx >= self.hyperlink_targets.items.len) return null;
        return self.hyperlink_targets.items[idx];
    }

    pub fn pendingClipboardSet(self: *const VtCore) ?[]const u8 {
        if (self.pending_clipboard) |req| return req.raw;
        return null;
    }

    pub fn kittyShellMark(self: *const VtCore) KittyShellMark {
        return self.kitty_shell_mark;
    }

    pub fn kittyNotificationCount(self: *const VtCore) usize {
        return self.kitty_notifications.items.len;
    }

    pub fn kittyNotificationAt(self: *const VtCore, idx: usize) ?KittyNotificationRequest {
        if (idx >= self.kitty_notifications.items.len) return null;
        return self.kitty_notifications.items[idx];
    }

    pub fn kittyPointerShape(self: *const VtCore) []const u8 {
        const stack = self.activeKittyPointerConst();
        if (stack.len == 0) return "0";
        return kittyPointerShapeName(stack.stack[stack.len - 1]);
    }

    pub fn kittyColorStackDepth(self: *const VtCore) u16 {
        return self.kitty_color_stack_depth;
    }

    pub fn terminalColorState(self: *const VtCore) TerminalColorState {
        return self.terminal_colors;
    }

    pub fn kittyGraphicsImageCount(self: *const VtCore) usize {
        return self.kitty_graphics_images.items.len;
    }

    pub fn kittyGraphicsImageAt(self: *const VtCore, idx: usize) ?KittyGraphicsImage {
        if (idx >= self.kitty_graphics_images.items.len) return null;
        return self.kitty_graphics_images.items[idx];
    }

    pub fn kittyGraphicsPlacementCount(self: *const VtCore) usize {
        return self.kitty_graphics_placements.items.len;
    }

    pub fn kittyGraphicsPlacementAt(self: *const VtCore, idx: usize) ?KittyGraphicsPlacement {
        if (idx >= self.kitty_graphics_placements.items.len) return null;
        return self.kitty_graphics_placements.items[idx];
    }

    pub fn kittyGraphicsFrameCount(self: *const VtCore) usize {
        return self.kitty_graphics_frames.items.len;
    }

    pub fn kittyGraphicsFrameAt(self: *const VtCore, idx: usize) ?KittyGraphicsFrame {
        if (idx >= self.kitty_graphics_frames.items.len) return null;
        return self.kitty_graphics_frames.items[idx];
    }

    pub fn clearPendingClipboardSet(self: *VtCore) void {
        if (self.pending_clipboard) |req| self.allocator.free(req.raw);
        self.pending_clipboard = null;
    }

    /// Reset parser state and clear queue.
    pub fn reset(self: *VtCore) void {
        self.pipeline.reset();
    }

    /// Reset visible grid state only.
    pub fn resetScreen(self: *VtCore) void {
        self.activeStateMut().reset();
    }

    /// Resize visible screen while preserving history ring contents.
    pub fn resize(self: *VtCore, rows: u16, cols: u16) !void {
        try self.primary_state.resize(self.allocator, rows, cols);
        try self.alt_state.resize(self.allocator, rows, cols);
        self.selection.clearIfInvalidatedByGrid(self.activeState());
    }

    /// Return read-only grid model reference.
    pub fn screen(self: *const VtCore) *const GridNs.GridModel {
        return self.activeState();
    }

    /// Return a stable render-facing snapshot view of visible state.
    pub fn renderView(self: *const VtCore) RenderView {
        return .{
            .rows = self.activeState().rows,
            .cols = self.activeState().cols,
            .cursor_row = self.activeState().cursor_row,
            .cursor_col = self.activeState().cursor_col,
            .cursor_visible = self.activeState().cursor_visible,
            .cursor_shape = self.activeState().cursor_style.shape,
            .is_alternate_screen = self.alt_active,
            .screen = self.activeState(),
        };
    }

    pub fn peekDirtyRows(self: *const VtCore) ?DirtyRows {
        return self.activeState().peekDirtyRows();
    }

    pub fn clearDirtyRows(self: *VtCore) void {
        self.activeStateMut().clearDirtyRows();
    }

    /// Return queued event count.
    pub fn queuedEventCount(self: *const VtCore) usize {
        return self.pipeline.len();
    }

    /// Return the most recent queued title-set event before apply clears the queue.
    pub fn latestTitleSet(self: *const VtCore) ?[]const u8 {
        var i = self.pipeline.events().len;
        while (i > 0) {
            i -= 1;
            const ev = self.pipeline.events()[i];
            switch (ev) {
                .osc => |osc| if (osc.kind == .title) return osc.payload,
                else => {},
            }
        }
        return null;
    }

    /// Return history cell by recency index and column.
    pub fn historyRowAt(self: *const VtCore, history_idx: usize, col: u16) u21 {
        if (self.alt_active) return 0;
        return self.primary_state.historyRowAt(history_idx, col);
    }

    pub fn historyCellAt(self: *const VtCore, history_idx: usize, col: u16) GridNs.Cell {
        if (self.alt_active) return GridNs.default_cell;
        return self.primary_state.historyCellAt(history_idx, col);
    }

    /// Return retained history row count.
    pub fn historyCount(self: *const VtCore) usize {
        if (self.alt_active) return 0;
        return self.primary_state.historyCount();
    }

    /// Return configured history capacity.
    pub fn historyCapacity(self: *const VtCore) u16 {
        return self.primary_state.historyCapacity();
    }

    pub fn isAlternateScreen(self: *const VtCore) bool {
        return self.alt_active;
    }

    /// Return active selection snapshot or null.
    pub fn selectionState(self: *const VtCore) ?Selection.TerminalSelection {
        return self.selection.state();
    }

    /// Start selection at row/column coordinates.
    pub fn selectionStart(self: *VtCore, row: i32, col: u16) void {
        self.selection.start(row, col);
    }

    /// Update selection end coordinates.
    pub fn selectionUpdate(self: *VtCore, row: i32, col: u16) void {
        self.selection.update(row, col);
    }

    /// Finish current active selection.
    pub fn selectionFinish(self: *VtCore) void {
        self.selection.finish();
    }

    /// Clear current selection state.
    pub fn selectionClear(self: *VtCore) void {
        self.selection.clear();
    }

    /// Encode logical key and modifiers.
    pub fn encodeKey(self: *VtCore, key: Input.Key, mod: Input.Modifier) []const u8 {
        const encoded = Input.Codec.encodeKey(self.encode_buf[0..], key, mod, self.application_cursor_keys, self.application_keypad, self.modify_other_keys, self.activeKittyKeyboardFlags());
        self.encode_len = encoded.len;
        return encoded;
    }

    pub fn kittyKeyboardFlags(self: *const VtCore) u32 {
        return self.activeKittyKeyboardFlags();
    }

    pub fn isApplicationKeypad(self: *const VtCore) bool {
        return self.application_keypad;
    }

    pub fn modifyOtherKeys(self: *const VtCore) i8 {
        return self.modify_other_keys;
    }

    /// Encode mouse event payload (placeholder surface).
    pub fn encodeMouse(self: *VtCore, event: Input.MouseEvent) []const u8 {
        const encoded = Input.Codec.encodeMouse(self.encode_buf[0..], event, self.mouse_tracking, self.mouse_protocol);
        self.encode_len = encoded.len;
        return encoded;
    }

    pub fn encodeFocusIn(self: *VtCore) []const u8 {
        const encoded = if (self.focus_reporting) "\x1b[I" else "";
        @memcpy(self.encode_buf[0..encoded.len], encoded);
        self.encode_len = encoded.len;
        return self.encode_buf[0..encoded.len];
    }

    pub fn encodeFocusOut(self: *VtCore) []const u8 {
        const encoded = if (self.focus_reporting) "\x1b[O" else "";
        @memcpy(self.encode_buf[0..encoded.len], encoded);
        self.encode_len = encoded.len;
        return self.encode_buf[0..encoded.len];
    }

    pub fn encodePasteStart(self: *VtCore) []const u8 {
        const encoded = if (self.bracketed_paste) "\x1b[200~" else "";
        @memcpy(self.encode_buf[0..encoded.len], encoded);
        self.encode_len = encoded.len;
        return self.encode_buf[0..encoded.len];
    }

    pub fn encodePasteEnd(self: *VtCore) []const u8 {
        const encoded = if (self.bracketed_paste) "\x1b[201~" else "";
        @memcpy(self.encode_buf[0..encoded.len], encoded);
        self.encode_len = encoded.len;
        return self.encode_buf[0..encoded.len];
    }

    /// Parse host key token into vt-core key constant.
    pub fn parseKeyToken(name: []const u8) ?Key {
        return Input.Codec.parseKeyToken(name);
    }

    /// Parse host modifier bitfield into vt-core modifier mask.
    pub fn parseModifierBits(mods: i32) Modifier {
        return Input.Codec.parseModifierBits(mods);
    }

    /// Parse host control token into control signal.
    pub fn parseControlToken(name: []const u8) ?ControlSignal {
        if (std.mem.eql(u8, name, "interrupt")) return .interrupt;
        if (std.mem.eql(u8, name, "terminate")) return .terminate;
        return null;
    }

    /// Capture deterministic snapshot of vt_core observable state.
    ///
    /// Returns an VtCoreSnapshot containing visible cells, cursor, modes, history,
    /// and selection state at the time of the call. Snapshots are host-neutral and
    /// do not capture parser state, queued events, or internal encode buffers.
    ///
    /// Determinism: identical observable vt_core state produces identical snapshots.
    /// Identical byte sequences fed via feedByte/feedSlice, followed by apply(),
    /// produce identical snapshots regardless of how bytes are chunked.
    ///
    /// Memory: allocates owned copies of cell and history buffers. Caller must
    /// call snapshot.deinit() to release them when done.
    ///
    /// Error: returns allocation error if owned buffer allocation fails.
    pub fn snapshot(self: *const VtCore) !Snapshot.VtCoreSnapshot {
        return Snapshot.VtCoreSnapshot.captureFromScreen(
            self.allocator,
            self.activeState(),
            self.selection.state(),
        );
    }

    fn activeState(self: *const VtCore) *const GridNs.GridModel {
        return if (self.alt_active) &self.alt_state else &self.primary_state;
    }

    fn activeStateMut(self: *VtCore) *GridNs.GridModel {
        return if (self.alt_active) &self.alt_state else &self.primary_state;
    }

    fn activeKittyKeyboard(self: *VtCore) *KittyKeyboardStack {
        return if (self.alt_active) &self.kitty_keyboard_alt else &self.kitty_keyboard_main;
    }

    fn activeKittyKeyboardConst(self: *const VtCore) *const KittyKeyboardStack {
        return if (self.alt_active) &self.kitty_keyboard_alt else &self.kitty_keyboard_main;
    }

    fn activeKittyKeyboardFlags(self: *const VtCore) u32 {
        return self.activeKittyKeyboardConst().flags;
    }

    fn activeKittyPointer(self: *VtCore) *KittyPointerShapeStack {
        return if (self.alt_active) &self.kitty_pointer_alt else &self.kitty_pointer_main;
    }

    fn activeKittyPointerConst(self: *const VtCore) *const KittyPointerShapeStack {
        return if (self.alt_active) &self.kitty_pointer_alt else &self.kitty_pointer_main;
    }

    fn setKittyKeyboardFlags(self: *VtCore, flags: u32, mode: u8) void {
        const kb = self.activeKittyKeyboard();
        switch (mode) {
            2 => kb.flags |= flags,
            3 => kb.flags &= ~flags,
            else => kb.flags = flags,
        }
    }

    fn pushKittyKeyboardFlags(self: *VtCore, flags: u32) void {
        const kb = self.activeKittyKeyboard();
        if (kb.len == kb.stack.len) {
            std.mem.copyForwards(u32, kb.stack[0 .. kb.stack.len - 1], kb.stack[1..kb.stack.len]);
            kb.len -= 1;
        }
        kb.stack[kb.len] = kb.flags;
        kb.len += 1;
        kb.flags = flags;
    }

    fn popKittyKeyboardFlags(self: *VtCore, count: u16) void {
        const kb = self.activeKittyKeyboard();
        var remaining = count;
        while (remaining > 0 and kb.len > 0) : (remaining -= 1) {
            kb.len -= 1;
            kb.flags = kb.stack[kb.len];
        }
        if (remaining > 0) kb.flags = 0;
    }

    fn appendKittyKeyboardReport(self: *VtCore) void {
        const text = std.fmt.bufPrint(self.encode_buf[0..], "\x1b[?{d}u", .{self.activeKittyKeyboardFlags()}) catch return;
        self.appendPendingOutput(text);
    }

    fn appendModifyOtherKeysReport(self: *VtCore) void {
        const text = std.fmt.bufPrint(self.encode_buf[0..], "\x1b[>4;{d}m", .{self.modify_other_keys}) catch return;
        self.appendPendingOutput(text);
    }

    fn setKittyShellMark(self: *VtCore, mark: anytype) void {
        self.allocator.free(self.kitty_shell_mark.metadata);
        const owned = self.allocator.dupe(u8, mark.metadata) catch {
            self.kitty_shell_mark = .{};
            return;
        };
        self.kitty_shell_mark = .{ .kind = mark.kind, .status = mark.status, .metadata = owned };
    }

    fn appendKittyNotification(self: *VtCore, notification: anytype) void {
        const metadata = self.allocator.dupe(u8, notification.metadata) catch return;
        errdefer self.allocator.free(metadata);
        const payload = self.allocator.dupe(u8, notification.payload) catch return;
        self.kitty_notifications.append(self.allocator, .{ .metadata = metadata, .payload = payload }) catch {
            self.allocator.free(metadata);
            self.allocator.free(payload);
        };
    }

    fn handleKittyPointerShape(self: *VtCore, cmd: anytype) void {
        switch (cmd.action) {
            '<' => self.popKittyPointerShape(),
            '>' => self.pushKittyPointerShapes(cmd.names),
            '?' => self.appendKittyPointerShapeQuery(cmd.names),
            else => self.setKittyPointerShape(cmd.names),
        }
    }

    fn handleKittyColorStack(self: *VtCore, cmd: anytype) void {
        switch (cmd) {
            .push => self.pushTerminalColorState(),
            .pop => self.popTerminalColorState(),
        }
    }

    fn pushTerminalColorState(self: *VtCore) void {
        if (self.terminal_color_stack.len == self.terminal_color_stack.stack.len) {
            std.mem.copyForwards(TerminalColorState, self.terminal_color_stack.stack[0 .. self.terminal_color_stack.stack.len - 1], self.terminal_color_stack.stack[1..self.terminal_color_stack.stack.len]);
            self.terminal_color_stack.len -= 1;
        }
        self.terminal_color_stack.stack[self.terminal_color_stack.len] = self.terminal_colors;
        self.terminal_color_stack.len += 1;
        self.kitty_color_stack_depth = self.terminal_color_stack.len;
    }

    fn popTerminalColorState(self: *VtCore) void {
        if (self.terminal_color_stack.len == 0) {
            self.kitty_color_stack_depth = 0;
            return;
        }
        self.terminal_color_stack.len -= 1;
        self.terminal_colors = self.terminal_color_stack.stack[self.terminal_color_stack.len];
        self.kitty_color_stack_depth = self.terminal_color_stack.len;
    }

    fn handleTerminalColorControl(self: *VtCore, cmd: anytype) void {
        switch (cmd.command) {
            21 => self.handleKittyColorControl(cmd.payload),
            4 => self.handleXtermPaletteControl(cmd.payload),
            10 => self.handleXtermSpecialColor(.foreground, cmd.payload),
            11 => self.handleXtermSpecialColor(.background, cmd.payload),
            12 => self.handleXtermSpecialColor(.cursor, cmd.payload),
            104 => self.resetXtermPalette(cmd.payload),
            110 => self.terminal_colors.foreground = GridNs.default_fg,
            111 => self.terminal_colors.background = GridNs.default_bg,
            112 => self.terminal_colors.cursor = null,
            else => {},
        }
    }

    fn handleKittyColorControl(self: *VtCore, payload: []const u8) void {
        var parts = std.mem.splitScalar(u8, payload, ';');
        while (parts.next()) |raw_part| {
            const part = std.mem.trim(u8, raw_part, " \t\r\n");
            if (part.len == 0) continue;
            const eq = std.mem.indexOfScalar(u8, part, '=');
            if (eq) |pos| {
                const key = std.mem.trim(u8, part[0..pos], " \t");
                const value = std.mem.trim(u8, part[pos + 1 ..], " \t");
                if (std.mem.eql(u8, value, "?")) {
                    self.appendKittyColorQueryReply(key);
                } else {
                    self.setColorKey(key, value);
                }
            } else {
                self.resetColorKey(std.mem.trim(u8, part, " \t"));
            }
        }
    }

    fn handleXtermPaletteControl(self: *VtCore, payload: []const u8) void {
        var parts = std.mem.splitScalar(u8, payload, ';');
        while (parts.next()) |idx_text| {
            const value = parts.next() orelse break;
            const idx = std.fmt.parseUnsigned(u8, idx_text, 10) catch continue;
            if (std.mem.eql(u8, value, "?")) {
                const text = std.fmt.bufPrint(self.encode_buf[0..], "\x1b]4;{d};", .{idx}) catch continue;
                self.appendPendingOutput(text);
                self.appendColorOsc(self.terminal_colors.palette[idx]);
                self.appendPendingOutput("\x1b\\");
            } else if (parseColor(value)) |color| {
                self.terminal_colors.palette[idx] = color;
            }
        }
    }

    fn handleXtermSpecialColor(self: *VtCore, key: SpecialColorKey, payload: []const u8) void {
        if (std.mem.eql(u8, payload, "?")) {
            self.appendXtermSpecialColorReply(key);
        } else if (parseColor(payload)) |color| {
            self.setSpecialColor(key, color);
        }
    }

    fn resetXtermPalette(self: *VtCore, payload: []const u8) void {
        if (payload.len == 0) {
            self.terminal_colors.palette = defaultPalette();
            return;
        }
        var parts = std.mem.splitScalar(u8, payload, ';');
        while (parts.next()) |idx_text| {
            const idx = std.fmt.parseUnsigned(u8, idx_text, 10) catch continue;
            self.terminal_colors.palette[idx] = defaultPaletteColor(idx);
        }
    }

    fn appendKittyColorQueryReply(self: *VtCore, key: []const u8) void {
        self.appendPendingOutput("\x1b]21;");
        self.appendPendingOutput(key);
        self.appendPendingOutput("=");
        if (colorForKey(self.terminal_colors, key)) |color| {
            self.appendColorOsc(color);
        } else if (isKnownColorKey(key)) {
            // Empty value means dynamic/undefined for Kitty color control.
        } else {
            self.appendPendingOutput("?");
        }
        self.appendPendingOutput("\x1b\\");
    }

    fn appendXtermSpecialColorReply(self: *VtCore, key: SpecialColorKey) void {
        const osc: u8 = switch (key) { .foreground => 10, .background => 11, .cursor => 12, else => 10 };
        const color = switch (key) {
            .foreground => self.terminal_colors.foreground,
            .background => self.terminal_colors.background,
            .cursor => self.terminal_colors.cursor orelse self.terminal_colors.foreground,
            else => self.terminal_colors.foreground,
        };
        const text = std.fmt.bufPrint(self.encode_buf[0..], "\x1b]{d};", .{osc}) catch return;
        self.appendPendingOutput(text);
        self.appendColorOsc(color);
        self.appendPendingOutput("\x1b\\");
    }

    fn appendColorOsc(self: *VtCore, color: Color) void {
        const text = std.fmt.bufPrint(self.encode_buf[0..], "rgb:{x:0>2}/{x:0>2}/{x:0>2}", .{ color.r, color.g, color.b }) catch return;
        self.appendPendingOutput(text);
    }

    fn setColorKey(self: *VtCore, key: []const u8, value: []const u8) void {
        if (std.fmt.parseUnsigned(u8, key, 10)) |idx| {
            if (parseColor(value)) |color| self.terminal_colors.palette[idx] = color;
            return;
        } else |_| {}
        if (value.len == 0) {
            self.setSpecialColorDynamic(key);
        } else if (parseColor(value)) |color| {
            if (specialColorKey(key)) |special| self.setSpecialColor(special, color);
        }
    }

    fn resetColorKey(self: *VtCore, key: []const u8) void {
        if (std.fmt.parseUnsigned(u8, key, 10)) |idx| {
            self.terminal_colors.palette[idx] = defaultPaletteColor(idx);
            return;
        } else |_| {}
        if (specialColorKey(key)) |special| switch (special) {
            .foreground => self.terminal_colors.foreground = GridNs.default_fg,
            .background => self.terminal_colors.background = GridNs.default_bg,
            .cursor => self.terminal_colors.cursor = null,
            .cursor_text => self.terminal_colors.cursor_text = null,
            .selection_background => self.terminal_colors.selection_background = null,
            .selection_foreground => self.terminal_colors.selection_foreground = null,
        };
    }

    fn setSpecialColor(self: *VtCore, key: SpecialColorKey, color: Color) void {
        switch (key) {
            .foreground => self.terminal_colors.foreground = color,
            .background => self.terminal_colors.background = color,
            .cursor => self.terminal_colors.cursor = color,
            .cursor_text => self.terminal_colors.cursor_text = color,
            .selection_background => self.terminal_colors.selection_background = color,
            .selection_foreground => self.terminal_colors.selection_foreground = color,
        }
    }

    fn setSpecialColorDynamic(self: *VtCore, key: []const u8) void {
        if (specialColorKey(key)) |special| switch (special) {
            .foreground => {},
            .background => {},
            .cursor => self.terminal_colors.cursor = null,
            .cursor_text => self.terminal_colors.cursor_text = null,
            .selection_background => self.terminal_colors.selection_background = null,
            .selection_foreground => self.terminal_colors.selection_foreground = null,
        };
    }

    fn setKittyPointerShape(self: *VtCore, names: []const u8) void {
        const stack = self.activeKittyPointer();
        stack.len = 0;
        const shape = firstKittyPointerShape(names) orelse return;
        stack.stack[0] = shape;
        stack.len = 1;
    }

    fn pushKittyPointerShapes(self: *VtCore, names: []const u8) void {
        var parts = std.mem.splitScalar(u8, names, ',');
        while (parts.next()) |name| {
            const shape = parseKittyPointerShapeName(name) orelse continue;
            const stack = self.activeKittyPointer();
            if (stack.len == stack.stack.len) {
                std.mem.copyForwards(KittyPointerShape, stack.stack[0 .. stack.stack.len - 1], stack.stack[1..stack.stack.len]);
                stack.len -= 1;
            }
            stack.stack[stack.len] = shape;
            stack.len += 1;
        }
    }

    fn popKittyPointerShape(self: *VtCore) void {
        const stack = self.activeKittyPointer();
        if (stack.len > 0) stack.len -= 1;
    }

    fn appendKittyPointerShapeQuery(self: *VtCore, names: []const u8) void {
        self.appendPendingOutput("\x1b]22;");
        var first = true;
        var parts = std.mem.splitScalar(u8, names, ',');
        while (parts.next()) |name| {
            if (!first) self.appendPendingOutput(",");
            first = false;
            if (std.mem.eql(u8, name, "__current__")) {
                self.appendPendingOutput(self.kittyPointerShape());
            } else if (std.mem.eql(u8, name, "__default__") or std.mem.eql(u8, name, "__grabbed__")) {
                self.appendPendingOutput("default");
            } else {
                self.appendPendingOutput(if (parseKittyPointerShapeName(name) != null) "1" else "0");
            }
        }
        self.appendPendingOutput("\x1b\\");
    }

    fn resetTerminalState(self: *VtCore) void {
        self.activeStateMut().reset();
        self.kitty_pointer_main.len = 0;
        self.kitty_pointer_alt.len = 0;
        self.kitty_color_stack_depth = 0;
    }

    fn applySemantic(self: *VtCore, sem_ev: Interpret.SemanticEvent) void {
        switch (sem_ev) {
            .enter_alt_screen => |opts| self.enterAltScreen(opts.clear, opts.save_cursor),
            .exit_alt_screen => |opts| self.exitAltScreen(opts.restore_cursor),
            .application_cursor_keys => |enabled| self.application_cursor_keys = enabled,
            .application_keypad => |enabled| self.application_keypad = enabled,
            .modify_other_keys_set => |value| self.modify_other_keys = value,
            .modify_other_keys_query => self.appendModifyOtherKeysReport(),
            .modify_other_keys_disable => self.modify_other_keys = -1,
            .focus_reporting => |enabled| self.focus_reporting = enabled,
            .bracketed_paste => |enabled| self.bracketed_paste = enabled,
            .kitty_keyboard_set => |req| self.setKittyKeyboardFlags(req.flags, req.mode),
            .kitty_keyboard_query => self.appendKittyKeyboardReport(),
            .kitty_keyboard_push => |flags| self.pushKittyKeyboardFlags(flags),
            .kitty_keyboard_pop => |count| self.popKittyKeyboardFlags(count),
            .kitty_shell_mark => |mark| self.setKittyShellMark(mark),
            .kitty_notification => |notification| self.appendKittyNotification(notification),
            .kitty_pointer_shape => |cmd| self.handleKittyPointerShape(cmd),
            .kitty_color_stack => |cmd| self.handleKittyColorStack(cmd),
            .terminal_color_control => |cmd| self.handleTerminalColorControl(cmd),
            .mouse_tracking_off => self.mouse_tracking = .off,
            .mouse_tracking_x10 => self.mouse_tracking = .x10,
            .mouse_tracking_normal => self.mouse_tracking = .normal,
            .mouse_tracking_button_event => self.mouse_tracking = .button_event,
            .mouse_tracking_any_event => self.mouse_tracking = .any_event,
            .mouse_protocol_utf8 => |enabled| self.mouse_protocol = if (enabled) .utf8 else .none,
            .mouse_protocol_sgr => |enabled| self.mouse_protocol = if (enabled) .sgr else .none,
            .mouse_protocol_urxvt => |enabled| self.mouse_protocol = if (enabled) .urxvt else .none,
            .hyperlink_set => |uri| self.activeStateMut().setCurrentLinkId(self.internHyperlink(uri)),
            .hyperlink_clear => self.activeStateMut().setCurrentLinkId(0),
            .clipboard_set => |payload| self.setPendingClipboard(payload),
            .dec_mode_query => |mode| self.appendDecModeReport(mode),
            .dec_mode_save => |modes| self.saveDecModes(modes.params[0..modes.param_count]),
            .dec_mode_restore => |modes| self.restoreDecModes(modes.params[0..modes.param_count]),
            .device_status_report => self.appendPendingOutput("\x1b[0n"),
            .cursor_position_report => self.appendCursorPositionReport(),
            .dec_cursor_position_report => self.appendDecCursorPositionReport(),
            .primary_device_attributes => self.appendPendingOutput("\x1b[?62;22c"),
            .secondary_device_attributes => self.appendPendingOutput("\x1b[>1;10;0c"),
            .kitty_graphics => |cmd| self.handleKittyGraphics(cmd),
            .reset_screen => self.resetTerminalState(),
            else => self.activeStateMut().apply(sem_ev),
        }
    }

    fn handleKittyGraphics(self: *VtCore, cmd: anytype) void {
        if (cmd.action == 'q') {
            if (!cmd.quiet) self.appendKittyGraphicsReply(cmd.image_id, "EINVAL:kitty graphics rendering unsupported");
            return;
        }
        if (cmd.action == 'p') {
            self.placeKittyGraphicsImage(cmd);
            return;
        }
        if (cmd.action == 'd') {
            self.deleteKittyGraphics(cmd);
            return;
        }
        if (cmd.action == 'f') {
            self.captureKittyGraphicsUpload(cmd);
            return;
        }
        self.captureKittyGraphicsUpload(cmd);
    }

    fn placeKittyGraphicsImage(self: *VtCore, cmd: anytype) void {
        const image_id = self.resolveKittyGraphicsImageId(cmd) orelse {
            if (!cmd.quiet) self.appendKittyGraphicsReply(cmd.image_id, "ENOENT:image not found");
            return;
        };
        const view = self.renderView();
        self.kitty_graphics_placements.append(self.allocator, .{
            .image_id = image_id,
            .placement_id = cmd.placement_id,
            .row = view.cursor_row,
            .col = view.cursor_col,
            .columns = cmd.columns,
            .rows = cmd.rows,
            .z_index = cmd.z,
        }) catch return;
        if (!cmd.quiet) self.appendKittyGraphicsReply(image_id, "OK");
    }

    fn deleteKittyGraphics(self: *VtCore, cmd: anytype) void {
        self.abortKittyGraphicsUpload();
        switch (cmd.delete_target) {
            0, 'a', 'A' => {
                self.kitty_graphics_placements.clearRetainingCapacity();
                if (cmd.delete_target == 'A') self.deleteUnplacedKittyGraphicsImages();
            },
            'i', 'I' => if (self.resolveKittyGraphicsImageId(cmd)) |image_id| {
                if (cmd.placement_id != 0) self.deleteKittyGraphicsPlacement(image_id, cmd.placement_id) else self.deleteKittyGraphicsImage(image_id);
            },
            'n', 'N' => if (self.findNewestKittyGraphicsImageByNumber(cmd.image_number)) |idx| {
                const image_id = self.kitty_graphics_images.items[idx].image_id;
                if (cmd.placement_id != 0) self.deleteKittyGraphicsPlacement(image_id, cmd.placement_id) else self.deleteKittyGraphicsImage(image_id);
            },
            'c', 'C' => {
                const view = self.renderView();
                self.deleteKittyGraphicsPlacementsAt(view.cursor_col + 1, view.cursor_row + 1, null);
                if (cmd.delete_target == 'C') self.deleteUnplacedKittyGraphicsImages();
            },
            'p', 'P' => {
                self.deleteKittyGraphicsPlacementsAt(cmd.x, cmd.y, null);
                if (cmd.delete_target == 'P') self.deleteUnplacedKittyGraphicsImages();
            },
            'q', 'Q' => {
                self.deleteKittyGraphicsPlacementsAt(cmd.x, cmd.y, cmd.z);
                if (cmd.delete_target == 'Q') self.deleteUnplacedKittyGraphicsImages();
            },
            'r', 'R' => {
                self.deleteKittyGraphicsImagesInRange(cmd.x, cmd.y);
            },
            'x', 'X' => {
                self.deleteKittyGraphicsPlacementsInColumn(cmd.x);
                if (cmd.delete_target == 'X') self.deleteUnplacedKittyGraphicsImages();
            },
            'y', 'Y' => {
                self.deleteKittyGraphicsPlacementsInRow(cmd.y);
                if (cmd.delete_target == 'Y') self.deleteUnplacedKittyGraphicsImages();
            },
            'z', 'Z' => {
                self.deleteKittyGraphicsPlacementsByZ(cmd.z);
                if (cmd.delete_target == 'Z') self.deleteUnplacedKittyGraphicsImages();
            },
            'f', 'F' => self.deleteKittyGraphicsFrames(cmd),
            else => {},
        }
    }

    fn captureKittyGraphicsUpload(self: *VtCore, cmd: anytype) void {
        if (cmd.medium != 'd') return;
        if (cmd.action != 't' and cmd.action != 'T' and cmd.action != 'f') return;
        if (cmd.more_chunks) {
            self.appendKittyGraphicsUploadChunk(cmd, true);
            return;
        }
        if (self.kitty_graphics_upload != null) {
            self.appendKittyGraphicsUploadChunk(cmd, false);
        } else {
            self.storeKittyGraphicsPayload(cmd, cmd.payload);
        }
    }

    fn appendKittyGraphicsUploadChunk(self: *VtCore, cmd: anytype, more: bool) void {
        if (self.kitty_graphics_upload == null) {
            const image_id = self.imageIdForUpload(cmd);
            self.kitty_graphics_upload = .{
                .image_id = image_id,
                .image_number = cmd.image_number,
                .action = cmd.action,
                .format = cmd.format,
                .width = cmd.width,
                .height = cmd.height,
                .frame_number = cmd.placement_id,
                .data = std.ArrayList(u8).empty,
            };
        }
        if (self.kitty_graphics_upload) |*upload| {
            upload.data.appendSlice(self.allocator, cmd.payload) catch return;
            if (more) return;
            const image_id = upload.image_id;
            const image_number = upload.image_number;
            const action = upload.action;
            const format = upload.format;
            const width = upload.width;
            const height = upload.height;
            const frame_number = upload.frame_number;
            const owned = upload.data.toOwnedSlice(self.allocator) catch return;
            if (action == 'f') {
                self.storeKittyGraphicsFrameOwned(image_id, frame_number, format, width, height, owned);
            } else {
                self.storeKittyGraphicsImageOwned(image_id, image_number, format, width, height, owned);
            }
            self.kitty_graphics_upload = null;
        }
    }

    fn storeKittyGraphicsPayload(self: *VtCore, cmd: anytype, payload: []const u8) void {
        const owned = self.allocator.dupe(u8, payload) catch return;
        const image_id = self.imageIdForUpload(cmd);
        if (cmd.action == 'f') {
            self.storeKittyGraphicsFrameOwned(image_id, cmd.placement_id, cmd.format, cmd.width, cmd.height, owned);
        } else {
            self.storeKittyGraphicsImageOwned(image_id, cmd.image_number, cmd.format, cmd.width, cmd.height, owned);
            if (cmd.image_number != 0 and !cmd.quiet) self.appendKittyGraphicsNumberReply(image_id, cmd.image_number, "OK");
        }
    }

    fn imageIdForUpload(self: *VtCore, cmd: anytype) u32 {
        if (cmd.image_id != 0) return cmd.image_id;
        if (cmd.image_number == 0) return 0;
        const image_id = self.next_kitty_graphics_image_id;
        self.next_kitty_graphics_image_id +%= 1;
        if (self.next_kitty_graphics_image_id == 0) self.next_kitty_graphics_image_id = 1;
        return image_id;
    }

    fn storeKittyGraphicsImageOwned(self: *VtCore, image_id: u32, image_number: u32, format: u16, width: u32, height: u32, owned: []u8) void {
        const image = KittyGraphicsImage{ .image_id = image_id, .image_number = image_number, .format = format, .width = width, .height = height, .base64_payload = owned };
        if (image_id != 0) self.deleteKittyGraphicsImage(image_id);
        self.kitty_graphics_images.append(self.allocator, image) catch self.allocator.free(owned);
    }

    fn storeKittyGraphicsFrameOwned(self: *VtCore, image_id: u32, frame_number: u32, format: u16, width: u32, height: u32, owned: []u8) void {
        const frame = KittyGraphicsFrame{ .image_id = image_id, .frame_number = frame_number, .format = format, .width = width, .height = height, .base64_payload = owned };
        self.kitty_graphics_frames.append(self.allocator, frame) catch self.allocator.free(owned);
    }

    fn findKittyGraphicsImage(self: *const VtCore, image_id: u32) ?usize {
        for (self.kitty_graphics_images.items, 0..) |image, idx| {
            if (image.image_id == image_id) return idx;
        }
        return null;
    }

    fn findNewestKittyGraphicsImageByNumber(self: *const VtCore, image_number: u32) ?usize {
        if (image_number == 0) return null;
        var idx = self.kitty_graphics_images.items.len;
        while (idx > 0) {
            idx -= 1;
            if (self.kitty_graphics_images.items[idx].image_number == image_number) return idx;
        }
        return null;
    }

    fn resolveKittyGraphicsImageId(self: *const VtCore, cmd: anytype) ?u32 {
        if (cmd.image_id != 0 and cmd.image_number != 0) return null;
        if (cmd.image_id != 0) return if (self.findKittyGraphicsImage(cmd.image_id) != null) cmd.image_id else null;
        if (cmd.image_number != 0) {
            const idx = self.findNewestKittyGraphicsImageByNumber(cmd.image_number) orelse return null;
            return self.kitty_graphics_images.items[idx].image_id;
        }
        return null;
    }

    fn abortKittyGraphicsUpload(self: *VtCore) void {
        if (self.kitty_graphics_upload) |*upload| upload.data.deinit(self.allocator);
        self.kitty_graphics_upload = null;
    }

    fn deleteKittyGraphicsImage(self: *VtCore, image_id: u32) void {
        var idx: usize = 0;
        while (idx < self.kitty_graphics_images.items.len) {
            if (self.kitty_graphics_images.items[idx].image_id == image_id) {
                self.allocator.free(self.kitty_graphics_images.items[idx].base64_payload);
                _ = self.kitty_graphics_images.swapRemove(idx);
            } else idx += 1;
        }
        idx = 0;
        while (idx < self.kitty_graphics_placements.items.len) {
            if (self.kitty_graphics_placements.items[idx].image_id == image_id) _ = self.kitty_graphics_placements.swapRemove(idx) else idx += 1;
        }
        idx = 0;
        while (idx < self.kitty_graphics_frames.items.len) {
            if (self.kitty_graphics_frames.items[idx].image_id == image_id) {
                self.allocator.free(self.kitty_graphics_frames.items[idx].base64_payload);
                _ = self.kitty_graphics_frames.swapRemove(idx);
            } else idx += 1;
        }
    }

    fn deleteKittyGraphicsPlacement(self: *VtCore, image_id: u32, placement_id: u32) void {
        var idx: usize = 0;
        while (idx < self.kitty_graphics_placements.items.len) {
            const placement = self.kitty_graphics_placements.items[idx];
            if (placement.image_id == image_id and placement.placement_id == placement_id) _ = self.kitty_graphics_placements.swapRemove(idx) else idx += 1;
        }
    }

    fn deleteKittyGraphicsPlacementsAt(self: *VtCore, x: u32, y: u32, z: ?i32) void {
        if (x == 0 or y == 0) return;
        const col = x - 1;
        const row = y - 1;
        var idx: usize = 0;
        while (idx < self.kitty_graphics_placements.items.len) {
            const p = self.kitty_graphics_placements.items[idx];
            const cols = @max(p.columns, 1);
            const rows = @max(p.rows, 1);
            const intersects = col >= p.col and col < p.col + cols and row >= p.row and row < p.row + rows and (z == null or p.z_index == z.?);
            if (intersects) _ = self.kitty_graphics_placements.swapRemove(idx) else idx += 1;
        }
    }

    fn deleteKittyGraphicsPlacementsInColumn(self: *VtCore, x: u32) void {
        if (x == 0) return;
        const col = x - 1;
        var idx: usize = 0;
        while (idx < self.kitty_graphics_placements.items.len) {
            const p = self.kitty_graphics_placements.items[idx];
            const cols = @max(p.columns, 1);
            if (col >= p.col and col < p.col + cols) _ = self.kitty_graphics_placements.swapRemove(idx) else idx += 1;
        }
    }

    fn deleteKittyGraphicsPlacementsInRow(self: *VtCore, y: u32) void {
        if (y == 0) return;
        const row = y - 1;
        var idx: usize = 0;
        while (idx < self.kitty_graphics_placements.items.len) {
            const p = self.kitty_graphics_placements.items[idx];
            const rows = @max(p.rows, 1);
            if (row >= p.row and row < p.row + rows) _ = self.kitty_graphics_placements.swapRemove(idx) else idx += 1;
        }
    }

    fn deleteKittyGraphicsPlacementsByZ(self: *VtCore, z: i32) void {
        var idx: usize = 0;
        while (idx < self.kitty_graphics_placements.items.len) {
            if (self.kitty_graphics_placements.items[idx].z_index == z) _ = self.kitty_graphics_placements.swapRemove(idx) else idx += 1;
        }
    }

    fn deleteKittyGraphicsImagesInRange(self: *VtCore, first: u32, last: u32) void {
        const lo = @min(first, last);
        const hi = @max(first, last);
        var idx: usize = 0;
        while (idx < self.kitty_graphics_images.items.len) {
            const image_id = self.kitty_graphics_images.items[idx].image_id;
            if (image_id >= lo and image_id <= hi) self.deleteKittyGraphicsImage(image_id) else idx += 1;
        }
    }

    fn deleteUnplacedKittyGraphicsImages(self: *VtCore) void {
        var idx: usize = 0;
        while (idx < self.kitty_graphics_images.items.len) {
            const image_id = self.kitty_graphics_images.items[idx].image_id;
            if (!self.kittyGraphicsImageHasPlacement(image_id)) self.deleteKittyGraphicsImage(image_id) else idx += 1;
        }
    }

    fn kittyGraphicsImageHasPlacement(self: *const VtCore, image_id: u32) bool {
        for (self.kitty_graphics_placements.items) |placement| if (placement.image_id == image_id) return true;
        return false;
    }

    fn deleteKittyGraphicsFrames(self: *VtCore, cmd: anytype) void {
        const image_id = self.resolveKittyGraphicsImageId(cmd) orelse cmd.image_id;
        var idx: usize = 0;
        while (idx < self.kitty_graphics_frames.items.len) {
            const frame = self.kitty_graphics_frames.items[idx];
            if ((image_id == 0 or frame.image_id == image_id) and (cmd.placement_id == 0 or frame.frame_number == cmd.placement_id)) {
                self.allocator.free(self.kitty_graphics_frames.items[idx].base64_payload);
                _ = self.kitty_graphics_frames.swapRemove(idx);
            } else idx += 1;
        }
    }

    fn deleteAllKittyGraphics(self: *VtCore) void {
        for (self.kitty_graphics_images.items) |image| self.allocator.free(image.base64_payload);
        self.kitty_graphics_images.clearRetainingCapacity();
        self.kitty_graphics_placements.clearRetainingCapacity();
        for (self.kitty_graphics_frames.items) |frame| self.allocator.free(frame.base64_payload);
        self.kitty_graphics_frames.clearRetainingCapacity();
    }

    fn appendKittyGraphicsReply(self: *VtCore, image_id: u32, msg: []const u8) void {
        const text = std.fmt.bufPrint(self.encode_buf[0..], "\x1b_Gi={d};{s}\x1b\\", .{ image_id, msg }) catch return;
        self.appendPendingOutput(text);
    }

    fn appendKittyGraphicsNumberReply(self: *VtCore, image_id: u32, image_number: u32, msg: []const u8) void {
        const text = std.fmt.bufPrint(self.encode_buf[0..], "\x1b_Gi={d},I={d};{s}\x1b\\", .{ image_id, image_number, msg }) catch return;
        self.appendPendingOutput(text);
    }

    fn appendPendingOutput(self: *VtCore, bytes: []const u8) void {
        self.pending_output.appendSlice(self.allocator, bytes) catch {};
    }

    fn appendCursorPositionReport(self: *VtCore) void {
        const view = self.renderView();
        const text = std.fmt.bufPrint(self.encode_buf[0..], "\x1b[{d};{d}R", .{ view.cursor_row + 1, view.cursor_col + 1 }) catch return;
        self.appendPendingOutput(text);
    }

    fn appendDecCursorPositionReport(self: *VtCore) void {
        const view = self.renderView();
        const text = std.fmt.bufPrint(self.encode_buf[0..], "\x1b[?{d};{d}R", .{ view.cursor_row + 1, view.cursor_col + 1 }) catch return;
        self.appendPendingOutput(text);
    }

    fn appendDecModeReport(self: *VtCore, mode: u16) void {
        const state = self.decModeState(mode);
        const text = std.fmt.bufPrint(self.encode_buf[0..], "\x1b[?{d};{d}$y", .{ mode, state }) catch return;
        self.appendPendingOutput(text);
    }

    fn decModeState(self: *const VtCore, mode: u16) u8 {
        return switch (mode) {
            1 => boolToDecModeState(self.application_cursor_keys),
            7 => boolToDecModeState(self.activeState().auto_wrap),
            66 => boolToDecModeState(self.application_keypad),
            25 => boolToDecModeState(self.activeState().cursor_visible),
            47, 1047, 1049 => boolToDecModeState(self.alt_active),
            9 => if (self.mouse_tracking == .x10) 1 else 2,
            1000 => if (self.mouse_tracking == .normal) 1 else 2,
            1002 => if (self.mouse_tracking == .button_event) 1 else 2,
            1003 => if (self.mouse_tracking == .any_event) 1 else 2,
            1004 => boolToDecModeState(self.focus_reporting),
            1005 => boolToDecModeState(self.mouse_protocol == .utf8),
            1006 => boolToDecModeState(self.mouse_protocol == .sgr),
            1015 => boolToDecModeState(self.mouse_protocol == .urxvt),
            2004 => boolToDecModeState(self.bracketed_paste),
            else => 0,
        };
    }

    fn boolToDecModeState(enabled: bool) u8 {
        return if (enabled) 1 else 2;
    }

    fn saveDecModes(self: *VtCore, modes: []const u16) void {
        for (modes) |mode| {
            if (!self.canSetDecMode(mode)) continue;
            self.saved_dec_modes[self.savedDecModeSlot(mode)] = .{ .mode = mode, .state = self.decModeState(mode) };
        }
    }

    fn restoreDecModes(self: *VtCore, modes: []const u16) void {
        for (modes) |mode| {
            const state = self.savedDecModeState(mode) orelse continue;
            switch (state) {
                1 => self.setDecMode(mode, true),
                2 => self.setDecMode(mode, false),
                else => {},
            }
        }
    }

    fn savedDecModeSlot(self: *VtCore, mode: u16) usize {
        var idx: usize = 0;
        while (idx < self.saved_dec_mode_count) : (idx += 1) {
            if (self.saved_dec_modes[idx].mode == mode) return idx;
        }
        if (self.saved_dec_mode_count < self.saved_dec_modes.len) {
            const slot = self.saved_dec_mode_count;
            self.saved_dec_mode_count += 1;
            return slot;
        }
        return self.saved_dec_modes.len - 1;
    }

    fn savedDecModeState(self: *const VtCore, mode: u16) ?u8 {
        var idx: usize = 0;
        while (idx < self.saved_dec_mode_count) : (idx += 1) {
            if (self.saved_dec_modes[idx].mode == mode) return self.saved_dec_modes[idx].state;
        }
        return null;
    }

    fn canSetDecMode(self: *const VtCore, mode: u16) bool {
        _ = self;
        return switch (mode) {
            1, 6, 7, 9, 25, 47, 66, 1047, 1049, 1000, 1002, 1003, 1004, 1005, 1006, 1015, 2004 => true,
            else => false,
        };
    }

    fn setDecMode(self: *VtCore, mode: u16, enabled: bool) void {
        switch (mode) {
            1 => self.application_cursor_keys = enabled,
            6 => self.activeStateMut().apply(.{ .origin_mode = enabled }),
            7 => self.activeStateMut().apply(.{ .auto_wrap = enabled }),
            25 => self.activeStateMut().apply(.{ .cursor_visible = enabled }),
            66 => self.application_keypad = enabled,
            47 => if (enabled) self.enterAltScreen(false, false) else self.exitAltScreen(false),
            1047 => if (enabled) self.enterAltScreen(true, false) else self.exitAltScreen(false),
            1049 => if (enabled) self.enterAltScreen(true, true) else self.exitAltScreen(true),
            9 => self.mouse_tracking = if (enabled) .x10 else .off,
            1000 => self.mouse_tracking = if (enabled) .normal else .off,
            1002 => self.mouse_tracking = if (enabled) .button_event else .off,
            1003 => self.mouse_tracking = if (enabled) .any_event else .off,
            1004 => self.focus_reporting = enabled,
            1005 => self.mouse_protocol = if (enabled) .utf8 else .none,
            1006 => self.mouse_protocol = if (enabled) .sgr else .none,
            1015 => self.mouse_protocol = if (enabled) .urxvt else .none,
            2004 => self.bracketed_paste = enabled,
            else => {},
        }
    }

    fn internHyperlink(self: *VtCore, uri: []const u8) u32 {
        for (self.hyperlink_targets.items, 0..) |existing, idx| {
            if (std.mem.eql(u8, existing, uri)) return @intCast(idx + 1);
        }
        const owned = self.allocator.dupe(u8, uri) catch return 0;
        self.hyperlink_targets.append(self.allocator, owned) catch {
            self.allocator.free(owned);
            return 0;
        };
        return @intCast(self.hyperlink_targets.items.len);
    }

    fn setPendingClipboard(self: *VtCore, payload: []const u8) void {
        if (self.pending_clipboard) |req| self.allocator.free(req.raw);
        const owned = self.allocator.dupe(u8, payload) catch {
            self.pending_clipboard = null;
            return;
        };
        self.pending_clipboard = .{ .raw = owned };
    }

    fn enterAltScreen(self: *VtCore, clear_alt: bool, save_cursor: bool) void {
        if (save_cursor) {
            self.saved_primary_cursor = .{
                .row = self.primary_state.cursor_row,
                .col = self.primary_state.cursor_col,
                .wrap_pending = self.primary_state.wrap_pending,
                .cursor_visible = self.primary_state.cursor_visible,
            };
        }
        if (clear_alt) self.alt_state.reset();
        self.alt_active = true;
        self.alt_state.markAllDirty();
        self.selection.clear();
    }

    fn exitAltScreen(self: *VtCore, restore_cursor: bool) void {
        self.alt_active = false;
        if (restore_cursor) {
            if (self.saved_primary_cursor) |saved| {
                self.primary_state.cursor_row = @min(saved.row, self.primary_state.rows -| 1);
                self.primary_state.cursor_col = @min(saved.col, self.primary_state.cols -| 1);
                self.primary_state.wrap_pending = saved.wrap_pending;
                self.primary_state.cursor_visible = saved.cursor_visible;
            }
            self.saved_primary_cursor = null;
        }
        self.primary_state.markAllDirty();
        self.selection.clear();
    }
};

fn firstKittyPointerShape(names: []const u8) ?KittyPointerShape {
    var parts = std.mem.splitScalar(u8, names, ',');
    while (parts.next()) |name| {
        if (parseKittyPointerShapeName(name)) |shape| return shape;
    }
    return null;
}

fn parseKittyPointerShapeName(name: []const u8) ?KittyPointerShape {
    if (std.mem.eql(u8, name, "alias")) return .alias;
    if (std.mem.eql(u8, name, "cell")) return .cell;
    if (std.mem.eql(u8, name, "copy")) return .copy;
    if (std.mem.eql(u8, name, "crosshair")) return .crosshair;
    if (std.mem.eql(u8, name, "default")) return .@"default";
    if (std.mem.eql(u8, name, "e-resize")) return .e_resize;
    if (std.mem.eql(u8, name, "ew-resize")) return .ew_resize;
    if (std.mem.eql(u8, name, "grab")) return .grab;
    if (std.mem.eql(u8, name, "grabbing")) return .grabbing;
    if (std.mem.eql(u8, name, "help")) return .help;
    if (std.mem.eql(u8, name, "move")) return .move;
    if (std.mem.eql(u8, name, "n-resize")) return .n_resize;
    if (std.mem.eql(u8, name, "ne-resize")) return .ne_resize;
    if (std.mem.eql(u8, name, "nesw-resize")) return .nesw_resize;
    if (std.mem.eql(u8, name, "no-drop")) return .no_drop;
    if (std.mem.eql(u8, name, "not-allowed")) return .not_allowed;
    if (std.mem.eql(u8, name, "ns-resize")) return .ns_resize;
    if (std.mem.eql(u8, name, "nw-resize")) return .nw_resize;
    if (std.mem.eql(u8, name, "nwse-resize")) return .nwse_resize;
    if (std.mem.eql(u8, name, "pointer")) return .pointer;
    if (std.mem.eql(u8, name, "progress")) return .progress;
    if (std.mem.eql(u8, name, "s-resize")) return .s_resize;
    if (std.mem.eql(u8, name, "se-resize")) return .se_resize;
    if (std.mem.eql(u8, name, "sw-resize")) return .sw_resize;
    if (std.mem.eql(u8, name, "text")) return .text;
    if (std.mem.eql(u8, name, "vertical-text")) return .vertical_text;
    if (std.mem.eql(u8, name, "w-resize")) return .w_resize;
    if (std.mem.eql(u8, name, "wait")) return .wait;
    if (std.mem.eql(u8, name, "zoom-in")) return .zoom_in;
    if (std.mem.eql(u8, name, "zoom-out")) return .zoom_out;
    return null;
}

fn kittyPointerShapeName(shape: KittyPointerShape) []const u8 {
    return switch (shape) {
        .alias => "alias",
        .cell => "cell",
        .copy => "copy",
        .crosshair => "crosshair",
        .@"default" => "default",
        .e_resize => "e-resize",
        .ew_resize => "ew-resize",
        .grab => "grab",
        .grabbing => "grabbing",
        .help => "help",
        .move => "move",
        .n_resize => "n-resize",
        .ne_resize => "ne-resize",
        .nesw_resize => "nesw-resize",
        .no_drop => "no-drop",
        .not_allowed => "not-allowed",
        .ns_resize => "ns-resize",
        .nw_resize => "nw-resize",
        .nwse_resize => "nwse-resize",
        .pointer => "pointer",
        .progress => "progress",
        .s_resize => "s-resize",
        .se_resize => "se-resize",
        .sw_resize => "sw-resize",
        .text => "text",
        .vertical_text => "vertical-text",
        .w_resize => "w-resize",
        .wait => "wait",
        .zoom_in => "zoom-in",
        .zoom_out => "zoom-out",
    };
}

fn defaultPalette() [256]Color {
    @setEvalBranchQuota(4096);
    var palette: [256]Color = undefined;
    var idx: u16 = 0;
    while (idx < 256) : (idx += 1) palette[idx] = defaultPaletteColor(@intCast(idx));
    return palette;
}

fn defaultPaletteColor(idx: u8) Color {
    if (idx < 16) return ansi16Color(idx);
    if (idx < 232) {
        const n = idx - 16;
        const r = cubeComponent(n / 36);
        const g = cubeComponent((n / 6) % 6);
        const b = cubeComponent(n % 6);
        return .{ .r = r, .g = g, .b = b };
    }
    const gray: u8 = 8 + (idx - 232) * 10;
    return .{ .r = gray, .g = gray, .b = gray };
}

fn cubeComponent(v: u8) u8 {
    return if (v == 0) 0 else 55 + v * 40;
}

fn ansi16Color(idx: u8) Color {
    return switch (idx) {
        0 => .{ .r = 0, .g = 0, .b = 0 },
        1 => .{ .r = 205, .g = 49, .b = 49 },
        2 => .{ .r = 13, .g = 188, .b = 121 },
        3 => .{ .r = 229, .g = 229, .b = 16 },
        4 => .{ .r = 36, .g = 114, .b = 200 },
        5 => .{ .r = 188, .g = 63, .b = 188 },
        6 => .{ .r = 17, .g = 168, .b = 205 },
        7 => .{ .r = 229, .g = 229, .b = 229 },
        8 => .{ .r = 102, .g = 102, .b = 102 },
        9 => .{ .r = 241, .g = 76, .b = 76 },
        10 => .{ .r = 35, .g = 209, .b = 139 },
        11 => .{ .r = 245, .g = 245, .b = 67 },
        12 => .{ .r = 59, .g = 142, .b = 234 },
        13 => .{ .r = 214, .g = 112, .b = 214 },
        14 => .{ .r = 41, .g = 184, .b = 219 },
        else => .{ .r = 255, .g = 255, .b = 255 },
    };
}

fn parseColor(value: []const u8) ?Color {
    const color_text = stripAlpha(std.mem.trim(u8, value, " \t\r\n"));
    if (color_text.len == 0) return null;
    if (std.mem.startsWith(u8, color_text, "#")) return parseHashColor(color_text[1..]);
    if (std.mem.startsWith(u8, color_text, "rgb:")) return parseRgbColor(color_text[4..]);
    if (std.ascii.eqlIgnoreCase(color_text, "black")) return .{ .r = 0, .g = 0, .b = 0 };
    if (std.ascii.eqlIgnoreCase(color_text, "red")) return .{ .r = 255, .g = 0, .b = 0 };
    if (std.ascii.eqlIgnoreCase(color_text, "green")) return .{ .r = 0, .g = 255, .b = 0 };
    if (std.ascii.eqlIgnoreCase(color_text, "blue")) return .{ .r = 0, .g = 0, .b = 255 };
    if (std.ascii.eqlIgnoreCase(color_text, "white")) return .{ .r = 255, .g = 255, .b = 255 };
    return null;
}

fn stripAlpha(value: []const u8) []const u8 {
    const at = std.mem.indexOfScalar(u8, value, '@') orelse return value;
    return value[0..at];
}

fn parseHashColor(hex: []const u8) ?Color {
    return switch (hex.len) {
        3 => blk: {
            const r = parseHexNibble(hex[0]) orelse return null;
            const g = parseHexNibble(hex[1]) orelse return null;
            const b = parseHexNibble(hex[2]) orelse return null;
            break :blk .{ .r = r << 4, .g = g << 4, .b = b << 4 };
        },
        6 => .{ .r = parseHexByte(hex[0..2]) orelse return null, .g = parseHexByte(hex[2..4]) orelse return null, .b = parseHexByte(hex[4..6]) orelse return null },
        9 => .{ .r = parseHexByte(hex[0..2]) orelse return null, .g = parseHexByte(hex[3..5]) orelse return null, .b = parseHexByte(hex[6..8]) orelse return null },
        12 => .{ .r = parseHexByte(hex[0..2]) orelse return null, .g = parseHexByte(hex[4..6]) orelse return null, .b = parseHexByte(hex[8..10]) orelse return null },
        else => null,
    };
}

fn parseRgbColor(text: []const u8) ?Color {
    var parts = std.mem.splitScalar(u8, text, '/');
    const r = parseRgbComponent(parts.next() orelse return null) orelse return null;
    const g = parseRgbComponent(parts.next() orelse return null) orelse return null;
    const b = parseRgbComponent(parts.next() orelse return null) orelse return null;
    return .{ .r = r, .g = g, .b = b };
}

fn parseRgbComponent(text: []const u8) ?u8 {
    if (text.len == 0 or text.len > 4) return null;
    const value = std.fmt.parseUnsigned(u16, text, 16) catch return null;
    return switch (text.len) {
        1 => @intCast(value * 17),
        2 => @intCast(value),
        3 => @intCast(value >> 4),
        4 => @intCast(value >> 8),
        else => null,
    };
}

fn parseHexByte(text: []const u8) ?u8 {
    if (text.len != 2) return null;
    return std.fmt.parseUnsigned(u8, text, 16) catch null;
}

fn parseHexNibble(byte: u8) ?u8 {
    return switch (byte) {
        '0'...'9' => byte - '0',
        'a'...'f' => byte - 'a' + 10,
        'A'...'F' => byte - 'A' + 10,
        else => null,
    };
}

fn specialColorKey(key: []const u8) ?SpecialColorKey {
    if (std.mem.eql(u8, key, "foreground")) return .foreground;
    if (std.mem.eql(u8, key, "background")) return .background;
    if (std.mem.eql(u8, key, "cursor")) return .cursor;
    if (std.mem.eql(u8, key, "cursor_text")) return .cursor_text;
    if (std.mem.eql(u8, key, "selection_background")) return .selection_background;
    if (std.mem.eql(u8, key, "selection_foreground")) return .selection_foreground;
    return null;
}

fn isKnownColorKey(key: []const u8) bool {
    if (specialColorKey(key) != null) return true;
    _ = std.fmt.parseUnsigned(u8, key, 10) catch return false;
    return true;
}

fn colorForKey(colors: TerminalColorState, key: []const u8) ?Color {
    if (std.fmt.parseUnsigned(u8, key, 10)) |idx| return colors.palette[idx] else |_| {}
    if (specialColorKey(key)) |special| return switch (special) {
        .foreground => colors.foreground,
        .background => colors.background,
        .cursor => colors.cursor,
        .cursor_text => colors.cursor_text,
        .selection_background => colors.selection_background,
        .selection_foreground => colors.selection_foreground,
    };
    return null;
}

pub const Grid = grid_owner.Grid;

test "VtCore facade methods remain available" {
    try std.testing.expect(@hasDecl(VtCore, "init"));
    try std.testing.expect(@hasDecl(VtCore, "initWithCells"));
    try std.testing.expect(@hasDecl(VtCore, "deinit"));
    try std.testing.expect(@hasDecl(VtCore, "feedByte"));
    try std.testing.expect(@hasDecl(VtCore, "feedSlice"));
    try std.testing.expect(@hasDecl(VtCore, "apply"));
    try std.testing.expect(@hasDecl(VtCore, "clear"));
    try std.testing.expect(@hasDecl(VtCore, "reset"));
    try std.testing.expect(@hasDecl(VtCore, "resetScreen"));
    try std.testing.expect(@hasDecl(VtCore, "resize"));
    try std.testing.expect(@hasDecl(VtCore, "screen"));
    try std.testing.expect(@hasDecl(VtCore, "queuedEventCount"));
}

test "VtCore method signatures remain host-facing" {
    const Allocator = std.mem.Allocator;
    const GridModel = GridNs.GridModel;
    const init_fn: fn (Allocator, u16, u16) anyerror!VtCore = VtCore.init;
    const init_cells_fn: fn (Allocator, u16, u16) anyerror!VtCore = VtCore.initWithCells;
    const deinit_fn: fn (*VtCore) void = VtCore.deinit;
    const feed_byte_fn: fn (*VtCore, u8) void = VtCore.feedByte;
    const feed_slice_fn: fn (*VtCore, []const u8) void = VtCore.feedSlice;
    const apply_fn: fn (*VtCore) void = VtCore.apply;
    const clear_fn: fn (*VtCore) void = VtCore.clear;
    const reset_fn: fn (*VtCore) void = VtCore.reset;
    const reset_screen_fn: fn (*VtCore) void = VtCore.resetScreen;
    const resize_fn: fn (*VtCore, u16, u16) anyerror!void = VtCore.resize;
    const screen_fn: fn (*const VtCore) *const GridModel = VtCore.screen;
    const queue_fn: fn (*const VtCore) usize = VtCore.queuedEventCount;
    _ = .{ init_fn, init_cells_fn, deinit_fn, feed_byte_fn, feed_slice_fn, apply_fn, clear_fn, reset_fn, reset_screen_fn, resize_fn, screen_fn, queue_fn };
}

test "const-read history and selection accessors stay stable" {
    const history_row_fn: fn (*const VtCore, usize, u16) u21 = VtCore.historyRowAt;
    const history_count_fn: fn (*const VtCore) usize = VtCore.historyCount;
    const history_capacity_fn: fn (*const VtCore) u16 = VtCore.historyCapacity;
    const selection_state_fn: fn (*const VtCore) ?Selection.TerminalSelection = VtCore.selectionState;
    _ = .{ history_row_fn, history_count_fn, history_capacity_fn, selection_state_fn };
}

test "lifecycle extension methods stay stable" {
    const init_cells_history_fn: fn (std.mem.Allocator, u16, u16, u16) anyerror!VtCore = VtCore.initWithCellsAndHistory;
    const selection_start_fn: fn (*VtCore, i32, u16) void = VtCore.selectionStart;
    const selection_update_fn: fn (*VtCore, i32, u16) void = VtCore.selectionUpdate;
    const selection_finish_fn: fn (*VtCore) void = VtCore.selectionFinish;
    const selection_clear_fn: fn (*VtCore) void = VtCore.selectionClear;
    _ = .{ init_cells_history_fn, selection_start_fn, selection_update_fn, selection_finish_fn, selection_clear_fn };
}

test "snapshot surface remains deterministic" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 5, 10);
    defer vt_core.deinit();

    vt_core.feedSlice("TEST");
    vt_core.apply();

    var snap1 = try vt_core.snapshot();
    defer snap1.deinit();

    var snap2 = try vt_core.snapshot();
    defer snap2.deinit();

    try std.testing.expectEqual(snap1.rows, snap2.rows);
    try std.testing.expectEqual(snap1.cols, snap2.cols);
    try std.testing.expectEqual(snap1.cursor_row, snap2.cursor_row);
    try std.testing.expectEqual(snap1.cursor_col, snap2.cursor_col);
}

test "resize keeps history enabled state" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCellsAndHistory(allocator, 1, 3, 8);
    defer vt_core.deinit();

    vt_core.feedSlice("111\n222\n333");
    vt_core.apply();
    const before = vt_core.historyCount();
    try vt_core.resize(3, 3);

    try std.testing.expectEqual(@as(u16, 8), vt_core.historyCapacity());
    try std.testing.expect(vt_core.historyCount() <= before);
}

test "alternate screen exit preserves primary scrollback" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCellsAndHistory(allocator, 2, 4, 16);
    defer vt_core.deinit();

    vt_core.feedSlice("AAAA\nBBBB\nCCCC\nDDDD");
    vt_core.apply();
    var before = try vt_core.snapshot();
    defer before.deinit();
    const history_before = vt_core.historyCount();
    try std.testing.expect(history_before > 0);

    vt_core.feedSlice("\x1b[?1049hALT!");
    vt_core.apply();
    try std.testing.expect(vt_core.isAlternateScreen());
    try std.testing.expectEqual(@as(usize, 0), vt_core.historyCount());
    try std.testing.expectEqual(@as(u21, 'A'), vt_core.screen().cellAt(0, 0));

    vt_core.feedSlice("\x1b[?1049l");
    vt_core.apply();
    var after = try vt_core.snapshot();
    defer after.deinit();
    try std.testing.expect(!vt_core.isAlternateScreen());
    try std.testing.expectEqual(history_before, vt_core.historyCount());
    try std.testing.expectEqual(before.cursor_row, after.cursor_row);
    try std.testing.expectEqual(before.cursor_col, after.cursor_col);
    var row: u16 = 0;
    while (row < before.rows) : (row += 1) {
        var col: u16 = 0;
        while (col < before.cols) : (col += 1) {
            try std.testing.expectEqual(before.cellAt(row, col), after.cellAt(row, col));
        }
    }
}

test "alternate screen 1049 restores primary cursor" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 4, 8);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b[3;4H\x1b[?1049h\x1b[2;2H\x1b[?1049l");
    vt_core.apply();
    try std.testing.expectEqual(@as(u16, 2), vt_core.screen().cursor_row);
    try std.testing.expectEqual(@as(u16, 3), vt_core.screen().cursor_col);
}

test "alternate screen switches mark active viewport fully dirty" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 4);
    defer vt_core.deinit();
    vt_core.activeStateMut().clearDirtyRows();
    vt_core.feedSlice("\x1b[?1049h");
    vt_core.apply();
    const enter_dirty = vt_core.screen().peekDirtyRows().?;
    try std.testing.expectEqual(@as(u16, 0), enter_dirty.start_row);
    try std.testing.expectEqual(@as(u16, 2), enter_dirty.end_row);
    try std.testing.expectEqual(@as(u16, 0), enter_dirty.dirty_cols_start[0]);
    try std.testing.expectEqual(@as(u16, 3), enter_dirty.dirty_cols_end[2]);

    vt_core.activeStateMut().clearDirtyRows();
    vt_core.feedSlice("\x1b[?1049l");
    vt_core.apply();
    const exit_dirty = vt_core.screen().peekDirtyRows().?;
    try std.testing.expectEqual(@as(u16, 0), exit_dirty.start_row);
    try std.testing.expectEqual(@as(u16, 2), exit_dirty.end_row);
    try std.testing.expectEqual(@as(u16, 0), exit_dirty.dirty_cols_start[0]);
    try std.testing.expectEqual(@as(u16, 3), exit_dirty.dirty_cols_end[2]);
}

test "encodeKey and encodeMouse methods are callable" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 5, 10);
    defer vt_core.deinit();

    const encode_key_fn: fn (*VtCore, Input.Key, Input.Modifier) []const u8 = VtCore.encodeKey;
    const encode_mouse_fn: fn (*VtCore, Input.MouseEvent) []const u8 = VtCore.encodeMouse;
    _ = .{ encode_key_fn, encode_mouse_fn };

    vt_core.feedSlice("TEST");
    vt_core.apply();

    var snap_before = try vt_core.snapshot();
    defer snap_before.deinit();

    _ = vt_core.encodeKey('A', 0);
    _ = vt_core.encodeKey('B', 0);

    var snap_after = try vt_core.snapshot();
    defer snap_after.deinit();

    try std.testing.expectEqual(snap_before.cursor_row, snap_after.cursor_row);
    try std.testing.expectEqual(snap_before.cursor_col, snap_after.cursor_col);
    try std.testing.expectEqual(snap_before.history_count, snap_after.history_count);
    try std.testing.expectEqual(snap_before.selection, snap_after.selection);
}

test "encodeMouse returns empty output and does not mutate state" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 5, 10);
    defer vt_core.deinit();

    vt_core.feedSlice("HELLO");
    vt_core.apply();

    var snap_before = try vt_core.snapshot();
    defer snap_before.deinit();

    const mouse_event = Input.MouseEvent{
        .kind = .press,
        .button = .left,
        .row = 2,
        .col = 3,
        .pixel_x = null,
        .pixel_y = null,
        .mod = 0,
        .buttons_down = 1,
    };

    const output = vt_core.encodeMouse(mouse_event);
    try std.testing.expectEqual(@as(usize, 0), output.len);
    try std.testing.expectEqualSlices(u8, "", output);

    var snap_after = try vt_core.snapshot();
    defer snap_after.deinit();

    try std.testing.expectEqual(snap_before.cursor_row, snap_after.cursor_row);
    try std.testing.expectEqual(snap_before.cursor_col, snap_after.cursor_col);
    try std.testing.expectEqual(snap_before.selection, snap_after.selection);
    try std.testing.expectEqual(snap_before.history_count, snap_after.history_count);
}

test "mouse reporting is gated by DECSET mouse modes and SGR protocol" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 5, 10);
    defer vt_core.deinit();

    const mouse_event = Input.MouseEvent{
        .kind = .press,
        .button = .left,
        .row = 2,
        .col = 3,
        .pixel_x = null,
        .pixel_y = null,
        .mod = 0,
        .buttons_down = 1,
    };

    try std.testing.expectEqualStrings("", vt_core.encodeMouse(mouse_event));
    vt_core.feedSlice("\x1b[?1000h\x1b[?1006h");
    vt_core.apply();
    try std.testing.expectEqualStrings("\x1b[<0;4;3M", vt_core.encodeMouse(mouse_event));

    const move_event = Input.MouseEvent{
        .kind = .move,
        .button = .left,
        .row = 2,
        .col = 3,
        .pixel_x = null,
        .pixel_y = null,
        .mod = 0,
        .buttons_down = 1,
    };
    try std.testing.expectEqualStrings("", vt_core.encodeMouse(move_event));
    vt_core.feedSlice("\x1b[?1002h");
    vt_core.apply();
    try std.testing.expectEqualStrings("\x1b[<32;4;3M", vt_core.encodeMouse(move_event));
    vt_core.feedSlice("\x1b[?1003h");
    vt_core.apply();
    const hover_event = Input.MouseEvent{
        .kind = .move,
        .button = .none,
        .row = 1,
        .col = 1,
        .pixel_x = null,
        .pixel_y = null,
        .mod = 0,
        .buttons_down = 0,
    };
    try std.testing.expectEqualStrings("\x1b[<35;2;2M", vt_core.encodeMouse(hover_event));
}

test "mouse reporting supports legacy x10 normal utf8 and urxvt encodings" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 5, 10);
    defer vt_core.deinit();

    const press = Input.MouseEvent{ .kind = .press, .button = .left, .row = 2, .col = 3, .mod = VtCore.mod_shift | VtCore.mod_alt, .buttons_down = 1 };
    const release = Input.MouseEvent{ .kind = .release, .button = .left, .row = 2, .col = 3, .mod = 0, .buttons_down = 0 };
    const wheel = Input.MouseEvent{ .kind = .wheel, .button = .wheel_down, .row = 2, .col = 3, .mod = 0, .buttons_down = 0 };

    vt_core.feedSlice("\x1b[?9h");
    vt_core.apply();
    try std.testing.expectEqualStrings("\x1b[M $#", vt_core.encodeMouse(press));
    try std.testing.expectEqualStrings("", vt_core.encodeMouse(release));

    vt_core.feedSlice("\x1b[?1000h");
    vt_core.apply();
    try std.testing.expectEqualStrings("\x1b[M,$#", vt_core.encodeMouse(press));
    try std.testing.expectEqualStrings("\x1b[M#$#", vt_core.encodeMouse(release));
    try std.testing.expectEqualStrings("\x1b[Ma$#", vt_core.encodeMouse(wheel));

    vt_core.feedSlice("\x1b[?1005h");
    vt_core.apply();
    const far_press = Input.MouseEvent{ .kind = .press, .button = .left, .row = 240, .col = 240, .mod = 0, .buttons_down = 1 };
    try std.testing.expectEqualStrings("\x1b[M \xc4\x91\xc4\x91", vt_core.encodeMouse(far_press));

    vt_core.feedSlice("\x1b[?1015h");
    vt_core.apply();
    try std.testing.expectEqualStrings("\x1b[32;241;241M", vt_core.encodeMouse(far_press));
}

test "mouse mode queries and save restore include extended protocols" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 4, 8);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b[?1003h\x1b[?1005h\x1b[?1003;1005s");
    vt_core.feedSlice("\x1b[?1000h\x1b[?1006h");
    vt_core.feedSlice("\x1b[?1003;1005r");
    vt_core.feedSlice("\x1b[?9$p\x1b[?1000$p\x1b[?1003$p\x1b[?1005$p\x1b[?1006$p\x1b[?1015$p");
    vt_core.apply();

    try std.testing.expectEqualStrings("\x1b[?9;2$y\x1b[?1000;2$y\x1b[?1003;1$y\x1b[?1005;1$y\x1b[?1006;2$y\x1b[?1015;2$y", vt_core.pendingOutput());
}

test "latestTitleSet returns typed OSC title payload" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 8);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b]0;My Title\x07");
    try std.testing.expectEqualStrings("My Title", vt_core.latestTitleSet().?);
}

test "OSC 8 assigns link ids and preserves URI lookup" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 16);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b]8;;https://example.com\x07abc\x1b]8;;\x07z");
    vt_core.apply();

    const first = vt_core.screen().cellInfoAt(0, 0).attrs.link_id;
    const second = vt_core.screen().cellInfoAt(0, 1).attrs.link_id;
    const third = vt_core.screen().cellInfoAt(0, 2).attrs.link_id;
    const trailing = vt_core.screen().cellInfoAt(0, 3).attrs.link_id;
    try std.testing.expect(first != 0);
    try std.testing.expectEqual(first, second);
    try std.testing.expectEqual(first, third);
    try std.testing.expectEqual(@as(u32, 0), trailing);
    try std.testing.expectEqualStrings("https://example.com", vt_core.hyperlinkUriForId(first).?);
}

test "OSC 52 produces pending clipboard request" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 16);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b]52;c;Zm9v\x07");
    vt_core.apply();
    try std.testing.expectEqualStrings("c;Zm9v", vt_core.pendingClipboardSet().?);
    vt_core.clearPendingClipboardSet();
    try std.testing.expectEqual(@as(?[]const u8, null), vt_core.pendingClipboardSet());
}

test "kitty graphics query returns conservative unsupported reply" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 16);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b_Gi=31,s=1,v=1,a=q,t=d,f=24;AAAA\x1b\\");
    vt_core.apply();

    try std.testing.expectEqualStrings("\x1b_Gi=31;EINVAL:kitty graphics rendering unsupported\x1b\\", vt_core.pendingOutput());
}

test "kitty graphics direct upload stores single base64 payload" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 16);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b_Gi=7,s=2,v=1,t=d,f=24;QUJD\x1b\\");
    vt_core.apply();

    try std.testing.expectEqual(@as(usize, 1), vt_core.kittyGraphicsImageCount());
    const image = vt_core.kittyGraphicsImageAt(0).?;
    try std.testing.expectEqual(@as(u32, 7), image.image_id);
    try std.testing.expectEqual(@as(u16, 24), image.format);
    try std.testing.expectEqual(@as(u32, 2), image.width);
    try std.testing.expectEqual(@as(u32, 1), image.height);
    try std.testing.expectEqualStrings("QUJD", image.base64_payload);
}

test "kitty graphics direct upload assembles chunked base64 payload" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 16);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b_Gi=9,s=2,v=1,t=d,f=24,m=1;QU\x1b\\");
    vt_core.feedSlice("\x1b_Gm=0;JD\x1b\\");
    vt_core.apply();

    try std.testing.expectEqual(@as(usize, 1), vt_core.kittyGraphicsImageCount());
    const image = vt_core.kittyGraphicsImageAt(0).?;
    try std.testing.expectEqual(@as(u32, 9), image.image_id);
    try std.testing.expectEqual(@as(u16, 24), image.format);
    try std.testing.expectEqualStrings("QUJD", image.base64_payload);
}

test "kitty graphics upload with same image id replaces image and placements" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 16);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b_Gi=7,s=1,v=1,t=d,f=24;AAAA\x1b\\");
    vt_core.feedSlice("\x1b_Ga=p,i=7,p=3,c=2,r=1\x1b\\");
    vt_core.feedSlice("\x1b_Gi=7,s=1,v=1,t=d,f=24;BBBB\x1b\\");
    vt_core.apply();

    try std.testing.expectEqual(@as(usize, 1), vt_core.kittyGraphicsImageCount());
    try std.testing.expectEqualStrings("BBBB", vt_core.kittyGraphicsImageAt(0).?.base64_payload);
    try std.testing.expectEqual(@as(usize, 0), vt_core.kittyGraphicsPlacementCount());
}

test "kitty graphics place stores metadata and replies by image id" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 16);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b_Gi=7,s=1,v=1,t=d,f=24;AAAA\x1b\\");
    vt_core.feedSlice("\x1b[2;3H");
    vt_core.feedSlice("\x1b_Ga=p,i=7,p=3,c=4,r=2\x1b\\");
    vt_core.apply();

    try std.testing.expectEqualStrings("\x1b_Gi=7;OK\x1b\\", vt_core.pendingOutput());
    try std.testing.expectEqual(@as(usize, 1), vt_core.kittyGraphicsPlacementCount());
    const placement = vt_core.kittyGraphicsPlacementAt(0).?;
    try std.testing.expectEqual(@as(u32, 7), placement.image_id);
    try std.testing.expectEqual(@as(u32, 3), placement.placement_id);
    try std.testing.expectEqual(@as(u16, 1), placement.row);
    try std.testing.expectEqual(@as(u16, 2), placement.col);
    try std.testing.expectEqual(@as(u32, 4), placement.columns);
    try std.testing.expectEqual(@as(u32, 2), placement.rows);
}

test "kitty graphics place missing image replies ENOENT" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 16);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b_Ga=p,i=404\x1b\\");
    vt_core.apply();

    try std.testing.expectEqualStrings("\x1b_Gi=404;ENOENT:image not found\x1b\\", vt_core.pendingOutput());
}

test "kitty graphics delete by image id removes image and placements" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 16);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b_Gi=7,s=1,v=1,t=d,f=24;AAAA\x1b\\");
    vt_core.feedSlice("\x1b_Ga=p,i=7,p=3\x1b\\");
    vt_core.feedSlice("\x1b_Ga=d,d=i,i=7\x1b\\");
    vt_core.apply();

    try std.testing.expectEqual(@as(usize, 0), vt_core.kittyGraphicsImageCount());
    try std.testing.expectEqual(@as(usize, 0), vt_core.kittyGraphicsPlacementCount());
}

test "kitty graphics image numbers allocate ids and place newest image" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 16);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b_GI=13,s=1,v=1,t=d,f=24;AAAA\x1b\\");
    vt_core.feedSlice("\x1b_GI=13,s=1,v=1,t=d,f=24;BBBB\x1b\\");
    vt_core.feedSlice("\x1b_Ga=p,I=13,p=2\x1b\\");
    vt_core.apply();

    try std.testing.expectEqual(@as(usize, 2), vt_core.kittyGraphicsImageCount());
    try std.testing.expectEqualStrings("\x1b_Gi=1,I=13;OK\x1b\\\x1b_Gi=2,I=13;OK\x1b\\\x1b_Gi=2;OK\x1b\\", vt_core.pendingOutput());
    try std.testing.expectEqual(@as(u32, 2), vt_core.kittyGraphicsPlacementAt(0).?.image_id);
}

test "kitty graphics deletion selectors remove matching placements" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 5, 16);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b_Gi=7,s=1,v=1,t=d,f=24;AAAA\x1b\\");
    vt_core.feedSlice("\x1b[2;3H\x1b_Ga=p,i=7,p=1,c=4,r=2,z=5\x1b\\");
    vt_core.feedSlice("\x1b[5;10H\x1b_Ga=p,i=7,p=2,c=1,r=1,z=2\x1b\\");
    vt_core.feedSlice("\x1b_Ga=d,d=p,x=4,y=2\x1b\\");
    vt_core.apply();

    try std.testing.expectEqual(@as(usize, 1), vt_core.kittyGraphicsPlacementCount());
    try std.testing.expectEqual(@as(u32, 2), vt_core.kittyGraphicsPlacementAt(0).?.placement_id);
}

test "kitty graphics animation frame upload stores frame metadata" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 16);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b_Gi=7,s=1,v=1,t=d,f=24;AAAA\x1b\\");
    vt_core.feedSlice("\x1b_Ga=f,i=7,p=3,s=1,v=1,t=d,f=24;CCCC\x1b\\");
    vt_core.apply();

    try std.testing.expectEqual(@as(usize, 1), vt_core.kittyGraphicsFrameCount());
    const frame = vt_core.kittyGraphicsFrameAt(0).?;
    try std.testing.expectEqual(@as(u32, 7), frame.image_id);
    try std.testing.expectEqual(@as(u32, 3), frame.frame_number);
    try std.testing.expectEqualStrings("CCCC", frame.base64_payload);
}

test "application cursor mode changes arrow key encoding" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 8);
    defer vt_core.deinit();

    try std.testing.expectEqualStrings("\x1b[A", vt_core.encodeKey(VtCore.key_up, VtCore.mod_none));
    vt_core.feedSlice("\x1b[?1h");
    vt_core.apply();
    try std.testing.expectEqualStrings("\x1bOA", vt_core.encodeKey(VtCore.key_up, VtCore.mod_none));
    try std.testing.expectEqualStrings("\x1b[1;5A", vt_core.encodeKey(VtCore.key_up, VtCore.mod_ctrl));
    vt_core.feedSlice("\x1b[?1l");
    vt_core.apply();
    try std.testing.expectEqualStrings("\x1b[A", vt_core.encodeKey(VtCore.key_up, VtCore.mod_none));
}

test "kitty keyboard set query push and pop flags" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 8);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b[=5u\x1b[?u");
    vt_core.apply();
    try std.testing.expectEqual(@as(u32, 5), vt_core.kittyKeyboardFlags());
    try std.testing.expectEqualStrings("\x1b[?5u", vt_core.pendingOutput());
    vt_core.clearPendingOutput();

    vt_core.feedSlice("\x1b[>1u\x1b[?u");
    vt_core.apply();
    try std.testing.expectEqual(@as(u32, 1), vt_core.kittyKeyboardFlags());
    try std.testing.expectEqualStrings("\x1b[?1u", vt_core.pendingOutput());
    vt_core.clearPendingOutput();

    vt_core.feedSlice("\x1b[<u\x1b[?u");
    vt_core.apply();
    try std.testing.expectEqual(@as(u32, 5), vt_core.kittyKeyboardFlags());
    try std.testing.expectEqualStrings("\x1b[?5u", vt_core.pendingOutput());
}

test "kitty keyboard flags stay separate across alternate screen" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 8);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b[=1u\x1b[?1049h\x1b[=8u");
    vt_core.apply();
    try std.testing.expect(vt_core.isAlternateScreen());
    try std.testing.expectEqual(@as(u32, 8), vt_core.kittyKeyboardFlags());
    vt_core.feedSlice("\x1b[?1049l");
    vt_core.apply();
    try std.testing.expectEqual(@as(u32, 1), vt_core.kittyKeyboardFlags());
}

test "kitty keyboard mode switches existing keys to CSI-u family" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 8);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b[=1u");
    vt_core.apply();
    try std.testing.expectEqualStrings("\x1b[27u", vt_core.encodeKey(VtCore.key_escape, VtCore.mod_none));
    try std.testing.expectEqualStrings("\x1b[127;5u", vt_core.encodeKey(VtCore.key_backspace, VtCore.mod_ctrl));
    try std.testing.expectEqualStrings("\x1b[1;5A", vt_core.encodeKey(VtCore.key_up, VtCore.mod_ctrl));
    try std.testing.expectEqualStrings("\x1b[15~", vt_core.encodeKey(VtCore.key_f5, VtCore.mod_none));
}

test "focus reports are gated by DECSET 1004" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 8);
    defer vt_core.deinit();

    try std.testing.expectEqualStrings("", vt_core.encodeFocusIn());
    try std.testing.expectEqualStrings("", vt_core.encodeFocusOut());
    vt_core.feedSlice("\x1b[?1004h");
    vt_core.apply();
    try std.testing.expectEqualStrings("\x1b[I", vt_core.encodeFocusIn());
    try std.testing.expectEqualStrings("\x1b[O", vt_core.encodeFocusOut());
    vt_core.feedSlice("\x1b[?1004l");
    vt_core.apply();
    try std.testing.expectEqualStrings("", vt_core.encodeFocusIn());
}

test "bracketed paste wrappers are gated by DECSET 2004" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 8);
    defer vt_core.deinit();

    try std.testing.expectEqualStrings("", vt_core.encodePasteStart());
    try std.testing.expectEqualStrings("", vt_core.encodePasteEnd());
    vt_core.feedSlice("\x1b[?2004h");
    vt_core.apply();
    try std.testing.expectEqualStrings("\x1b[200~", vt_core.encodePasteStart());
    try std.testing.expectEqualStrings("\x1b[201~", vt_core.encodePasteEnd());
    vt_core.feedSlice("\x1b[?2004l");
    vt_core.apply();
    try std.testing.expectEqualStrings("", vt_core.encodePasteStart());
}

test "report queries append pending host output" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 4, 8);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b[2;3H\x1b[5n\x1b[6n\x1b[c\x1b[>c");
    vt_core.apply();
    try std.testing.expectEqualStrings("\x1b[0n\x1b[2;3R\x1b[?62;22c\x1b[>1;10;0c", vt_core.pendingOutput());

    vt_core.clearPendingOutput();
    try std.testing.expectEqualStrings("", vt_core.pendingOutput());
}

test "DECXCPR appends DEC cursor position report" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 4, 8);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b[3;4H\x1b[?6n");
    vt_core.apply();
    try std.testing.expectEqualStrings("\x1b[?3;4R", vt_core.pendingOutput());
}

test "DEC mode queries append DECRPM replies" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 4, 8);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b[?1004h\x1b[?2004h\x1b[?1002h\x1b[?1006h\x1b[?1004$p\x1b[?2004$p\x1b[?1002$p\x1b[?1006$p\x1b[?25$p\x1b[?9999$p");
    vt_core.apply();
    try std.testing.expectEqualStrings("\x1b[?1004;1$y\x1b[?2004;1$y\x1b[?1002;1$y\x1b[?1006;1$y\x1b[?25;1$y\x1b[?9999;0$y", vt_core.pendingOutput());
}

test "XTSAVE and XTRESTORE restore supported DEC private modes" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 4, 8);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b[?1h\x1b[?7l\x1b[?25l\x1b[?1004h\x1b[?2004h");
    vt_core.feedSlice("\x1b[?1;7;25;1004;2004s");
    vt_core.feedSlice("\x1b[?1l\x1b[?7h\x1b[?25h\x1b[?1004l\x1b[?2004l");
    vt_core.feedSlice("\x1b[?1;7;25;1004;2004r");
    vt_core.feedSlice("\x1b[?1$p\x1b[?7$p\x1b[?25$p\x1b[?1004$p\x1b[?2004$p");
    vt_core.apply();

    try std.testing.expect(vt_core.application_cursor_keys);
    try std.testing.expect(!vt_core.renderView().screen.auto_wrap);
    try std.testing.expect(!vt_core.renderView().cursor_visible);
    try std.testing.expect(vt_core.focus_reporting);
    try std.testing.expect(vt_core.bracketed_paste);
    try std.testing.expectEqualStrings("\x1b[?1;1$y\x1b[?7;2$y\x1b[?25;2$y\x1b[?1004;1$y\x1b[?2004;1$y", vt_core.pendingOutput());
}

test "application keypad modes affect keypad encoding and DECRQM" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 4, 8);
    defer vt_core.deinit();

    try std.testing.expectEqualStrings("1", vt_core.encodeKey(VtCore.key_kp_1, VtCore.mod_none));
    try std.testing.expectEqualStrings("\r", vt_core.encodeKey(VtCore.key_kp_enter, VtCore.mod_none));

    vt_core.feedSlice("\x1b=\x1b[?66$p");
    vt_core.apply();
    try std.testing.expect(vt_core.isApplicationKeypad());
    try std.testing.expectEqualStrings("\x1b[?66;1$y", vt_core.pendingOutput());
    try std.testing.expectEqualStrings("\x1bOq", vt_core.encodeKey(VtCore.key_kp_1, VtCore.mod_none));
    try std.testing.expectEqualStrings("\x1bOM", vt_core.encodeKey(VtCore.key_kp_enter, VtCore.mod_none));

    vt_core.feedSlice("\x1b>");
    vt_core.apply();
    try std.testing.expect(!vt_core.isApplicationKeypad());
    try std.testing.expectEqualStrings("1", vt_core.encodeKey(VtCore.key_kp_1, VtCore.mod_none));
}

test "modifyOtherKeys set query disable and encoding" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 4, 8);
    defer vt_core.deinit();

    try std.testing.expectEqualStrings("a", vt_core.encodeKey('a', VtCore.mod_alt));
    vt_core.feedSlice("\x1b[>4;2m\x1b[?4m");
    vt_core.apply();
    try std.testing.expectEqual(@as(i8, 2), vt_core.modifyOtherKeys());
    try std.testing.expectEqualStrings("\x1b[>4;2m", vt_core.pendingOutput());
    try std.testing.expectEqualStrings("\x1b[27;3;97~", vt_core.encodeKey('a', VtCore.mod_alt));
    try std.testing.expectEqualStrings("a", vt_core.encodeKey('a', VtCore.mod_none));

    vt_core.feedSlice("\x1b[>4;3m");
    vt_core.apply();
    try std.testing.expectEqualStrings("\x1b[27;1;97~", vt_core.encodeKey('a', VtCore.mod_none));

    vt_core.feedSlice("\x1b[>4n");
    vt_core.apply();
    try std.testing.expectEqual(@as(i8, -1), vt_core.modifyOtherKeys());
}

test "VtCore exposes key and modifier constants" {
    _ = VtCore.mod_none;
    _ = VtCore.mod_shift;
    _ = VtCore.mod_alt;
    _ = VtCore.mod_ctrl;
    _ = VtCore.key_enter;
    _ = VtCore.key_tab;
    _ = VtCore.key_backspace;
    _ = VtCore.key_escape;
    _ = VtCore.key_up;
    _ = VtCore.key_down;
    _ = VtCore.key_left;
    _ = VtCore.key_right;
    _ = VtCore.key_kp_0;
    _ = VtCore.key_kp_enter;
}

test "kitty shell integration OSC 133 records latest mark" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 8);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b]133;C;cmdline=ls\x07\x1b]133;D;2\x07");
    vt_core.apply();

    const mark = vt_core.kittyShellMark();
    try std.testing.expectEqual(@as(u8, 'D'), mark.kind);
    try std.testing.expectEqual(@as(?i32, 2), mark.status);
    try std.testing.expectEqualStrings("2", mark.metadata);
}

test "kitty notification OSC 99 queues host-neutral request" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 8);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b]99;i=1:d=0;Hello\x1b\\\x1b]99;i=1:p=body;World\x1b\\");
    vt_core.apply();

    try std.testing.expectEqual(@as(usize, 2), vt_core.kittyNotificationCount());
    try std.testing.expectEqualStrings("i=1:d=0", vt_core.kittyNotificationAt(0).?.metadata);
    try std.testing.expectEqualStrings("Hello", vt_core.kittyNotificationAt(0).?.payload);
    try std.testing.expectEqualStrings("i=1:p=body", vt_core.kittyNotificationAt(1).?.metadata);
    try std.testing.expectEqualStrings("World", vt_core.kittyNotificationAt(1).?.payload);
}

test "kitty pointer shape OSC 22 maintains per-screen stack and replies to queries" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 8);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b]22;pointer\x1b\\\x1b]22;>wait,crosshair\x1b\\\x1b]22;?__current__,pointer,no-such\x1b\\");
    vt_core.apply();

    try std.testing.expectEqualStrings("crosshair", vt_core.kittyPointerShape());
    try std.testing.expectEqualStrings("\x1b]22;crosshair,1,0\x1b\\", vt_core.pendingOutput());

    vt_core.clearPendingOutput();
    vt_core.feedSlice("\x1b[?1049h\x1b]22;text\x1b\\\x1b[?1049l");
    vt_core.apply();
    try std.testing.expectEqualStrings("crosshair", vt_core.kittyPointerShape());
}

test "kitty color stack OSC 30001 and 30101 track depth" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 8);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b]30001\x1b\\\x1b]30001\x1b\\\x1b]30101\x1b\\");
    vt_core.apply();
    try std.testing.expectEqual(@as(u16, 1), vt_core.kittyColorStackDepth());
}

test "kitty OSC 21 sets queries and resets terminal colors" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 8);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b]21;foreground=#112233;background=rgb:44/55/66;cursor=\x1b\\");
    vt_core.feedSlice("\x1b]21;foreground=?;background=?;cursor=?;no_such=?\x1b\\");
    vt_core.apply();

    const colors = vt_core.terminalColorState();
    try std.testing.expectEqual(GridNs.Color{ .r = 0x11, .g = 0x22, .b = 0x33 }, colors.foreground);
    try std.testing.expectEqual(GridNs.Color{ .r = 0x44, .g = 0x55, .b = 0x66 }, colors.background);
    try std.testing.expectEqual(@as(?GridNs.Color, null), colors.cursor);
    try std.testing.expectEqualStrings("\x1b]21;foreground=rgb:11/22/33\x1b\\\x1b]21;background=rgb:44/55/66\x1b\\\x1b]21;cursor=\x1b\\\x1b]21;no_such=?\x1b\\", vt_core.pendingOutput());

    vt_core.feedSlice("\x1b]21;foreground;background\x1b\\");
    vt_core.apply();
    try std.testing.expectEqual(GridNs.default_fg, vt_core.terminalColorState().foreground);
    try std.testing.expectEqual(GridNs.default_bg, vt_core.terminalColorState().background);
}

test "xterm OSC colors set query and reset palette and dynamic colors" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 8);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b]4;1;#010203\x1b\\\x1b]10;#aabbcc\x1b\\\x1b]11;rgb:0d/0e/0f\x1b\\\x1b]12;red\x1b\\");
    vt_core.feedSlice("\x1b]4;1;?\x1b\\\x1b]10;?\x1b\\\x1b]11;?\x1b\\\x1b]12;?\x1b\\");
    vt_core.apply();

    try std.testing.expectEqual(GridNs.Color{ .r = 1, .g = 2, .b = 3 }, vt_core.terminalColorState().palette[1]);
    try std.testing.expectEqualStrings("\x1b]4;1;rgb:01/02/03\x1b\\\x1b]10;rgb:aa/bb/cc\x1b\\\x1b]11;rgb:0d/0e/0f\x1b\\\x1b]12;rgb:ff/00/00\x1b\\", vt_core.pendingOutput());

    vt_core.feedSlice("\x1b]104;1\x1b\\\x1b]110\x1b\\\x1b]111\x1b\\\x1b]112\x1b\\");
    vt_core.apply();
    try std.testing.expectEqual(ansi16Color(1), vt_core.terminalColorState().palette[1]);
    try std.testing.expectEqual(GridNs.default_fg, vt_core.terminalColorState().foreground);
    try std.testing.expectEqual(GridNs.default_bg, vt_core.terminalColorState().background);
    try std.testing.expectEqual(@as(?GridNs.Color, null), vt_core.terminalColorState().cursor);
}

test "kitty color stack restores terminal color snapshots" {
    const allocator = std.testing.allocator;
    var vt_core = try VtCore.initWithCells(allocator, 3, 8);
    defer vt_core.deinit();

    vt_core.feedSlice("\x1b]21;foreground=#010203;1=#040506\x1b\\\x1b]30001\x1b\\");
    vt_core.feedSlice("\x1b]21;foreground=#aabbcc;1=#ddeeff\x1b\\\x1b]30101\x1b\\");
    vt_core.apply();

    try std.testing.expectEqual(@as(u16, 0), vt_core.kittyColorStackDepth());
    try std.testing.expectEqual(GridNs.Color{ .r = 1, .g = 2, .b = 3 }, vt_core.terminalColorState().foreground);
    try std.testing.expectEqual(GridNs.Color{ .r = 4, .g = 5, .b = 6 }, vt_core.terminalColorState().palette[1]);
}

test {
    _ = @import("test/pipeline_regression.zig");
    _ = @import("test/screen_state_behavior.zig");
    _ = @import("test/semantic_mapping.zig");
    _ = @import("test/snapshot_regression.zig");
    _ = @import("test/system_flows.zig");
}
