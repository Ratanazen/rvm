use ratatui::style::Color;

#[derive(Debug, Clone)]
pub struct ThemeColors {
    pub editor_bg: Color,
    pub sidebar_bg: Color,
    pub header_bg: Color,
    pub status_bg: Color,
    pub status_text: Color,
    pub text: Color,
    pub muted_text: Color,
    pub border: Color,
    pub accent: Color,
    pub keyword: Color,
    pub string: Color,
    pub number: Color,
    pub function: Color,
    pub comment: Color,
    pub selection: Color,
    pub cursor: Color,
}

#[derive(Debug, Clone)]
pub struct Theme {
    pub id: String,
    pub name: String,
    pub colors: ThemeColors,
    /// True if this theme uses the terminal emulator's default fg/bg.
    /// Per spec requirement #13: "Default RVM theme: terminal"
    pub terminal_native: bool,
}

impl Theme {
    pub fn all() -> Vec<Theme> {
        // The terminal-native theme is FIRST, making it the default
        // (per spec: "Default RVM theme: terminal").
        vec![
            // 0. RVM Terminal — terminal-native (default per spec)
            Theme {
                id: "rvm-terminal".to_string(),
                name: "0. RVM Terminal".to_string(),
                terminal_native: true,
                colors: ThemeColors {
                    // Color::Reset = "use terminal emulator's color"
                    editor_bg: Color::Reset,
                    sidebar_bg: Color::Reset,
                    header_bg: Color::Reset,
                    status_bg: Color::Indexed(238),  // subtle ANSI 256 band
                    status_text: Color::Reset,
                    text: Color::Reset,
                    muted_text: Color::Indexed(242),  // ANSI 256 gray
                    border: Color::Indexed(238),
                    accent: Color::Indexed(75),       // ANSI 256 blue
                    keyword: Color::Indexed(99),      // ANSI 256 indigo
                    string: Color::Indexed(114),      // ANSI 256 green
                    number: Color::Indexed(179),      // ANSI 256 amber
                    function: Color::Indexed(75),     // ANSI 256 blue
                    comment: Color::Indexed(242),     // ANSI 256 gray
                    selection: Color::Indexed(238),
                    cursor: Color::Reset,
                },
            },
            // 1. RVM Dark
            Theme {
                id: "rvm-dark".to_string(),
                name: "1. RVM Dark".to_string(),
                terminal_native: false,
                colors: ThemeColors {
                    editor_bg: Color::Rgb(30, 30, 30),
                    sidebar_bg: Color::Rgb(37, 37, 38),
                    header_bg: Color::Rgb(45, 45, 45),
                    status_bg: Color::Rgb(0, 122, 204),
                    status_text: Color::Rgb(255, 255, 255),
                    text: Color::Rgb(204, 204, 204),
                    muted_text: Color::Rgb(133, 133, 133),
                    border: Color::Rgb(60, 60, 60),
                    accent: Color::Rgb(0, 122, 204),
                    keyword: Color::Rgb(86, 156, 214),
                    string: Color::Rgb(206, 145, 120),
                    number: Color::Rgb(181, 206, 168),
                    function: Color::Rgb(220, 220, 170),
                    comment: Color::Rgb(106, 153, 85),
                    selection: Color::Rgb(38, 79, 120),
                    cursor: Color::Rgb(255, 255, 255),
                },
            },
            // 2. RVM Midnight
            Theme {
                id: "rvm-midnight".to_string(),
                name: "2. RVM Midnight".to_string(),
                terminal_native: false,
                colors: ThemeColors {
                    editor_bg: Color::Rgb(9, 13, 22),
                    sidebar_bg: Color::Rgb(15, 20, 34),
                    header_bg: Color::Rgb(20, 26, 42),
                    status_bg: Color::Rgb(99, 102, 241),
                    status_text: Color::Rgb(255, 255, 255),
                    text: Color::Rgb(224, 230, 237),
                    muted_text: Color::Rgb(76, 86, 106),
                    border: Color::Rgb(30, 41, 59),
                    accent: Color::Rgb(99, 102, 241),
                    keyword: Color::Rgb(129, 140, 248),
                    string: Color::Rgb(52, 211, 153),
                    number: Color::Rgb(251, 191, 36),
                    function: Color::Rgb(167, 139, 250),
                    comment: Color::Rgb(82, 97, 122),
                    selection: Color::Rgb(30, 27, 75),
                    cursor: Color::Rgb(129, 140, 248),
                },
            },
            // 3. RVM Black
            Theme {
                id: "rvm-black".to_string(),
                name: "3. RVM Black".to_string(),
                terminal_native: false,
                colors: ThemeColors {
                    editor_bg: Color::Rgb(0, 0, 0),
                    sidebar_bg: Color::Rgb(12, 12, 12),
                    header_bg: Color::Rgb(20, 20, 20),
                    status_bg: Color::Rgb(37, 37, 38),
                    status_text: Color::Rgb(255, 255, 255),
                    text: Color::Rgb(255, 255, 255),
                    muted_text: Color::Rgb(102, 102, 102),
                    border: Color::Rgb(34, 34, 34),
                    accent: Color::Rgb(59, 130, 246),
                    keyword: Color::Rgb(96, 165, 250),
                    string: Color::Rgb(74, 222, 128),
                    number: Color::Rgb(248, 113, 113),
                    function: Color::Rgb(250, 204, 21),
                    comment: Color::Rgb(85, 85, 85),
                    selection: Color::Rgb(40, 40, 40),
                    cursor: Color::Rgb(255, 255, 255),
                },
            },
            // 4. RVM Dracula
            Theme {
                id: "rvm-dracula".to_string(),
                name: "4. RVM Dracula".to_string(),
                terminal_native: false,
                colors: ThemeColors {
                    editor_bg: Color::Rgb(40, 42, 54),
                    sidebar_bg: Color::Rgb(33, 34, 44),
                    header_bg: Color::Rgb(50, 52, 65),
                    status_bg: Color::Rgb(98, 114, 164),
                    status_text: Color::Rgb(248, 248, 242),
                    text: Color::Rgb(248, 248, 242),
                    muted_text: Color::Rgb(98, 114, 164),
                    border: Color::Rgb(68, 71, 90),
                    accent: Color::Rgb(189, 147, 249),
                    keyword: Color::Rgb(255, 121, 198),
                    string: Color::Rgb(241, 250, 140),
                    number: Color::Rgb(189, 147, 249),
                    function: Color::Rgb(80, 250, 123),
                    comment: Color::Rgb(98, 114, 164),
                    selection: Color::Rgb(68, 71, 90),
                    cursor: Color::Rgb(248, 248, 242),
                },
            },
            // 5. RVM Nord
            Theme {
                id: "rvm-nord".to_string(),
                name: "5. RVM Nord".to_string(),
                terminal_native: false,
                colors: ThemeColors {
                    editor_bg: Color::Rgb(46, 52, 64),
                    sidebar_bg: Color::Rgb(39, 44, 54),
                    header_bg: Color::Rgb(59, 66, 82),
                    status_bg: Color::Rgb(94, 129, 172),
                    status_text: Color::Rgb(236, 239, 244),
                    text: Color::Rgb(216, 222, 233),
                    muted_text: Color::Rgb(76, 86, 106),
                    border: Color::Rgb(59, 66, 82),
                    accent: Color::Rgb(136, 192, 208),
                    keyword: Color::Rgb(129, 161, 193),
                    string: Color::Rgb(163, 190, 140),
                    number: Color::Rgb(180, 142, 173),
                    function: Color::Rgb(136, 192, 208),
                    comment: Color::Rgb(97, 110, 136),
                    selection: Color::Rgb(67, 76, 94),
                    cursor: Color::Rgb(216, 222, 233),
                },
            },
            // 6. RVM Tokyo Night
            Theme {
                id: "rvm-tokyo-night".to_string(),
                name: "6. RVM Tokyo Night".to_string(),
                terminal_native: false,
                colors: ThemeColors {
                    editor_bg: Color::Rgb(26, 27, 38),
                    sidebar_bg: Color::Rgb(22, 22, 30),
                    header_bg: Color::Rgb(36, 40, 59),
                    status_bg: Color::Rgb(122, 162, 247),
                    status_text: Color::Rgb(21, 22, 30),
                    text: Color::Rgb(169, 177, 214),
                    muted_text: Color::Rgb(86, 95, 137),
                    border: Color::Rgb(36, 40, 59),
                    accent: Color::Rgb(122, 162, 247),
                    keyword: Color::Rgb(187, 154, 247),
                    string: Color::Rgb(158, 206, 106),
                    number: Color::Rgb(255, 158, 100),
                    function: Color::Rgb(122, 162, 247),
                    comment: Color::Rgb(86, 95, 137),
                    selection: Color::Rgb(40, 52, 87),
                    cursor: Color::Rgb(192, 202, 245),
                },
            },
            // 7. RVM Catppuccin
            Theme {
                id: "rvm-catppuccin".to_string(),
                name: "7. RVM Catppuccin".to_string(),
                terminal_native: false,
                colors: ThemeColors {
                    editor_bg: Color::Rgb(30, 30, 46),
                    sidebar_bg: Color::Rgb(24, 24, 37),
                    header_bg: Color::Rgb(49, 50, 68),
                    status_bg: Color::Rgb(203, 166, 247),
                    status_text: Color::Rgb(17, 11, 27),
                    text: Color::Rgb(205, 214, 244),
                    muted_text: Color::Rgb(108, 112, 134),
                    border: Color::Rgb(49, 50, 68),
                    accent: Color::Rgb(203, 166, 247),
                    keyword: Color::Rgb(203, 166, 247),
                    string: Color::Rgb(166, 227, 161),
                    number: Color::Rgb(250, 179, 135),
                    function: Color::Rgb(137, 180, 250),
                    comment: Color::Rgb(108, 112, 134),
                    selection: Color::Rgb(69, 71, 90),
                    cursor: Color::Rgb(245, 224, 220),
                },
            },
            // 8. RVM Monokai
            Theme {
                id: "rvm-monokai".to_string(),
                name: "8. RVM Monokai".to_string(),
                terminal_native: false,
                colors: ThemeColors {
                    editor_bg: Color::Rgb(39, 40, 34),
                    sidebar_bg: Color::Rgb(30, 31, 28),
                    header_bg: Color::Rgb(62, 61, 50),
                    status_bg: Color::Rgb(249, 38, 114),
                    status_text: Color::Rgb(255, 255, 255),
                    text: Color::Rgb(248, 248, 242),
                    muted_text: Color::Rgb(117, 113, 94),
                    border: Color::Rgb(62, 61, 50),
                    accent: Color::Rgb(249, 38, 114),
                    keyword: Color::Rgb(249, 38, 114),
                    string: Color::Rgb(230, 219, 116),
                    number: Color::Rgb(174, 129, 255),
                    function: Color::Rgb(166, 226, 46),
                    comment: Color::Rgb(117, 113, 94),
                    selection: Color::Rgb(73, 72, 62),
                    cursor: Color::Rgb(248, 248, 240),
                },
            },
            // 9. RVM Gruvbox
            Theme {
                id: "rvm-gruvbox".to_string(),
                name: "9. RVM Gruvbox".to_string(),
                terminal_native: false,
                colors: ThemeColors {
                    editor_bg: Color::Rgb(40, 40, 40),
                    sidebar_bg: Color::Rgb(29, 32, 33),
                    header_bg: Color::Rgb(60, 56, 54),
                    status_bg: Color::Rgb(254, 128, 25),
                    status_text: Color::Rgb(40, 40, 40),
                    text: Color::Rgb(235, 219, 178),
                    muted_text: Color::Rgb(146, 131, 116),
                    border: Color::Rgb(60, 56, 54),
                    accent: Color::Rgb(254, 128, 25),
                    keyword: Color::Rgb(251, 73, 52),
                    string: Color::Rgb(184, 187, 38),
                    number: Color::Rgb(211, 134, 155),
                    function: Color::Rgb(184, 187, 38),
                    comment: Color::Rgb(146, 131, 116),
                    selection: Color::Rgb(80, 73, 69),
                    cursor: Color::Rgb(235, 219, 178),
                },
            },
            // 10. RVM Cyber
            Theme {
                id: "rvm-cyber".to_string(),
                name: "10. RVM Cyber".to_string(),
                terminal_native: false,
                colors: ThemeColors {
                    editor_bg: Color::Rgb(13, 2, 33),
                    sidebar_bg: Color::Rgb(25, 10, 56),
                    header_bg: Color::Rgb(40, 15, 85),
                    status_bg: Color::Rgb(255, 0, 127),
                    status_text: Color::Rgb(255, 255, 255),
                    text: Color::Rgb(0, 240, 255),
                    muted_text: Color::Rgb(112, 0, 255),
                    border: Color::Rgb(255, 0, 127),
                    accent: Color::Rgb(255, 0, 127),
                    keyword: Color::Rgb(255, 0, 127),
                    string: Color::Rgb(0, 240, 255),
                    number: Color::Rgb(255, 230, 0),
                    function: Color::Rgb(0, 255, 102),
                    comment: Color::Rgb(112, 0, 255),
                    selection: Color::Rgb(58, 0, 125),
                    cursor: Color::Rgb(0, 240, 255),
                },
            },
            // 11. RVM Terminal Green
            Theme {
                id: "rvm-terminal-green".to_string(),
                name: "11. RVM Terminal Green".to_string(),
                terminal_native: false,
                colors: ThemeColors {
                    editor_bg: Color::Rgb(10, 16, 13),
                    sidebar_bg: Color::Rgb(6, 11, 9),
                    header_bg: Color::Rgb(15, 25, 20),
                    status_bg: Color::Rgb(0, 102, 41),
                    status_text: Color::Rgb(0, 255, 102),
                    text: Color::Rgb(0, 255, 102),
                    muted_text: Color::Rgb(0, 136, 55),
                    border: Color::Rgb(0, 102, 41),
                    accent: Color::Rgb(0, 255, 102),
                    keyword: Color::Rgb(0, 255, 102),
                    string: Color::Rgb(102, 255, 153),
                    number: Color::Rgb(153, 255, 187),
                    function: Color::Rgb(0, 255, 102),
                    comment: Color::Rgb(0, 102, 41),
                    selection: Color::Rgb(0, 68, 27),
                    cursor: Color::Rgb(0, 255, 102),
                },
            },
        ]
    }

    pub fn default_theme() -> Self {
        // The terminal-native theme is the default per spec requirement #13
        Self::all()[0].clone()
    }
}
