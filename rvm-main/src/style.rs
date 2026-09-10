// src/style.rs — Editor styles for the native Rust binary.
// Per spec requirement #15: add a new "lazyvim" style.
//
// Characteristics (per spec):
//   - compact
//   - keyboard-first
//   - clean
//   - minimal borders
//   - information dense
//   - project focused
//   - terminal-native

#[derive(Debug, Clone)]
pub struct Style {
    pub id: String,
    pub name: String,
    pub sidebar: bool,
    pub statusline: bool,
    pub tabline: bool,
    pub borders: bool,
    pub border_style: BorderStyle,
    pub line_numbers: bool,
    pub header: bool,
    pub padding: u16,
    pub explorer_width: u16,
    pub icons: bool,
    pub cursor_style: CursorStyle,
    pub popup_style: PopupStyle,
    pub terminal_position: TerminalPosition,
    pub desc: String,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum BorderStyle {
    None,
    Single,
    Double,
    Rounded,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum CursorStyle {
    Block,
    Bar,
    Underline,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum PopupStyle {
    Border,
    Minimal,
    Floating,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TerminalPosition {
    Hidden,
    Bottom,
    Side,
}

impl Style {
    pub fn all() -> Vec<Style> {
        vec![
            Style {
                id: "rvm-lazyvim".to_string(),
                name: "RVM LazyVim".to_string(),
                sidebar: true,
                statusline: true,
                tabline: true,
                borders: false,
                border_style: BorderStyle::None,
                line_numbers: true,
                header: false,
                padding: 0,
                explorer_width: 22,
                icons: true,
                cursor_style: CursorStyle::Block,
                popup_style: PopupStyle::Minimal,
                terminal_position: TerminalPosition::Hidden,
                desc: "Compact, keyboard-first LazyVim-inspired layout".to_string(),
            },
            Style {
                id: "rvm-classic".to_string(),
                name: "RVM Classic".to_string(),
                sidebar: true,
                statusline: true,
                tabline: true,
                borders: true,
                border_style: BorderStyle::Single,
                line_numbers: true,
                header: true,
                padding: 1,
                explorer_width: 24,
                icons: true,
                cursor_style: CursorStyle::Block,
                popup_style: PopupStyle::Border,
                terminal_position: TerminalPosition::Hidden,
                desc: "Standard full-featured layout".to_string(),
            },
            Style {
                id: "rvm-minimal".to_string(),
                name: "RVM Minimal".to_string(),
                sidebar: false,
                statusline: false,
                tabline: false,
                borders: false,
                border_style: BorderStyle::None,
                line_numbers: false,
                header: false,
                padding: 0,
                explorer_width: 0,
                icons: false,
                cursor_style: CursorStyle::Bar,
                popup_style: PopupStyle::Minimal,
                terminal_position: TerminalPosition::Hidden,
                desc: "Distraction-free canvas".to_string(),
            },
            Style {
                id: "rvm-vim".to_string(),
                name: "RVM Vim".to_string(),
                sidebar: false,
                statusline: true,
                tabline: false,
                borders: false,
                border_style: BorderStyle::None,
                line_numbers: true,
                header: false,
                padding: 0,
                explorer_width: 0,
                icons: false,
                cursor_style: CursorStyle::Block,
                popup_style: PopupStyle::Minimal,
                terminal_position: TerminalPosition::Bottom,
                desc: "Authentic Vim-like experience".to_string(),
            },
            Style {
                id: "rvm-ide".to_string(),
                name: "RVM IDE".to_string(),
                sidebar: true,
                statusline: true,
                tabline: true,
                borders: true,
                border_style: BorderStyle::Single,
                line_numbers: true,
                header: true,
                padding: 1,
                explorer_width: 28,
                icons: true,
                cursor_style: CursorStyle::Block,
                popup_style: PopupStyle::Floating,
                terminal_position: TerminalPosition::Bottom,
                desc: "Full IDE layout".to_string(),
            },
        ]
    }

    pub fn default_style() -> Self {
        // LazyVim is the default per spec requirement #15
        Self::all()[0].clone()
    }

    pub fn get(query: &str) -> Option<Self> {
        let q = query.to_lowercase().replace([' ', '-'], "");
        Self::all().into_iter().find(|s| {
            let sid = s.id.to_lowercase().replace([' ', '-'], "");
            let sname = s.name.to_lowercase().replace([' ', '-'], "");
            sid == q || sname == q || sname.contains(&q)
        })
    }
}
