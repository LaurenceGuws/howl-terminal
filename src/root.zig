//! Responsibility: expose the public Howl Terminal module surface.
//! Ownership: package root API boundary.
//! Reason: provide stable imports for parser and model primitives.

pub const parser = @import("terminal/parser.zig");
pub const model = @import("terminal/model.zig");
pub const pipeline = @import("terminal/parser_core_event_pipeline.zig");
