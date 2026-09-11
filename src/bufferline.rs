// src/bufferline.rs — Modern bufferline + statusline renderer for the Rust binary.
//
// Per spec requirement #17, statusline shows:
//   NORMAL  main.dart  Dart  LSP   Git:main  42:18
//
// Per spec requirement #10, bufferline shows multiple buffers with
// modified indicators, next/previous buffer, close buffer.

use ratatui::{
    layout::Rect,
    style::{Color, Modifier, Style},
    text::{Line, Span},
    widgets::Paragraph,
    Frame,
};

use crate::buffer::Buffer;
use crate::theme::ThemeColors;
use crate::vim::VimMode;

/// Render a bufferline at the top of the screen.
pub fn render_bufferline(
    f: &mut Frame,
    area: Rect,
    buffers: &[Buffer],
    active_index: usize,
    colors: &ThemeColors,
) {
    if buffers.is_empty() {
        let p = Paragraph::new(" [no buffers]").style(
            Style::default()
                .bg(colors.status_bg)
                .fg(colors.muted_text),
        );
        f.render_widget(p, area);
        return;
    }

    let mut spans: Vec<Span> = Vec::new();
    for (i, b) in buffers.iter().enumerate() {
        let name = b
            .file_path
            .as_ref()
            .and_then(|p| p.file_name())
            .map(|n| n.to_string_lossy().to_string())
            .unwrap_or_else(|| "Untitled".to_string());
        let dirty = if b.is_dirty { " ●" } else { "" };
        let is_active = i == active_index;

        let style = if is_active {
            Style::default()
                .bg(colors.status_bg)
                .fg(colors.status_text)
                .add_modifier(Modifier::BOLD)
        } else {
            Style::default().fg(colors.muted_text)
        };

        spans.push(Span::styled(format!(" {}{} ", name, dirty), style));
        if i + 1 < buffers.len() {
            spans.push(Span::styled(
                "│",
                Style::default().fg(colors.border),
            ));
        }
    }

    let line = Line::from(spans);
    let p = Paragraph::new(line).style(Style::default().bg(colors.editor_bg));
    f.render_widget(p, area);
}

/// Render a modern statusline at the bottom of the screen.
pub fn render_statusline(
    f: &mut Frame,
    area: Rect,
    mode: VimMode,
    buffer: &Buffer,
    language: &str,
    git_branch: Option<&str>,
    lsp_ok: bool,
    diag_count: usize,
    colors: &ThemeColors,
) {
    let file_name = buffer
        .file_path
        .as_ref()
        .and_then(|p| p.file_name())
        .map(|n| n.to_string_lossy().to_string())
        .unwrap_or_else(|| "Untitled".to_string());

    // Mode badge (color-coded)
    let mode_color = match mode {
        VimMode::Insert => Color::Rgb(78, 201, 176),
        VimMode::Visual | VimMode::VisualLine | VimMode::VisualBlock => Color::Rgb(96, 165, 250),
        VimMode::Command | VimMode::Search => Color::Rgb(251, 191, 36),
        VimMode::Replace => Color::Rgb(248, 113, 113),
        _ => Color::Rgb(56, 189, 248),
    };

    let mut spans: Vec<Span> = Vec::new();
    spans.push(Span::styled(
        format!(" {} ", mode.label()),
        Style::default()
            .bg(mode_color)
            .fg(Color::Black)
            .add_modifier(Modifier::BOLD),
    ));

    // File name + language
    spans.push(Span::styled(
        format!("  {}  ", file_name),
        Style::default().bg(colors.status_bg).fg(colors.accent),
    ));
    spans.push(Span::styled(
        format!("{}  ", language),
        Style::default().bg(colors.status_bg).fg(colors.muted_text),
    ));

    // LSP indicator
    let lsp_str = if lsp_ok { "LSP OK" } else { "LSP --" };
    spans.push(Span::styled(
        format!("{}  ", lsp_str),
        Style::default()
            .bg(colors.status_bg)
            .fg(colors.muted_text),
    ));

    // Git branch
    if let Some(branch) = git_branch {
        spans.push(Span::styled(
            format!("Git:{}  ", branch),
            Style::default().bg(colors.status_bg).fg(colors.accent),
        ));
    }

    // Diagnostics count
    if diag_count > 0 {
        spans.push(Span::styled(
            format!("⨉ {}  ", diag_count),
            Style::default().bg(colors.status_bg).fg(Color::Rgb(248, 113, 113)),
        ));
    }

    // Position
    spans.push(Span::styled(
        format!("{}:{}", buffer.cursor_row + 1, buffer.cursor_col + 1),
        Style::default().bg(colors.status_bg).fg(colors.muted_text),
    ));

    let line = Line::from(spans);
    let p = Paragraph::new(line).style(Style::default().bg(colors.status_bg));
    f.render_widget(p, area);
}
