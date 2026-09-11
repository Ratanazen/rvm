// src/keymap.rs — Keymap dispatcher for the native Rust binary.
//
// Architecture (per spec requirement #2):
//   Input → Mode → Keymap → Command → Editor
//
// This module is the *Keymap* layer: it takes a key event and dispatches
// the appropriate editor command based on the current Vim mode.
//
// Editor state lives in `buffer.rs`. Mode enumeration lives in `vim.rs`.

use crossterm::event::{KeyCode, KeyEvent, KeyModifiers};

use crate::buffer::Buffer;
use crate::vim::{Count, PendingKey, VimMode};

/// Result of a keymap action.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum KeymapResult {
    /// Mode unchanged, no message.
    Stay,
    /// Switch to a new mode.
    SwitchMode(VimMode),
    /// Multi-key sequence pending (e.g. 'gg', 'dd').
    Pending(PendingKey),
    /// Editor state was mutated.
    Edited,
    /// Cursor moved.
    Moved,
    /// Scrolled.
    Scrolled,
    /// Search action.
    Searched,
    /// Yanked text.
    Yanked,
    /// Undo.
    Undo,
    /// Redo.
    Redo,
    /// Inserted text.
    Inserted,
    /// Deleted text.
    Deleted,
    /// A command string was entered (ex command).
    Command(String),
    /// A search query was entered.
    SearchQuery(String),
    /// Quit the editor.
    Quit,
    /// No action.
    Noop,
}

/// The keymap state.
#[derive(Debug, Clone)]
pub struct Keymap {
    pub mode: VimMode,
    pub pending: PendingKey,
    pub count: Count,
    /// Last search query (for `n` / `N`).
    pub last_search: Option<String>,
    /// Last search direction (forward=true).
    pub last_search_forward: bool,
    /// Visual selection anchor (row, col).
    pub visual_start: Option<(usize, usize)>,
    /// Command-line input accumulator.
    pub command_input: String,
    /// Search input accumulator.
    pub search_input: String,
}

impl Keymap {
    pub fn new() -> Self {
        Self {
            mode: VimMode::Normal,
            pending: PendingKey::None,
            count: Count::new(),
            last_search: None,
            last_search_forward: true,
            visual_start: None,
            command_input: String::new(),
            search_input: String::new(),
        }
    }

    /// Dispatch a key event.
    pub fn handle(&mut self, key: KeyEvent, buffer: &mut Buffer) -> KeymapResult {
        // Two-key pending state
        if self.pending != PendingKey::None {
            let result = self.handle_pending(key, buffer);
            if result != KeymapResult::Stay {
                self.pending = PendingKey::None;
                return result;
            }
            self.pending = PendingKey::None;
        }

        // Count digits
        if self.mode == VimMode::Normal {
            if let KeyCode::Char(c) = key.code {
                if c.is_ascii_digit() && !self.count.is_building() && c != '0' {
                    self.count.push_digit(c);
                    return KeymapResult::Stay;
                }
                if c.is_ascii_digit() && self.count.is_building() {
                    self.count.push_digit(c);
                    return KeymapResult::Stay;
                }
            }
        }

        // Dispatch by mode
        match self.mode {
            VimMode::Normal => self.handle_normal(key, buffer),
            VimMode::Insert => self.handle_insert(key, buffer),
            VimMode::Replace => self.handle_replace(key, buffer),
            VimMode::Visual | VimMode::VisualLine | VimMode::VisualBlock => {
                self.handle_visual(key, buffer)
            }
            VimMode::Command => self.handle_command(key),
            VimMode::Search => self.handle_search(key),
        }
    }

    fn line_len(&self, buffer: &Buffer) -> usize {
        buffer
            .lines
            .get(buffer.cursor_row)
            .map(|s| s.len())
            .unwrap_or(0)
    }

    fn handle_normal(&mut self, key: KeyEvent, buffer: &mut Buffer) -> KeymapResult {
        let count = self.count.value();
        self.count.reset();

        match key.code {
            // Mode transitions
            KeyCode::Esc => KeymapResult::Stay,
            KeyCode::Char('i') => KeymapResult::SwitchMode(VimMode::Insert),
            KeyCode::Char('I') => {
                // Move to first non-blank
                if let Some(line) = buffer.lines.get(buffer.cursor_row) {
                    let mut col = 0;
                    while col < line.len()
                        && line.as_bytes().get(col).copied().map_or(false, |b| b == b' ')
                    {
                        col += 1;
                    }
                    buffer.cursor_col = col;
                }
                KeymapResult::SwitchMode(VimMode::Insert)
            }
            KeyCode::Char('a') => {
                buffer.cursor_col += 1;
                buffer.clamp_cursor();
                KeymapResult::SwitchMode(VimMode::Insert)
            }
            KeyCode::Char('A') => {
                buffer.cursor_col = self.line_len(buffer) + 1;
                buffer.clamp_cursor();
                KeymapResult::SwitchMode(VimMode::Insert)
            }
            KeyCode::Char('o') => {
                buffer.insert_newline();
                KeymapResult::SwitchMode(VimMode::Insert)
            }
            KeyCode::Char('O') => {
                if buffer.lines.is_empty() {
                    buffer.lines.push(String::new());
                } else {
                    buffer.lines.insert(buffer.cursor_row, String::new());
                }
                buffer.cursor_col = 0;
                KeymapResult::SwitchMode(VimMode::Insert)
            }
            KeyCode::Char('R') => KeymapResult::SwitchMode(VimMode::Replace),
            // Ctrl-V (Visual Block) — MUST come before bare 'v' or the guard never matches
            KeyCode::Char('v') if key.modifiers.contains(KeyModifiers::CONTROL) => {
                self.visual_start = Some((buffer.cursor_row, buffer.cursor_col));
                KeymapResult::SwitchMode(VimMode::VisualBlock)
            }
            KeyCode::Char('v') => {
                self.visual_start = Some((buffer.cursor_row, buffer.cursor_col));
                KeymapResult::SwitchMode(VimMode::Visual)
            }
            KeyCode::Char('V') => {
                self.visual_start = Some((buffer.cursor_row, 1));
                KeymapResult::SwitchMode(VimMode::VisualLine)
            }
            KeyCode::Char(':') => {
                self.command_input.clear();
                KeymapResult::SwitchMode(VimMode::Command)
            }
            KeyCode::Char('/') => {
                self.search_input.clear();
                KeymapResult::SwitchMode(VimMode::Search)
            }
            KeyCode::Char('?') => {
                self.search_input.clear();
                self.last_search_forward = false;
                KeymapResult::SwitchMode(VimMode::Search)
            }

            // Motions
            KeyCode::Char('h') | KeyCode::Left => {
                buffer.cursor_col = buffer.cursor_col.saturating_sub(count);
                KeymapResult::Moved
            }
            KeyCode::Char('l') | KeyCode::Right => {
                buffer.cursor_col = buffer.cursor_col.saturating_add(count);
                buffer.clamp_cursor();
                KeymapResult::Moved
            }
            KeyCode::Char('j') | KeyCode::Down => {
                buffer.cursor_row = (buffer.cursor_row + count).min(buffer.lines.len().saturating_sub(1));
                buffer.clamp_cursor();
                KeymapResult::Moved
            }
            KeyCode::Char('k') | KeyCode::Up => {
                buffer.cursor_row = buffer.cursor_row.saturating_sub(count);
                buffer.clamp_cursor();
                KeymapResult::Moved
            }
            KeyCode::Char('w') => {
                for _ in 0..count {
                    self.next_word(buffer);
                }
                KeymapResult::Moved
            }
            KeyCode::Char('b') => {
                for _ in 0..count {
                    self.prev_word(buffer);
                }
                KeymapResult::Moved
            }
            KeyCode::Char('e') => {
                for _ in 0..count {
                    self.end_word(buffer);
                }
                KeymapResult::Moved
            }
            KeyCode::Char('0') | KeyCode::Home => {
                buffer.cursor_col = 0;
                KeymapResult::Moved
            }
            KeyCode::Char('$') | KeyCode::End => {
                buffer.cursor_col = self.line_len(buffer).max(1);
                KeymapResult::Moved
            }
            KeyCode::PageUp => {
                buffer.cursor_row = buffer.cursor_row.saturating_sub(15);
                buffer.clamp_cursor();
                KeymapResult::Scrolled
            }
            KeyCode::PageDown => {
                buffer.cursor_row = (buffer.cursor_row + 15).min(buffer.lines.len().saturating_sub(1));
                buffer.clamp_cursor();
                KeymapResult::Scrolled
            }
            KeyCode::Delete => {
                buffer.delete_char_forward();
                KeymapResult::Edited
            }
            KeyCode::Char('g') => {
                self.pending = PendingKey::G;
                KeymapResult::Pending(PendingKey::G)
            }
            KeyCode::Char('G') => {
                if count > 1 {
                    buffer.cursor_row = count.min(buffer.lines.len()).saturating_sub(1);
                } else {
                    buffer.cursor_row = buffer.lines.len().saturating_sub(1);
                }
                buffer.cursor_col = 0;
                buffer.clamp_cursor();
                KeymapResult::Moved
            }
            KeyCode::Char('u') if key.modifiers.contains(KeyModifiers::CONTROL) => {
                let new_row = buffer.cursor_row.saturating_sub(count * 10);
                buffer.cursor_row = new_row;
                buffer.clamp_cursor();
                KeymapResult::Scrolled
            }
            KeyCode::Char('d') if key.modifiers.contains(KeyModifiers::CONTROL) => {
                buffer.cursor_row = (buffer.cursor_row + count * 10).min(buffer.lines.len().saturating_sub(1));
                buffer.clamp_cursor();
                KeymapResult::Scrolled
            }
            KeyCode::Char('z') => {
                self.pending = PendingKey::Z;
                KeymapResult::Pending(PendingKey::Z)
            }

            // Editing
            KeyCode::Char('x') => {
                let line = buffer.lines.get_mut(buffer.cursor_row);
                if let Some(line) = line {
                    if buffer.cursor_col < line.len() {
                        let byte_idx = line.char_indices().nth(buffer.cursor_col).map(|(i, _)| i);
                        if let Some(idx) = byte_idx {
                            line.remove(idx);
                        }
                        buffer.is_dirty = true;
                    }
                }
                KeymapResult::Edited
            }
            KeyCode::Char('d') => {
                self.pending = PendingKey::D;
                KeymapResult::Pending(PendingKey::D)
            }
            KeyCode::Char('D') => {
                if let Some(line) = buffer.lines.get_mut(buffer.cursor_row) {
                    line.truncate(buffer.cursor_col);
                    buffer.is_dirty = true;
                }
                KeymapResult::Edited
            }
            KeyCode::Char('c') => {
                self.pending = PendingKey::C;
                KeymapResult::Pending(PendingKey::C)
            }
            KeyCode::Char('C') => {
                if let Some(line) = buffer.lines.get_mut(buffer.cursor_row) {
                    line.truncate(buffer.cursor_col);
                    buffer.is_dirty = true;
                }
                KeymapResult::SwitchMode(VimMode::Insert)
            }
            KeyCode::Char('y') => {
                self.pending = PendingKey::Y;
                KeymapResult::Pending(PendingKey::Y)
            }
            KeyCode::Char('Y') => {
                if let Some(line) = buffer.lines.get(buffer.cursor_row) {
                    buffer.yank_clipboard = Some(line.clone());
                }
                KeymapResult::Yanked
            }
            KeyCode::Char('p') => {
                if let Some(text) = buffer.yank_clipboard.clone() {
                    buffer.lines.insert(buffer.cursor_row + 1, text);
                    buffer.cursor_row += 1;
                    buffer.cursor_col = 0;
                    buffer.is_dirty = true;
                }
                KeymapResult::Edited
            }
            KeyCode::Char('P') => {
                if let Some(text) = buffer.yank_clipboard.clone() {
                    buffer.lines.insert(buffer.cursor_row, text);
                    buffer.cursor_col = 0;
                    buffer.is_dirty = true;
                }
                KeymapResult::Edited
            }
            KeyCode::Char('u') => {
                buffer.undo();
                KeymapResult::Undo
            }
            KeyCode::Char('r') if key.modifiers.contains(KeyModifiers::CONTROL) => {
                buffer.redo();
                KeymapResult::Redo
            }
            KeyCode::Char('n') => {
                self.repeat_search(buffer, true);
                KeymapResult::Searched
            }
            KeyCode::Char('N') => {
                self.repeat_search(buffer, false);
                KeymapResult::Searched
            }
            _ => KeymapResult::Noop,
        }
    }

    fn handle_insert(&mut self, key: KeyEvent, buffer: &mut Buffer) -> KeymapResult {
        match key.code {
            KeyCode::Esc => {
                if buffer.cursor_col > 0 {
                    buffer.cursor_col -= 1;
                }
                KeymapResult::SwitchMode(VimMode::Normal)
            }
            KeyCode::Char(c) => {
                buffer.insert_char(c);
                KeymapResult::Inserted
            }
            KeyCode::Enter => {
                buffer.insert_newline();
                KeymapResult::Inserted
            }
            KeyCode::Backspace => {
                buffer.delete_char();
                KeymapResult::Deleted
            }
            KeyCode::Delete => {
                buffer.delete_char_forward();
                KeymapResult::Deleted
            }
            KeyCode::Home => {
                buffer.cursor_col = 0;
                KeymapResult::Moved
            }
            KeyCode::End => {
                buffer.cursor_col = self.line_len(buffer);
                KeymapResult::Moved
            }
            KeyCode::PageUp => {
                buffer.cursor_row = buffer.cursor_row.saturating_sub(15);
                buffer.clamp_cursor();
                KeymapResult::Moved
            }
            KeyCode::PageDown => {
                buffer.cursor_row = (buffer.cursor_row + 15).min(buffer.lines.len().saturating_sub(1));
                buffer.clamp_cursor();
                KeymapResult::Moved
            }
            KeyCode::Tab => {
                for _ in 0..4 {
                    buffer.insert_char(' ');
                }
                KeymapResult::Inserted
            }
            KeyCode::Up => {
                buffer.cursor_row = buffer.cursor_row.saturating_sub(1);
                buffer.clamp_cursor();
                KeymapResult::Moved
            }
            KeyCode::Down => {
                buffer.cursor_row = (buffer.cursor_row + 1).min(buffer.lines.len().saturating_sub(1));
                buffer.clamp_cursor();
                KeymapResult::Moved
            }
            KeyCode::Left => {
                buffer.cursor_col = buffer.cursor_col.saturating_sub(1);
                KeymapResult::Moved
            }
            KeyCode::Right => {
                buffer.cursor_col += 1;
                buffer.clamp_cursor();
                KeymapResult::Moved
            }
            _ => KeymapResult::Noop,
        }
    }

    fn handle_replace(&mut self, key: KeyEvent, buffer: &mut Buffer) -> KeymapResult {
        match key.code {
            KeyCode::Esc => KeymapResult::SwitchMode(VimMode::Normal),
            KeyCode::Char(c) => {
                let line = buffer.lines.get_mut(buffer.cursor_row);
                if let Some(line) = line {
                    let mut chars: Vec<char> = line.chars().collect();
                    if buffer.cursor_col < chars.len() {
                        chars[buffer.cursor_col] = c;
                    } else {
                        chars.push(c);
                    }
                    *line = chars.into_iter().collect();
                    buffer.cursor_col += 1;
                    buffer.is_dirty = true;
                }
                KeymapResult::Edited
            }
            _ => KeymapResult::Noop,
        }
    }

    fn handle_visual(&mut self, key: KeyEvent, buffer: &mut Buffer) -> KeymapResult {
        match key.code {
            KeyCode::Esc => KeymapResult::SwitchMode(VimMode::Normal),
            KeyCode::Char('h') | KeyCode::Left => {
                buffer.cursor_col = buffer.cursor_col.saturating_sub(1);
                KeymapResult::Moved
            }
            KeyCode::Char('l') | KeyCode::Right => {
                buffer.cursor_col += 1;
                buffer.clamp_cursor();
                KeymapResult::Moved
            }
            KeyCode::Char('j') | KeyCode::Down => {
                buffer.cursor_row = (buffer.cursor_row + 1).min(buffer.lines.len().saturating_sub(1));
                buffer.clamp_cursor();
                KeymapResult::Moved
            }
            KeyCode::Char('k') | KeyCode::Up => {
                buffer.cursor_row = buffer.cursor_row.saturating_sub(1);
                buffer.clamp_cursor();
                KeymapResult::Moved
            }
            KeyCode::Home => {
                buffer.cursor_col = 0;
                KeymapResult::Moved
            }
            KeyCode::End => {
                buffer.cursor_col = self.line_len(buffer).max(1);
                KeymapResult::Moved
            }
            KeyCode::PageUp => {
                buffer.cursor_row = buffer.cursor_row.saturating_sub(15);
                buffer.clamp_cursor();
                KeymapResult::Moved
            }
            KeyCode::PageDown => {
                buffer.cursor_row = (buffer.cursor_row + 15).min(buffer.lines.len().saturating_sub(1));
                buffer.clamp_cursor();
                KeymapResult::Moved
            }
            KeyCode::Char('x') | KeyCode::Char('d') => {
                // Delete selection (simplified: delete current line for V-LINE, char for VISUAL)
                match self.mode {
                    VimMode::VisualLine => {
                        if buffer.cursor_row < buffer.lines.len() {
                            buffer.lines.remove(buffer.cursor_row);
                            if buffer.lines.is_empty() {
                                buffer.lines.push(String::new());
                            }
                            buffer.cursor_row = buffer.cursor_row.min(buffer.lines.len() - 1);
                            buffer.cursor_col = 0;
                            buffer.is_dirty = true;
                        }
                    }
                    _ => {
                        // Char-based: delete from visual_start to cursor (simplified)
                        let line = buffer.lines.get_mut(buffer.cursor_row);
                        if let Some(line) = line {
                            let mut chars: Vec<char> = line.chars().collect();
                            let start = self.visual_start.unwrap_or((buffer.cursor_row, 0)).1;
                            let end = buffer.cursor_col + 1;
                            let lo = start.min(end);
                            let hi = start.max(end);
                            let removed: String = chars.drain(lo..hi.min(chars.len())).collect();
                            buffer.yank_clipboard = Some(removed);
                            *line = chars.into_iter().collect();
                            buffer.cursor_col = lo;
                            buffer.is_dirty = true;
                        }
                    }
                }
                KeymapResult::SwitchMode(VimMode::Normal)
            }
            KeyCode::Char('y') => {
                if let Some(line) = buffer.lines.get(buffer.cursor_row) {
                    let start = self.visual_start.unwrap_or((buffer.cursor_row, 0)).1;
                    let end = buffer.cursor_col + 1;
                    let lo = start.min(end);
                    let hi = start.max(end);
                    let chars: Vec<char> = line.chars().collect();
                    let yanked: String = chars[lo..hi.min(chars.len())].iter().collect();
                    buffer.yank_clipboard = Some(yanked);
                }
                KeymapResult::SwitchMode(VimMode::Normal)
            }
            _ => KeymapResult::Noop,
        }
    }

    fn handle_command(&mut self, key: KeyEvent) -> KeymapResult {
        match key.code {
            KeyCode::Esc => {
                self.command_input.clear();
                KeymapResult::SwitchMode(VimMode::Normal)
            }
            KeyCode::Enter => {
                let cmd = self.command_input.clone();
                self.command_input.clear();
                KeymapResult::Command(cmd)
            }
            KeyCode::Backspace => {
                self.command_input.pop();
                KeymapResult::Stay
            }
            KeyCode::Char(c) => {
                self.command_input.push(c);
                KeymapResult::Stay
            }
            _ => KeymapResult::Noop,
        }
    }

    fn handle_search(&mut self, key: KeyEvent) -> KeymapResult {
        match key.code {
            KeyCode::Esc => {
                self.search_input.clear();
                KeymapResult::SwitchMode(VimMode::Normal)
            }
            KeyCode::Enter => {
                let q = self.search_input.clone();
                self.search_input.clear();
                self.last_search = Some(q.clone());
                KeymapResult::SearchQuery(q)
            }
            KeyCode::Backspace => {
                self.search_input.pop();
                KeymapResult::Stay
            }
            KeyCode::Char(c) => {
                self.search_input.push(c);
                KeymapResult::Stay
            }
            _ => KeymapResult::Noop,
        }
    }

    fn handle_pending(&mut self, key: KeyEvent, buffer: &mut Buffer) -> KeymapResult {
        let count = self.count.value();
        self.count.reset();
        match self.pending {
            PendingKey::G => {
                if let KeyCode::Char('g') = key.code {
                    if count > 1 {
                        buffer.cursor_row = count.min(buffer.lines.len()) - 1;
                    } else {
                        buffer.cursor_row = 0;
                    }
                    buffer.cursor_col = 0;
                    buffer.clamp_cursor();
                    KeymapResult::Moved
                } else {
                    KeymapResult::Noop
                }
            }
            PendingKey::D => {
                if let KeyCode::Char('d') = key.code {
                    let to_delete = count.min(buffer.lines.len() - buffer.cursor_row);
                    for _ in 0..to_delete {
                        if buffer.cursor_row < buffer.lines.len() {
                            let removed = buffer.lines.remove(buffer.cursor_row);
                            buffer.yank_clipboard = Some(removed);
                        }
                    }
                    if buffer.lines.is_empty() {
                        buffer.lines.push(String::new());
                    }
                    buffer.cursor_row = buffer.cursor_row.min(buffer.lines.len() - 1);
                    buffer.cursor_col = 0;
                    buffer.is_dirty = true;
                    KeymapResult::Edited
                } else {
                    KeymapResult::Noop
                }
            }
            PendingKey::C => {
                if let KeyCode::Char('c') = key.code {
                    if let Some(line) = buffer.lines.get_mut(buffer.cursor_row) {
                        line.clear();
                        buffer.cursor_col = 0;
                        buffer.is_dirty = true;
                    }
                    KeymapResult::SwitchMode(VimMode::Insert)
                } else {
                    KeymapResult::Noop
                }
            }
            PendingKey::Y => {
                if let KeyCode::Char('y') = key.code {
                    if let Some(line) = buffer.lines.get(buffer.cursor_row) {
                        buffer.yank_clipboard = Some(line.clone());
                    }
                    KeymapResult::Yanked
                } else {
                    KeymapResult::Noop
                }
            }
            PendingKey::Z => {
                // zz / zt / zb scroll actions; UI layer interprets
                match key.code {
                    KeyCode::Char('z') | KeyCode::Char('t') | KeyCode::Char('b') => KeymapResult::Scrolled,
                    _ => KeymapResult::Noop,
                }
            }
            _ => KeymapResult::Noop,
        }
    }

    // Word motion helpers
    fn next_word(&self, buffer: &mut Buffer) {
        let line = buffer.lines.get(buffer.cursor_row).cloned().unwrap_or_default();
        let mut col = buffer.cursor_col;
        let bytes = line.as_bytes();
        // skip current word
        while col < bytes.len() && (bytes[col] as char).is_alphanumeric() {
            col += 1;
        }
        while col < bytes.len() && (bytes[col] as char).is_whitespace() {
            col += 1;
        }
        if col >= bytes.len() && buffer.cursor_row + 1 < buffer.lines.len() {
            buffer.cursor_row += 1;
            buffer.cursor_col = 0;
        } else {
            buffer.cursor_col = col;
        }
    }

    fn prev_word(&self, buffer: &mut Buffer) {
        let line = buffer.lines.get(buffer.cursor_row).cloned().unwrap_or_default();
        let mut col = buffer.cursor_col.saturating_sub(1);
        let bytes = line.as_bytes();
        while col > 0 && (bytes[col] as char).is_whitespace() {
            col -= 1;
        }
        while col > 0 && (bytes[col - 1] as char).is_alphanumeric() {
            col -= 1;
        }
        buffer.cursor_col = col;
    }

    fn end_word(&self, buffer: &mut Buffer) {
        let line = buffer.lines.get(buffer.cursor_row).cloned().unwrap_or_default();
        let mut col = (buffer.cursor_col + 1).min(line.len());
        let bytes = line.as_bytes();
        while col < bytes.len() && (bytes[col] as char).is_whitespace() {
            col += 1;
        }
        while col + 1 < bytes.len() && (bytes[col + 1] as char).is_alphanumeric() {
            col += 1;
        }
        buffer.cursor_col = col;
    }

    fn repeat_search(&mut self, buffer: &mut Buffer, forward: bool) {
        if let Some(query) = self.last_search.clone() {
            let direction = if forward == self.last_search_forward {
                true
            } else {
                false
            };
            buffer.search(&query);
            // Move to next match
            let target_row = buffer.cursor_row;
            let target_col = buffer.cursor_col + 1;
            let mut found = None;
            for &(r, c) in &buffer.search_matches {
                if direction {
                    if r > target_row || (r == target_row && c >= target_col) {
                        found = Some((r, c));
                        break;
                    }
                } else {
                    if r < target_row || (r == target_row && c < target_col) {
                        found = Some((r, c));
                    }
                }
            }
            if let Some((r, c)) = found {
                buffer.cursor_row = r;
                buffer.cursor_col = c;
            }
        }
    }
}
