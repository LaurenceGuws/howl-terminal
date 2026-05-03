//! Responsibility: export the interpret domain owner surface.
//! Ownership: interpret package boundary.
//! Reason: keep one canonical owner for parser-to-grid translation flow.

const bridge = @import("interpret/bridge.zig");
const semantic = @import("interpret/semantic.zig");
const pipeline = @import("interpret/pipeline.zig");

/// Canonical interpret domain owner.
pub const Interpret = struct {
    /// Parser-bridge event payload.
    pub const Event = bridge.Event;
    /// Parser-to-grid bridge owner.
    pub const Bridge = bridge.Bridge;
    /// Semantic event payload.
    pub const SemanticEvent = semantic.SemanticEvent;
    /// End-to-end interpretation pipeline owner.
    pub const Pipeline = pipeline.Pipeline;

    /// One-shot semantic processing function.
    pub const process = semantic.process;
};
