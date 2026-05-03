//! Responsibility: export the grid domain owner surface.
//! Ownership: grid package boundary.
//! Reason: keep one canonical owner for grid state and behavior.

const model = @import("grid/model.zig");

/// Canonical grid domain owner.
pub const Grid = struct {
    /// Main grid-state model.
    pub const GridModel = model.GridModel;
};
