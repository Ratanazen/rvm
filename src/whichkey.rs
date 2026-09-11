// src/whichkey.rs — LazyVim-style Which-Key popup for the Rust binary.
//
// Per spec requirement #16: When pressing Space, show:
//   f  Find
//   g  Git
//   b  Buffers
//   p  Projects
//   l  LSP
//   x  Diagnostics
//   t  Terminal
//   e  Explorer
//
// This module is the *registry* + *state machine*; rendering lives in `ui.rs`.

#[derive(Debug, Clone)]
pub struct WhichKeyEntry {
    pub key: char,
    pub label: String,
    pub icon: String,
    pub desc: String,
}

#[derive(Debug, Clone, Default)]
pub struct WhichKey {
    pub visible: bool,
    pub prefix: String,
    pub last_action: Option<String>,
}

impl WhichKey {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn open(&mut self) {
        self.visible = true;
        self.prefix.clear();
    }

    pub fn close(&mut self) {
        self.visible = false;
        self.prefix.clear();
        self.last_action = None;
    }

    pub fn is_open(&self) -> bool {
        self.visible
    }

    /// Feed a key. Returns: ("chord", action) | ("prefix", prefix) | ("cancel", nil) | ("noop", nil)
    pub fn feed(&mut self, key: char) -> (&'static str, Option<String>) {
        if !self.visible {
            return ("noop", None);
        }
        if key == '\x1b' || key == ' ' {
            self.close();
            return ("cancel", None);
        }

        // Single-key shortcuts
        let single_action = match key {
            'e' => Some("explorer_toggle"),
            'w' => Some("file_save"),
            'q' => Some("app_quit"),
            'n' => Some("buffer_new"),
            't' => Some("theme_cycle"),
            's' => Some("style_cycle"),
            'u' => Some("edit_undo"),
            'r' => Some("edit_redo"),
            _ => None,
        };
        if self.prefix.is_empty() && single_action.is_some() {
            let action = single_action.unwrap().to_string();
            self.close();
            return ("chord", Some(action));
        }

        let new_prefix = format!("{}{}", self.prefix, key);

        // Check for two-key chord
        if new_prefix.len() == 2 {
            let action = Self::chord_action(&new_prefix);
            self.close();
            return if let Some(a) = action {
                ("chord", Some(a.to_string()))
            } else {
                ("cancel", None)
            };
        }

        // One-key prefix
        if new_prefix.len() == 1 {
            if Self::is_group_prefix(&new_prefix) {
                self.prefix = new_prefix;
                return ("prefix", Some(self.prefix.clone()));
            }
            self.close();
            return ("cancel", None);
        }

        self.close();
        ("cancel", None)
    }

    /// Get the hint rows for rendering.
    pub fn hint_rows(&self) -> Vec<WhichKeyEntry> {
        let mut rows = Vec::new();

        if self.prefix.is_empty() {
            // Top-level groups
            let groups = [
                ('f', "Find",       "󰍉", "Telescope-like finders"),
                ('g', "Git",         "󰊢", "Git workflow"),
                ('b', "Buffers",     "󰓩", "Buffer operations"),
                ('p', "Projects",    "󰉋", "Project management"),
                ('l', "LSP",         "󰌵", "Language server"),
                ('x', "Diagnostics", "󰅙", "Diagnostics panel"),
                ('t', "Terminal",    "󰆍", "Terminal panel"),
                ('e', "Explorer",    "󰉋", "Toggle file explorer"),
                ('w', "Window",      "󰖲", "Window management"),
                ('s', "Search",      "󰍉", "Buffer search"),
            ];
            for (k, label, icon, desc) in groups {
                rows.push(WhichKeyEntry {
                    key: k,
                    label: label.to_string(),
                    icon: icon.to_string(),
                    desc: desc.to_string(),
                });
            }
        } else {
            // Show entries in current group prefix
            let chords = Self::chords_for_prefix(&self.prefix);
            for (k, label) in chords {
                rows.push(WhichKeyEntry {
                    key: k,
                    label: label.to_string(),
                    icon: "›".to_string(),
                    desc: String::new(),
                });
            }
        }
        rows
    }

    fn is_group_prefix(p: &str) -> bool {
        matches!(p, "f" | "g" | "b" | "p" | "l" | "x" | "t" | "w" | "s")
    }

    fn chord_action(chord: &str) -> Option<&'static str> {
        match chord {
            // File finders
            "ff" => Some("finder_files"),
            "fg" => Some("finder_grep"),
            "fb" => Some("finder_buffers"),
            "fr" => Some("finder_recent"),
            "fc" => Some("finder_commands"),
            // Git
            "gg" => Some("git_status"),
            "gd" => Some("git_diff"),
            "gc" => Some("git_commit"),
            "gp" => Some("git_push"),
            "gl" => Some("git_log"),
            // Buffers
            "bd" => Some("buffer_delete"),
            "bo" => Some("buffer_close_others"),
            "bn" => Some("buffer_next"),
            "bp" => Some("buffer_prev"),
            // Projects
            "pp" => Some("project_switch"),
            "pf" => Some("project_files"),
            "pg" => Some("project_grep"),
            "pd" => Some("project_dashboard"),
            // LSP
            "la" => Some("lsp_code_action"),
            "lr" => Some("lsp_rename"),
            "lf" => Some("lsp_format"),
            "lh" => Some("lsp_hover"),
            "ld" => Some("lsp_definition"),
            "ll" => Some("lsp_references"),
            // Diagnostics
            "xx" => Some("diagnostics_panel"),
            "xn" => Some("diagnostics_next"),
            "xp" => Some("diagnostics_prev"),
            // Terminal
            "tt" => Some("terminal_toggle"),
            // Window
            "ws" => Some("window_split"),
            "wv" => Some("window_vsplit"),
            "wc" => Some("window_close"),
            "wh" => Some("window_focus_left"),
            "wj" => Some("window_focus_down"),
            "wk" => Some("window_focus_up"),
            "wl" => Some("window_focus_right"),
            _ => None,
        }
    }

    fn chords_for_prefix(prefix: &str) -> Vec<(char, &'static str)> {
        match prefix {
            "f" => vec![
                ('f', "Find Files"),
                ('g', "Live Grep"),
                ('b', "Buffers"),
                ('r', "Recent Files"),
                ('c', "Commands"),
            ],
            "g" => vec![
                ('g', "Git Status"),
                ('d', "Git Diff"),
                ('c', "Git Commit"),
                ('p', "Git Push"),
                ('l', "Git Log"),
            ],
            "b" => vec![
                ('d', "Delete Buffer"),
                ('o', "Close Other Buffers"),
                ('n', "Next Buffer"),
                ('p', "Previous Buffer"),
            ],
            "p" => vec![
                ('p', "Project Switcher"),
                ('f', "Project Files"),
                ('g', "Project Grep"),
                ('d', "Project Dashboard"),
            ],
            "l" => vec![
                ('a', "Code Actions"),
                ('r', "Rename Symbol"),
                ('f', "Format Buffer"),
                ('h', "Hover"),
                ('d', "Definition"),
                ('l', "References"),
            ],
            "x" => vec![
                ('x', "Diagnostics Panel"),
                ('n', "Next Diagnostic"),
                ('p', "Prev Diagnostic"),
            ],
            "t" => vec![
                ('t', "Toggle Terminal"),
                ('f', "Terminal Float"),
                ('o', "Open New Terminal"),
            ],
            "w" => vec![
                ('s', "Split Horizontal"),
                ('v', "Split Vertical"),
                ('c', "Close Window"),
                ('h', "Focus Left"),
                ('j', "Focus Down"),
                ('k', "Focus Up"),
                ('l', "Focus Right"),
            ],
            _ => vec![],
        }
    }
}
