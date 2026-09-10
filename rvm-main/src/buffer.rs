use std::fs;
use std::path::{Path, PathBuf};

#[derive(Debug, Clone)]
pub struct BufferState {
    pub lines: Vec<String>,
    pub cursor_row: usize,
    pub cursor_col: usize,
}

#[derive(Debug)]
pub struct Buffer {
    pub file_path: Option<PathBuf>,
    pub lines: Vec<String>,
    pub cursor_row: usize,
    pub cursor_col: usize,
    pub row_offset: usize,
    pub col_offset: usize,
    pub is_dirty: bool,
    pub undo_stack: Vec<BufferState>,
    pub redo_stack: Vec<BufferState>,
    pub yank_clipboard: Option<String>,
    pub search_query: Option<String>,
    pub search_matches: Vec<(usize, usize)>, // (row, col)
}

impl Buffer {
    pub fn new_empty() -> Self {
        Self {
            file_path: None,
            lines: vec![String::new()],
            cursor_row: 0,
            cursor_col: 0,
            row_offset: 0,
            col_offset: 0,
            is_dirty: false,
            undo_stack: Vec::new(),
            redo_stack: Vec::new(),
            yank_clipboard: None,
            search_query: None,
            search_matches: Vec::new(),
        }
    }

    pub fn from_file<P: AsRef<Path>>(path: P) -> std::io::Result<Self> {
        const BUF_LIMIT: usize = 10_000_000;
        let path_buf = path.as_ref().to_path_buf();
        let metadata = fs::metadata(&path_buf)?;
        if metadata.len() > BUF_LIMIT as u64 {
            return Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                format!("File size {} exceeds limit of {} bytes", metadata.len(), BUF_LIMIT),
            ));
        }

        let content = fs::read_to_string(&path_buf)?;
        let lines: Vec<String> = if content.is_empty() {
            vec![String::new()]
        } else {
            content.lines().map(|s| s.to_string()).collect()
        };

        Ok(Self {
            file_path: Some(path_buf),
            lines,
            cursor_row: 0,
            cursor_col: 0,
            row_offset: 0,
            col_offset: 0,
            is_dirty: false,
            undo_stack: Vec::new(),
            redo_stack: Vec::new(),
            yank_clipboard: None,
            search_query: None,
            search_matches: Vec::new(),
        })
    }

    pub fn save(&mut self) -> std::io::Result<()> {
        if let Some(ref path) = self.file_path {
            let content = self.lines.join("\n");
            fs::write(path, content)?;
            self.is_dirty = false;
            Ok(())
        } else {
            Err(std::io::Error::new(
                std::io::ErrorKind::NotFound,
                "No file path specified for save",
            ))
        }
    }

    pub fn save_as<P: AsRef<Path>>(&mut self, path: P) -> std::io::Result<()> {
        let path_buf = path.as_ref().to_path_buf();
        let content = self.lines.join("\n");
        fs::write(&path_buf, content)?;
        self.file_path = Some(path_buf);
        self.is_dirty = false;
        Ok(())
    }

    pub fn save_state(&mut self) {
        if self.undo_stack.len() > 100 {
            self.undo_stack.remove(0);
        }
        self.undo_stack.push(BufferState {
            lines: self.lines.clone(),
            cursor_row: self.cursor_row,
            cursor_col: self.cursor_col,
        });
        self.redo_stack.clear();
    }

    pub fn undo(&mut self) {
        if let Some(state) = self.undo_stack.pop() {
            self.redo_stack.push(BufferState {
                lines: self.lines.clone(),
                cursor_row: self.cursor_row,
                cursor_col: self.cursor_col,
            });
            self.lines = state.lines;
            self.cursor_row = state.cursor_row;
            self.cursor_col = state.cursor_col;
            self.is_dirty = true;
        }
    }

    pub fn redo(&mut self) {
        if let Some(state) = self.redo_stack.pop() {
            self.undo_stack.push(BufferState {
                lines: self.lines.clone(),
                cursor_row: self.cursor_row,
                cursor_col: self.cursor_col,
            });
            self.lines = state.lines;
            self.cursor_row = state.cursor_row;
            self.cursor_col = state.cursor_col;
            self.is_dirty = true;
        }
    }

    pub fn insert_char(&mut self, ch: char) {
        self.save_state();
        if self.cursor_row >= self.lines.len() {
            self.lines.push(String::new());
        }
        let line = &mut self.lines[self.cursor_row];
        if self.cursor_col >= line.len() {
            line.push(ch);
        } else {
            line.insert(self.cursor_col, ch);
        }
        self.cursor_col += 1;
        self.is_dirty = true;
    }

    pub fn insert_newline(&mut self) {
        self.save_state();
        if self.cursor_row >= self.lines.len() {
            self.lines.push(String::new());
            self.cursor_row = self.lines.len() - 1;
            self.cursor_col = 0;
            self.is_dirty = true;
            return;
        }

        let current_line = &self.lines[self.cursor_row];
        let split_pos = self.cursor_col.min(current_line.len());
        let tail = current_line[split_pos..].to_string();
        self.lines[self.cursor_row] = current_line[..split_pos].to_string();

        self.cursor_row += 1;
        self.lines.insert(self.cursor_row, tail);
        self.cursor_col = 0;
        self.is_dirty = true;
    }

    pub fn delete_char(&mut self) {
        if self.cursor_row >= self.lines.len() {
            return;
        }

        if self.cursor_col > 0 {
            self.save_state();
            let line = &mut self.lines[self.cursor_row];
            line.remove(self.cursor_col - 1);
            self.cursor_col -= 1;
            self.is_dirty = true;
        } else if self.cursor_row > 0 {
            self.save_state();
            let prev_line_len = self.lines[self.cursor_row - 1].len();
            let curr_line = self.lines.remove(self.cursor_row);
            self.cursor_row -= 1;
            self.lines[self.cursor_row].push_str(&curr_line);
            self.cursor_col = prev_line_len;
            self.is_dirty = true;
        }
    }

    pub fn delete_line(&mut self) {
        if self.lines.is_empty() {
            return;
        }
        self.save_state();
        let deleted = self.lines.remove(self.cursor_row);
        self.yank_clipboard = Some(deleted);
        if self.lines.is_empty() {
            self.lines.push(String::new());
        }
        if self.cursor_row >= self.lines.len() {
            self.cursor_row = self.lines.len() - 1;
        }
        self.cursor_col = 0;
        self.is_dirty = true;
    }

    pub fn yank_line(&mut self) {
        if self.cursor_row < self.lines.len() {
            self.yank_clipboard = Some(self.lines[self.cursor_row].clone());
        }
    }

    pub fn paste_line(&mut self) {
        if let Some(ref text) = self.yank_clipboard.clone() {
            self.save_state();
            self.cursor_row += 1;
            if self.cursor_row >= self.lines.len() {
                self.lines.push(text.clone());
            } else {
                self.lines.insert(self.cursor_row, text.clone());
            }
            self.cursor_col = 0;
            self.is_dirty = true;
        }
    }

    pub fn search(&mut self, query: &str) {
        self.search_query = Some(query.to_string());
        self.search_matches.clear();

        if query.is_empty() {
            return;
        }

        for (r_idx, line) in self.lines.iter().enumerate() {
            for (c_idx, _) in line.match_indices(query) {
                self.search_matches.push((r_idx, c_idx));
            }
        }

        // Move to first match after cursor
        if let Some(&(r, c)) = self.search_matches.iter().find(|&&(r, c)| {
            r > self.cursor_row || (r == self.cursor_row && c >= self.cursor_col)
        }) {
            self.cursor_row = r;
            self.cursor_col = c;
        } else if let Some(&(r, c)) = self.search_matches.first() {
            self.cursor_row = r;
            self.cursor_col = c;
        }
    }

    pub fn next_match(&mut self) {
        if self.search_matches.is_empty() {
            return;
        }

        if let Some(&(r, c)) = self.search_matches.iter().find(|&&(r, c)| {
            r > self.cursor_row || (r == self.cursor_row && c > self.cursor_col)
        }) {
            self.cursor_row = r;
            self.cursor_col = c;
        } else if let Some(&(r, c)) = self.search_matches.first() {
            self.cursor_row = r;
            self.cursor_col = c;
        }
    }

    pub fn clamp_cursor(&mut self) {
        if self.lines.is_empty() {
            self.lines.push(String::new());
        }
        if self.cursor_row >= self.lines.len() {
            self.cursor_row = self.lines.len() - 1;
        }
        let line_len = self.lines[self.cursor_row].len();
        if self.cursor_col > line_len {
            self.cursor_col = line_len;
        }
    }
}
