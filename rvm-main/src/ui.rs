use ratatui::{
    layout::{Constraint, Direction, Layout, Rect},
    style::{Color, Modifier, Style},
    text::{Line, Span},
    widgets::{Block, Borders, List, ListItem, Paragraph},
    Frame,
};

use crate::buffer::Buffer;
use crate::explorer::FileExplorer;
use crate::style::Style as AppStyle;
use crate::theme::Theme;
use crate::vim::VimMode;
use crate::whichkey::WhichKey;

pub struct UI<'a> {
    pub theme: Theme,
    pub style: AppStyle,
    pub vim_mode: VimMode,
    pub command_input: &'a str,
    pub search_input: &'a str,
    pub status_msg: &'a str,
    pub show_dashboard: bool,
    pub whichkey: &'a WhichKey,
}

impl<'a> UI<'a> {
    pub fn render(&self, f: &mut Frame, buffer: &Buffer, explorer: &FileExplorer) {
        let colors = &self.theme.colors;
        let native = self.theme.terminal_native;

        let area = f.area();
        let main_chunks = Layout::default()
            .direction(Direction::Vertical)
            .constraints([
                Constraint::Length(1), // bufferline (rendered separately by app.rs)
                Constraint::Length(1), // top header
                Constraint::Min(1),    // body
                Constraint::Length(1), // statusline
                Constraint::Length(if self.vim_mode == VimMode::Command
                    || self.vim_mode == VimMode::Search
                {
                    1
                } else {
                    0
                }),
            ])
            .split(area);

        // Top header
        let file_name = buffer
            .file_path
            .as_ref()
            .and_then(|p| p.file_name())
            .map(|n| n.to_string_lossy().to_string())
            .unwrap_or_else(|| "Untitled".to_string());

        let dirty_flag = if buffer.is_dirty { " [+]" } else { "" };
        let header_text = format!(" RVM — {}{}", file_name, dirty_flag);
        let header = Paragraph::new(header_text).style(
            Style::default()
                .fg(colors.accent)
                .add_modifier(Modifier::BOLD),
        );
        f.render_widget(header, main_chunks[1]);

        // Body: explorer + editor
        let body_area = main_chunks[2];
        let body_chunks = if explorer.is_visible {
            Layout::default()
                .direction(Direction::Horizontal)
                .constraints([Constraint::Length(self.style.explorer_width), Constraint::Min(1)])
                .split(body_area)
        } else {
            Layout::default()
                .direction(Direction::Horizontal)
                .constraints([Constraint::Percentage(0), Constraint::Percentage(100)])
                .split(body_area)
        };

        // Sidebar explorer
        if explorer.is_visible {
            let explorer_block = Block::default()
                .borders(Borders::RIGHT)
                .border_style(Style::default().fg(colors.border));

            let items: Vec<ListItem> = explorer
                .entries
                .iter()
                .enumerate()
                .map(|(idx, entry)| {
                    let prefix = if entry.is_dir { "📁 " } else { "📄 " };
                    let style = if idx == explorer.selected_index {
                        Style::default()
                            .bg(colors.selection)
                            .fg(colors.text)
                            .add_modifier(Modifier::BOLD)
                    } else if entry.is_dir {
                        Style::default().fg(colors.accent)
                    } else {
                        Style::default().fg(colors.text)
                    };
                    ListItem::new(format!("{}{}", prefix, entry.name)).style(style)
                })
                .collect();

            let explorer_list = List::new(items);
            f.render_widget(explorer_list.block(explorer_block), body_chunks[0]);
        }

        // Editor or dashboard
        let editor_area = body_chunks[1];
        if self.show_dashboard {
            self.render_dashboard(f, editor_area, colors);
        } else {
            self.render_editor(f, editor_area, buffer, colors);
        }

        // Statusline (rendered via bufferline.rs for the modern format)
        let info = Paragraph::new(Line::from(vec![
            Span::styled(
                format!(" {} ", self.vim_mode.label()),
                mode_style(self.vim_mode, colors),
            ),
            Span::styled(
                format!(
                    "  {}  |  Ln {}, Col {}  |  Theme: {}",
                    file_name,
                    buffer.cursor_row + 1,
                    buffer.cursor_col + 1,
                    self.theme.name
                ),
                Style::default().bg(colors.status_bg).fg(colors.status_text),
            ),
        ]))
        .style(Style::default().bg(colors.status_bg));
        f.render_widget(info, main_chunks[3]);

        // Command/search bar
        if self.vim_mode == VimMode::Command {
            let cmd_text = format!(":{}", self.command_input);
            let cmd_bar = Paragraph::new(cmd_text)
                .style(Style::default().bg(colors.status_bg).fg(colors.accent));
            f.render_widget(cmd_bar, main_chunks[4]);
        } else if self.vim_mode == VimMode::Search {
            let search_text = format!("/{}", self.search_input);
            let search_bar = Paragraph::new(search_text)
                .style(Style::default().bg(colors.status_bg).fg(colors.accent));
            f.render_widget(search_bar, main_chunks[4]);
        }

        // Which-key popup overlay
        if self.whichkey.is_open() {
            self.render_whichkey(f, area, colors);
        }
    }

    fn render_dashboard(&self, f: &mut Frame, area: Rect, colors: &crate::theme::ThemeColors) {
        let logo_lines = vec![
            Line::from(Span::styled(
                "   ██████╗  ██╗   ██╗ ███╗   ███╗",
                Style::default().fg(Color::Indexed(75)).add_modifier(Modifier::BOLD),
            )),
            Line::from(Span::styled(
                "   ██╔══██╗ ██║   ██║ ████╗ ████║",
                Style::default().fg(Color::Indexed(75)).add_modifier(Modifier::BOLD),
            )),
            Line::from(Span::styled(
                "   ██████╔╝ ██║   ██║ ██╔████╔██║",
                Style::default().fg(Color::Indexed(75)).add_modifier(Modifier::BOLD),
            )),
            Line::from(Span::styled(
                "   ██╔══██╗ ██║   ██║ ██║╚██╔╝██║",
                Style::default().fg(Color::Indexed(75)).add_modifier(Modifier::BOLD),
            )),
            Line::from(Span::styled(
                "   ██║  ██║ ╚██████╔╝ ██║ ╚═╝ ██║",
                Style::default().fg(Color::Indexed(75)).add_modifier(Modifier::BOLD),
            )),
            Line::from(Span::styled(
                "   ╚═╝  ╚═╝  ╚═════╝  ╚═╝     ╚═╝",
                Style::default().fg(Color::Indexed(75)).add_modifier(Modifier::BOLD),
            )),
            Line::from(""),
        ];

        let menu_items = vec![
            ("Find File",        "ff"),
            ("New File",         "n"),
            ("Projects",         "pp"),
            ("Find Text",         "fg"),
            ("Recent Files",     "fr"),
            ("Switch Theme",     "t"),
            ("Explorer",         "e"),
            ("Toggle Terminal", "tt"),
            ("Git Status",       "gg"),
            ("Quit",             "q"),
        ];

        let mut lines = logo_lines;
        for (label, key) in menu_items {
            lines.push(Line::from(vec![
                Span::styled(
                    format!("    {:<24}", label),
                    Style::default().fg(colors.text),
                ),
                Span::styled(
                    key.to_string(),
                    Style::default()
                        .fg(Color::Indexed(208))
                        .add_modifier(Modifier::BOLD),
                ),
            ]));
        }
        lines.push(Line::from(""));
        lines.push(Line::from(Span::styled(
            "    ⚡ RVM 2.0 — Vim + LazyVim UX, native terminal editor",
            Style::default().fg(Color::Indexed(170)),
        )));

        let dashboard = Paragraph::new(lines);
        f.render_widget(dashboard, area);
    }

    fn render_editor(
        &self,
        f: &mut Frame,
        area: Rect,
        buffer: &Buffer,
        colors: &crate::theme::ThemeColors,
    ) {
        let editor_height = area.height as usize;
        let line_count = buffer.lines.len();
        let gutter_width = format!("{}", line_count).len().max(3) + 3;

        let visible_lines = buffer
            .lines
            .iter()
            .enumerate()
            .skip(buffer.row_offset)
            .take(editor_height);

        let mut paragraph_lines: Vec<Line> = Vec::new();

        for (row_idx, line_str) in visible_lines {
            let is_cursor_row = row_idx == buffer.cursor_row;
            let line_num_str = format!("{:>w$} │ ", row_idx + 1, w = gutter_width - 3);

            let gutter_style = if is_cursor_row {
                Style::default().fg(colors.accent).add_modifier(Modifier::BOLD)
            } else {
                Style::default().fg(colors.muted_text)
            };

            let mut spans = vec![Span::styled(line_num_str, gutter_style)];

            let line_view = if buffer.col_offset < line_str.len() {
                &line_str[buffer.col_offset..]
            } else {
                ""
            };

            if is_cursor_row {
                let cursor_col = buffer.cursor_col.saturating_sub(buffer.col_offset);
                let line_chars: Vec<char> = line_view.chars().collect();

                let before: String = line_chars.iter().take(cursor_col).collect();
                let cursor_char = line_chars.get(cursor_col).copied().unwrap_or(' ');
                let after: String = line_chars.iter().skip(cursor_col + 1).collect();

                spans.push(Span::styled(before, Style::default().fg(colors.text)));
                spans.push(Span::styled(
                    cursor_char.to_string(),
                    Style::default()
                        .bg(colors.cursor)
                        .fg(colors.editor_bg)
                        .add_modifier(Modifier::BOLD),
                ));
                spans.push(Span::styled(after, Style::default().fg(colors.text)));
            } else {
                spans.push(Span::styled(line_view, Style::default().fg(colors.text)));
            }

            paragraph_lines.push(Line::from(spans));
        }

        let editor_paragraph = Paragraph::new(paragraph_lines);
        f.render_widget(editor_paragraph, area);
    }

    fn render_whichkey(&self, f: &mut Frame, area: Rect, colors: &crate::theme::ThemeColors) {
        let rows = self.whichkey.hint_rows();
        if rows.is_empty() {
            return;
        }

        let max_label_len = rows.iter().map(|r| r.label.len()).max().unwrap_or(0).max(8);
        let col_w = max_label_len + 12;
        let n_cols = ((area.width as usize) / col_w).max(1);
        let n_rows = (rows.len() + n_cols - 1) / n_cols;

        let popup_h = (n_rows + 2) as u16;
        let popup_w = ((n_cols * col_w + 2) as u16).min(area.width);
        let popup_x = (area.width.saturating_sub(popup_w)) / 2;
        let popup_y = area.height.saturating_sub(popup_h).saturating_sub(2);

        let popup_area = Rect::new(popup_x, popup_y, popup_w, popup_h);

        let title = if self.whichkey.prefix.is_empty() {
            "Which-Key".to_string()
        } else {
            format!("Which-Key — {}", self.whichkey.prefix)
        };

        let mut lines: Vec<Line> = Vec::new();
        for r in 1..=n_rows {
            let mut spans: Vec<Span> = Vec::new();
            for c in 0..n_cols {
                let idx = c * n_rows + (r - 1);
                if let Some(row) = rows.get(idx) {
                    spans.push(Span::styled(
                        format!(" {:>2}", row.key),
                        Style::default()
                            .fg(colors.keyword)
                            .add_modifier(Modifier::BOLD),
                    ));
                    spans.push(Span::styled(
                        format!(" {} {}  ", row.icon, row.label),
                        Style::default().fg(colors.text),
                    ));
                }
            }
            lines.push(Line::from(spans));
        }

        let popup = Paragraph::new(lines)
            .block(Block::default().borders(Borders::ALL).title(format!(" {} ", title)))
            .style(Style::default().bg(colors.editor_bg).fg(colors.text));
        f.render_widget(popup, popup_area);
    }
}

fn mode_style(mode: VimMode, colors: &crate::theme::ThemeColors) -> Style {
    match mode {
        VimMode::Normal => Style::default()
            .bg(colors.accent)
            .fg(colors.status_text)
            .add_modifier(Modifier::BOLD),
        VimMode::Insert => Style::default()
            .bg(Color::Rgb(34, 197, 94))
            .fg(colors.status_text)
            .add_modifier(Modifier::BOLD),
        VimMode::Replace => Style::default()
            .bg(Color::Rgb(248, 113, 113))
            .fg(colors.status_text)
            .add_modifier(Modifier::BOLD),
        VimMode::Visual | VimMode::VisualLine | VimMode::VisualBlock => Style::default()
            .bg(Color::Rgb(96, 165, 250))
            .fg(colors.status_text)
            .add_modifier(Modifier::BOLD),
        VimMode::Command | VimMode::Search => Style::default()
            .bg(Color::Rgb(234, 179, 8))
            .fg(Color::Rgb(0, 0, 0))
            .add_modifier(Modifier::BOLD),
    }
}
