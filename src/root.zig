//! Howl Terminal: standalone VT100-compatible terminal engine.
//! Root exports for parser and model primitives.

pub const parser = @import("terminal/parser.zig");
pub const model = @import("terminal/model.zig");
