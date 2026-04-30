//! Responsibility: expose the vt-core package public surface.
//! Ownership: root API export boundary.
//! Reason: keep one primary host-facing object.

pub const VtCore = @import("vt_core.zig").VtCore;
