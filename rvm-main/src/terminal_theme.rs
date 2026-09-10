// src/terminal_theme.rs — Terminal-native theme helpers for the Rust binary.
//
// Per spec requirement #13: "Default RVM theme: terminal"
//   RVM should use ANSI 16 colors, ANSI 256 colors, truecolor when supported.
//   Do NOT force Catppuccin / Dracula / Tokyo Night / Nord.
//
// The actual terminal theme is defined in `theme.rs` as the first entry
// (`rvm-terminal`), which uses `Color::Reset` for backgrounds/foregrounds
// so the terminal emulator's own colors remain visible.

use crate::theme::Theme;

/// Returns the terminal-native theme (the default per spec).
pub fn terminal_theme() -> Theme {
    Theme::default_theme()
}

/// Add the terminal theme to a list of themes if it's not already present.
pub fn ensure_terminal_theme_in(themes: &mut Vec<Theme>) {
    if !themes.iter().any(|t| t.id == "rvm-terminal") {
        themes.push(terminal_theme());
    }
}
