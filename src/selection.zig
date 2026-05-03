//! Responsibility: export the selection domain owner surface.
//! Ownership: selection package boundary.
//! Reason: keep one canonical owner for selection state and data shapes.

const model = @import("selection/model.zig");

/// Canonical selection domain owner.
pub const Selection = struct {
    /// Selection position payload.
    pub const SelectionPos = model.SelectionPos;
    /// Read-only terminal selection payload.
    pub const TerminalSelection = model.TerminalSelection;
    /// Mutable selection state owner.
    pub const SelectionState = model.SelectionState;
};
