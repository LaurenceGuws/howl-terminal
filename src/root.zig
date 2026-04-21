//! Howl Terminal: parser primitives and data model.
//! Exports core components: CSI/UTF8 parsing, stream tokenization, terminal state types.
//! Supports ANSI/DEC escape sequences with private mode handling.

pub const parser = @import("terminal/parser.zig");
pub const model = @import("terminal/model.zig");
