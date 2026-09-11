use crossterm::{
    event::{
        self, DisableMouseCapture, EnableMouseCapture, Event, KeyCode, KeyEvent, KeyModifiers,
        MouseButton, MouseEvent, MouseEventKind,
    },
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
    ExecutableCommand,
};
use ratatui::backend::CrosstermBackend;
use ratatui::Terminal;
use std::io::{stdout, Result};
use std::path::{Path, PathBuf};

use crate::buffer::Buffer;
use crate::explorer::FileExplorer;
use crate::keymap::{Keymap, KeymapResult};
use crate::style::Style;
use crate::theme::Theme;
use crate::ui::UI;
use crate::vim::VimMode;
use crate::whichkey::WhichKey;

pub struct App {
    pub buffers: Vec<Buffer>,
    pub buf_index: usize,
    pub explorer: FileExplorer,
    pub themes: Vec<Theme>,
    pub current_theme_index: usize,
    pub style: Style,
    pub keymap: Keymap,
    pub whichkey: WhichKey,
    pub command_input: String,
    pub search_input: String,
    pub status_msg: String,
    pub should_quit: bool,
    pub show_dashboard: bool,
}

impl App {
    pub fn new<P: AsRef<Path>>(target_path: Option<P>) -> Result<Self> {
        let mut explorer_root =
            std::env::current_dir().unwrap_or_else(|_| PathBuf::from("."));
        let mut initial_buffers: Vec<Buffer> = vec![Buffer::new_empty()];
        let mut show_dashboard = true;
        let mut initial_index = 0;

        if let Some(ref path) = target_path {
            let path_ref = path.as_ref();
            if path_ref.is_dir() {
                explorer_root = path_ref.to_path_buf();
                show_dashboard = true;
            } else {
                let buf = Buffer::open_or_create(path_ref);
                initial_buffers = vec![buf];
                initial_index = 0;
                show_dashboard = false;
                if let Some(parent) = path_ref.parent() {
                    if parent.exists() {
                        explorer_root = parent.to_path_buf();
                    }
                }
            }
        }

        let explorer = FileExplorer::new(explorer_root);
        let themes = Theme::all();
        let current_theme_index = 0;
        let style = Style::default_style();

        Ok(Self {
            buffers: initial_buffers,
            buf_index: initial_index,
            explorer,
            themes,
            current_theme_index,
            style,
            keymap: Keymap::new(),
            whichkey: WhichKey::new(),
            command_input: String::new(),
            search_input: String::new(),
            status_msg: String::new(),
            should_quit: false,
            show_dashboard,
        })
    }

    pub fn run(&mut self) -> Result<()> {
        enable_raw_mode()?;
        stdout().execute(EnterAlternateScreen)?;
        stdout().execute(EnableMouseCapture)?;

        let backend = CrosstermBackend::new(stdout());
        let mut terminal = Terminal::new(backend)?;

        while !self.should_quit {
            let current_theme = &self.themes[self.current_theme_index].clone();
            let style = self.style.clone();
            let active_buffer = &self.buffers[self.buf_index];

            let ui = UI {
                theme: current_theme.clone(),
                style,
                vim_mode: self.keymap.mode,
                command_input: &self.command_input,
                search_input: &self.search_input,
                status_msg: &self.status_msg,
                show_dashboard: self.show_dashboard,
                whichkey: &self.whichkey,
            };

            terminal.draw(|f| {
                ui.render(f, active_buffer, &self.explorer);
                crate::bufferline::render_bufferline(
                    f,
                    ratatui::layout::Rect::new(0, 0, f.area().width, 1),
                    &self.buffers,
                    self.buf_index,
                    &current_theme.colors,
                );
            })?;

            match event::read()? {
                Event::Key(key) => self.handle_key_event(key),
                Event::Mouse(mouse) => self.handle_mouse_event(mouse),
                _ => {}
            }
        }

        stdout().execute(DisableMouseCapture)?;
        disable_raw_mode()?;
        stdout().execute(LeaveAlternateScreen)?;
        Ok(())
    }

    fn handle_key_event(&mut self, key: KeyEvent) {
        // Leader key (Space) opens which-key popup (per spec requirement #16)
        if let KeyCode::Char(' ') = key.code {
            if !self.keymap.mode.is_insert_family() && !self.whichkey.is_open() {
                self.whichkey.open();
                self.status_msg = "Leader (Space) — press a key...".to_string();
                return;
            }
        }

        // Which-key popup takes precedence
        if self.whichkey.is_open() {
            if let KeyCode::Char(c) = key.code {
                let (kind, payload) = self.whichkey.feed(c);
                match kind {
                    "chord" => {
                        if let Some(action) = payload {
                            self.dispatch_action(&action);
                        }
                    }
                    "prefix" => {
                        if let Some(p) = payload {
                            self.status_msg = format!("Which-key: {}", p);
                        }
                    }
                    "cancel" => {
                        self.status_msg = "Leader cancelled".to_string();
                    }
                    _ => {}
                }
                return;
            }
            // ESC inside which-key
            if let KeyCode::Esc = key.code {
                self.whichkey.close();
                return;
            }
            return;
        }

        // Universal Ctrl-* & VS Code shortcuts
        if key.modifiers.contains(KeyModifiers::CONTROL) {
            match key.code {
                KeyCode::Char('s') => {
                    self.dispatch_action("file_save");
                    return;
                }
                KeyCode::Char('q') => {
                    self.should_quit = true;
                    return;
                }
                KeyCode::Char('p') => {
                    self.dispatch_action("finder_files");
                    return;
                }
                KeyCode::Char('b') => {
                    self.dispatch_action("explorer_toggle");
                    return;
                }
                KeyCode::Char('z') => {
                    self.dispatch_action("edit_undo");
                    return;
                }
                KeyCode::Char('y') => {
                    self.dispatch_action("edit_redo");
                    return;
                }
                KeyCode::Char('f') => {
                    if key.modifiers.contains(KeyModifiers::SHIFT) {
                        self.dispatch_action("finder_files");
                    } else {
                        self.keymap.mode = VimMode::Search;
                        self.search_input.clear();
                    }
                    return;
                }
                KeyCode::Char('e') => {
                    self.explorer.toggle_visibility();
                    return;
                }
                KeyCode::Char('w') => {
                    self.dispatch_action("buffer_delete");
                    return;
                }
                KeyCode::Char('n') => {
                    self.dispatch_action("buffer_new");
                    return;
                }
                KeyCode::Char('t') => {
                    self.dispatch_action("terminal_toggle");
                    return;
                }
                KeyCode::Tab => {
                    if key.modifiers.contains(KeyModifiers::SHIFT) {
                        self.dispatch_action("buffer_prev");
                    } else {
                        self.dispatch_action("buffer_next");
                    }
                    return;
                }
                _ => {}
            }
        }

        // Dispatch through keymap
        let buf = &mut self.buffers[self.buf_index];
        let result = self.keymap.handle(key, buf);

        match result {
            KeymapResult::SwitchMode(new_mode) => {
                self.keymap.mode = new_mode;
            }
            KeymapResult::Command(cmd) => {
                self.execute_command(&cmd);
            }
            KeymapResult::SearchQuery(q) => {
                let buf = &mut self.buffers[self.buf_index];
                buf.search(&q);
            }
            KeymapResult::Quit => {
                self.should_quit = true;
            }
            _ => {}
        }

        // Sync command/search input for display
        self.command_input = self.keymap.command_input.clone();
        self.search_input = self.keymap.search_input.clone();
    }

    fn handle_mouse_event(&mut self, mouse: MouseEvent) {
        match mouse.kind {
            MouseEventKind::Down(MouseButton::Left) => {
                let col = mouse.column;
                let row = mouse.row;
                let explorer_width = self.style.explorer_width;

                if self.explorer.is_visible && col < explorer_width {
                    if row >= 1 {
                        let entry_idx = (row - 1) as usize;
                        if entry_idx < self.explorer.entries.len() {
                            self.explorer.selected_index = entry_idx;
                            let entry = self.explorer.entries[entry_idx].clone();
                            if entry.is_dir {
                                self.explorer.root_path = entry.path;
                                self.explorer.refresh();
                            } else {
                                let buf = Buffer::open_or_create(&entry.path);
                                self.buffers.push(buf);
                                self.buf_index = self.buffers.len() - 1;
                                self.show_dashboard = false;
                                self.status_msg = format!("Opened {}", entry.name);
                            }
                        }
                    }
                } else if row >= 1 {
                    let target_row = (row - 1) as usize;
                    let target_col = if self.explorer.is_visible {
                        col.saturating_sub(explorer_width) as usize
                    } else {
                        col as usize
                    };
                    let buf = &mut self.buffers[self.buf_index];
                    buf.cursor_row = target_row.min(buf.lines.len().saturating_sub(1));
                    buf.cursor_col = target_col;
                    buf.clamp_cursor();
                }
            }
            MouseEventKind::ScrollUp => {
                let buf = &mut self.buffers[self.buf_index];
                buf.cursor_row = buf.cursor_row.saturating_sub(3);
                buf.clamp_cursor();
            }
            MouseEventKind::ScrollDown => {
                let buf = &mut self.buffers[self.buf_index];
                buf.cursor_row = (buf.cursor_row + 3).min(buf.lines.len().saturating_sub(1));
                buf.clamp_cursor();
            }
            _ => {}
        }
    }

    fn dispatch_action(&mut self, action: &str) {
        match action {
            "file_save" => {
                let buf = &mut self.buffers[self.buf_index];
                if let Err(e) = buf.save() {
                    self.status_msg = format!("Save error: {}", e);
                } else {
                    self.status_msg = "Saved".to_string();
                }
            }
            "app_quit" => {
                let buf = &self.buffers[self.buf_index];
                if buf.is_dirty {
                    self.status_msg = "Unsaved changes (use 'q!' to force)".to_string();
                } else {
                    self.should_quit = true;
                }
            }
            "explorer_toggle" => {
                self.explorer.toggle_visibility();
                self.status_msg = "Explorer toggled".to_string();
            }
            "buffer_next" => {
                if self.buffers.len() > 1 {
                    self.buf_index = (self.buf_index + 1) % self.buffers.len();
                }
            }
            "buffer_prev" => {
                if self.buffers.len() > 1 {
                    self.buf_index = if self.buf_index == 0 {
                        self.buffers.len() - 1
                    } else {
                        self.buf_index - 1
                    };
                }
            }
            "buffer_delete" => {
                if self.buffers.len() > 1 {
                    self.buffers.remove(self.buf_index);
                    if self.buf_index >= self.buffers.len() {
                        self.buf_index = self.buffers.len() - 1;
                    }
                } else {
                    self.buffers[0] = Buffer::new_empty();
                }
            }
            "buffer_new" => {
                self.buffers.push(Buffer::new_empty());
                self.buf_index = self.buffers.len() - 1;
            }
            "theme_cycle" => {
                self.current_theme_index = (self.current_theme_index + 1) % self.themes.len();
                self.status_msg = format!("Theme: {}", self.themes[self.current_theme_index].name);
            }
            "edit_undo" => {
                self.buffers[self.buf_index].undo();
            }
            "edit_redo" => {
                self.buffers[self.buf_index].redo();
            }
            "git_status" => {
                self.status_msg = "Git: see Lua implementation for full git workflow".to_string();
            }
            "finder_files" => {
                self.status_msg = "Finder: see Lua implementation".to_string();
            }
            "terminal_toggle" => {
                self.status_msg = "Terminal: see Lua implementation".to_string();
            }
            "lsp_hover" => {
                self.status_msg = "LSP: hover (see Lua implementation)".to_string();
            }
            "lsp_format" => {
                self.status_msg = "LSP: format (see Lua implementation)".to_string();
            }
            _ => {
                self.status_msg = format!("Action '{}' (see Lua implementation)", action);
            }
        }
    }

    fn execute_command(&mut self, cmd: &str) {
        let cmd = cmd.trim();
        if cmd.is_empty() {
            return;
        }
        if cmd == "w" || cmd == "write" {
            let buf = &mut self.buffers[self.buf_index];
            if let Err(e) = buf.save() {
                self.status_msg = format!("Error: {}", e);
            } else {
                self.status_msg = "Written".to_string();
            }
        } else if cmd == "q" || cmd == "quit" {
            let buf = &self.buffers[self.buf_index];
            if buf.is_dirty {
                self.status_msg = "No write since last change (add ! to override)".to_string();
            } else {
                self.should_quit = true;
            }
        } else if cmd == "wq" || cmd == "x" {
            let buf = &mut self.buffers[self.buf_index];
            let _ = buf.save();
            self.should_quit = true;
        } else if cmd == "q!" || cmd == "quit!" {
            self.should_quit = true;
        } else if cmd == "theme" {
            self.current_theme_index = (self.current_theme_index + 1) % self.themes.len();
            self.status_msg = format!("Theme: {}", self.themes[self.current_theme_index].name);
        } else if let Some(rest) = cmd.strip_prefix("theme ") {
            let query = rest.trim().to_lowercase();
            if let Some((idx, theme)) = self
                .themes
                .iter()
                .enumerate()
                .find(|(_, t)| t.name.to_lowercase().contains(&query) || t.id.contains(&query))
            {
                self.current_theme_index = idx;
                self.status_msg = format!("Applied theme: {}", theme.name);
            } else {
                self.status_msg = format!("Theme '{}' not found", query);
            }
        } else if cmd == "ls" || cmd == "buffers" {
            let names: Vec<String> = self
                .buffers
                .iter()
                .enumerate()
                .map(|(i, b)| {
                    let mark = if i == self.buf_index { "*" } else { " " };
                    let dirty = if b.is_dirty { "+" } else { " " };
                    let name = b
                        .file_path
                        .as_ref()
                        .and_then(|p| p.file_name())
                        .map(|n| n.to_string_lossy().to_string())
                        .unwrap_or_else(|| "Untitled".to_string());
                    format!("{}{}{} {}", i + 1, mark, dirty, name)
                })
                .collect();
            self.status_msg = format!("Buffers: {}", names.join(" | "));
        } else if let Some(rest) = cmd.strip_prefix("b ") {
            if let Ok(idx) = rest.trim().parse::<usize>() {
                if idx >= 1 && idx <= self.buffers.len() {
                    self.buf_index = idx - 1;
                    self.status_msg = format!("Switched to buffer {}", idx);
                } else {
                    self.status_msg = "Invalid buffer index".to_string();
                }
            }
        } else if cmd == "bd" || cmd == "bdelete" {
            self.dispatch_action("buffer_delete");
        } else if let Some(rest) = cmd.strip_prefix("e ") {
            let path = rest.trim();
            if !path.is_empty() {
                let buf = Buffer::open_or_create(path);
                self.buffers.push(buf);
                self.buf_index = self.buffers.len() - 1;
                self.show_dashboard = false;
                self.status_msg = format!("Opened: {}", path);
            }
        } else {
            self.status_msg = format!("Not an editor command: :{}", cmd);
        }
    }
}
