//! Environment switches read on both sides. Each has its `WSL_FIDO_BRIDGE_*` name and the
//! `WINDOWS_FIDO_BRIDGE_*` name used before the rename (and by upstream), which still works.

/// Debug logging on both sides.
pub const DEBUG: [&str; 2] = ["WSL_FIDO_BRIDGE_DEBUG", "WINDOWS_FIDO_BRIDGE_DEBUG"];

/// Always require user verification (PIN or biometrics).
pub const FORCE_USER_VERIFICATION: [&str; 2] = [
    "WSL_FIDO_BRIDGE_FORCE_USER_VERIFICATION",
    "WINDOWS_FIDO_BRIDGE_FORCE_USER_VERIFICATION",
];

/// Every switch, in the order the WSL library forwards them to Windows through `WSLENV`.
pub const ALL: [&str; 4] = [
    DEBUG[0],
    DEBUG[1],
    FORCE_USER_VERIFICATION[0],
    FORCE_USER_VERIFICATION[1],
];

/// Whether the switch is set (to any value) under either of its names.
pub fn is_set(names: [&str; 2]) -> bool {
    names.iter().any(|name| std::env::var_os(name).is_some())
}
