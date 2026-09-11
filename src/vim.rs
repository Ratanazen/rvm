// src/vim.rs — Full Vim mode enumeration for the native Rust binary.
// Implements all modes per spec requirement #2:
//   NORMAL, INSERT, VISUAL, V-LINE, V-BLOCK, COMMAND, SEARCH, REPLACE
//
// This module is the *Mode* layer. Input handling lives in `keymap.rs`,
// editor state lives in `buffer.rs`, rendering lives in `ui.rs`.

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum VimMode {
    Normal,
    Insert,
    Visual,
    VisualLine,
    VisualBlock,
    Command,
    Search,
    Replace,
}

impl VimMode {
    pub fn label(&self) -> &'static str {
        match self {
            VimMode::Normal => "NORMAL",
            VimMode::Insert => "INSERT",
            VimMode::Visual => "VISUAL",
            VimMode::VisualLine => "V-LINE",
            VimMode::VisualBlock => "V-BLOCK",
            VimMode::Command => "COMMAND",
            VimMode::Search => "SEARCH",
            VimMode::Replace => "REPLACE",
        }
    }

    /// True if this mode is part of the "insert family" (typing at cursor).
    pub fn is_insert_family(&self) -> bool {
        matches!(self, VimMode::Insert | VimMode::Replace)
    }

    /// True if this mode is part of the "visual family" (selection-based).
    pub fn is_visual_family(&self) -> bool {
        matches!(
            self,
            VimMode::Visual | VimMode::VisualLine | VimMode::VisualBlock
        )
    }

    /// True if this mode should display a cursor at the caret position.
    pub fn shows_caret(&self) -> bool {
        matches!(
            self,
            VimMode::Normal
                | VimMode::Insert
                | VimMode::Visual
                | VimMode::VisualLine
                | VimMode::VisualBlock
                | VimMode::Replace
        )
    }
}

/// Two-key sequence pending state (e.g. `gg`, `dd`, `yy`, `cc`, `zz`/`zt`/`zb`).
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PendingKey {
    None,
    G,
    D,
    Y,
    C,
    Z,
    R,
    /// For visual-mode replace pending (`r` then char)
    RVisual,
}

/// Vim register / count prefix accumulator.
#[derive(Debug, Clone, Default)]
pub struct Count {
    pub digits: String,
}

impl Count {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn value(&self) -> usize {
        self.digits.parse::<usize>().unwrap_or(1)
    }

    pub fn push_digit(&mut self, c: char) {
        if self.digits.is_empty() && c == '0' {
            // '0' alone is a motion (start of line), not a count
            return;
        }
        self.digits.push(c);
    }

    pub fn is_building(&self) -> bool {
        !self.digits.is_empty()
    }

    pub fn reset(&mut self) {
        self.digits.clear();
    }
}
