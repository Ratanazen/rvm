local Theme = {}

-- Helper to create a comprehensive theme with all 26 color tokens + UI aliases
local function make_theme(id, name, t)
    t.id = id
    t.name = name

    -- Backward compatibility aliases for UI rendering
    t.editor_bg = t.background
    t.text = t.foreground
    t.muted = t.comments
    t.border = t.borders
    t.sidebar_bg = t.sidebar
    t.header_bg = t.tabs
    t.status_bg = t.statusline
    t.status_fg = t.foreground
    t.accent = t.functions
    t.keyword = t.keywords
    t.string = t.strings
    t.number = t.numbers
    t.function_name = t.functions
    t.comment = t.comments

    return t
end

Theme.list = {
    -- 1. RVM Dark
    make_theme("rvm-dark", "1. RVM Dark", {
        background = {30, 30, 30}, foreground = {204, 204, 204}, cursor = {255, 255, 255}, selection = {38, 79, 120},
        line_numbers = {100, 100, 100}, current_line = {40, 40, 40}, comments = {106, 153, 85}, keywords = {86, 156, 214},
        strings = {206, 145, 120}, numbers = {181, 206, 168}, functions = {220, 220, 170}, variables = {156, 220, 254},
        types = {78, 201, 176}, operators = {212, 212, 212}, errors = {244, 71, 71}, warnings = {205, 149, 12},
        info = {117, 190, 255}, search = {97, 85, 0}, sidebar = {37, 37, 38}, tabs = {45, 45, 45},
        statusline = {37, 37, 38}, popup = {37, 37, 38}, borders = {60, 60, 60}, git_added = {78, 201, 176},
        git_modified = {226, 192, 141}, git_deleted = {244, 71, 71}
    }),

    -- 2. RVM Midnight
    make_theme("rvm-midnight", "2. RVM Midnight", {
        background = {9, 13, 22}, foreground = {224, 230, 237}, cursor = {129, 140, 248}, selection = {30, 27, 75},
        line_numbers = {76, 86, 106}, current_line = {15, 20, 34}, comments = {82, 97, 122}, keywords = {129, 140, 248},
        strings = {52, 211, 153}, numbers = {251, 191, 36}, functions = {167, 139, 250}, variables = {147, 197, 253},
        types = {99, 102, 241}, operators = {199, 210, 254}, errors = {248, 113, 113}, warnings = {251, 191, 36},
        info = {96, 165, 250}, search = {67, 56, 202}, sidebar = {15, 20, 34}, tabs = {20, 26, 42},
        statusline = {99, 102, 241}, popup = {20, 26, 42}, borders = {30, 41, 59}, git_added = {52, 211, 153},
        git_modified = {251, 191, 36}, git_deleted = {248, 113, 113}
    }),

    -- 3. RVM Black
    make_theme("rvm-black", "3. RVM Black", {
        background = {0, 0, 0}, foreground = {255, 255, 255}, cursor = {255, 255, 255}, selection = {40, 40, 40},
        line_numbers = {90, 90, 90}, current_line = {16, 16, 16}, comments = {85, 85, 85}, keywords = {96, 165, 250},
        strings = {74, 222, 128}, numbers = {248, 113, 113}, functions = {250, 204, 21}, variables = {243, 244, 246},
        types = {192, 132, 252}, operators = {209, 213, 219}, errors = {239, 68, 68}, warnings = {245, 158, 11},
        info = {59, 130, 246}, search = {60, 60, 0}, sidebar = {10, 10, 10}, tabs = {18, 18, 18},
        statusline = {37, 37, 38}, popup = {16, 16, 16}, borders = {34, 34, 34}, git_added = {74, 222, 128},
        git_modified = {250, 204, 21}, git_deleted = {239, 68, 68}
    }),

    -- 4. RVM Deep Ocean
    make_theme("rvm-deep-ocean", "4. RVM Deep Ocean", {
        background = {11, 19, 43}, foreground = {240, 244, 248}, cursor = {0, 229, 255}, selection = {28, 42, 74},
        line_numbers = {65, 90, 119}, current_line = {18, 29, 61}, comments = {74, 108, 142}, keywords = {0, 229, 255},
        strings = {100, 255, 218}, numbers = {255, 179, 71}, functions = {130, 170, 255}, variables = {179, 205, 224},
        types = {199, 146, 234}, operators = {137, 221, 255}, errors = {255, 83, 112}, warnings = {255, 203, 107},
        info = {130, 170, 255}, search = {23, 105, 170}, sidebar = {15, 23, 42}, tabs = {20, 32, 60},
        statusline = {0, 150, 214}, popup = {18, 29, 61}, borders = {35, 53, 90}, git_added = {100, 255, 218},
        git_modified = {255, 203, 107}, git_deleted = {255, 83, 112}
    }),

    -- 5. RVM Ocean
    make_theme("rvm-ocean", "5. RVM Ocean", {
        background = {15, 23, 42}, foreground = {226, 232, 240}, cursor = {56, 189, 248}, selection = {30, 41, 59},
        line_numbers = {71, 85, 105}, current_line = {23, 37, 84}, comments = {100, 116, 139}, keywords = {56, 189, 248},
        strings = {52, 211, 153}, numbers = {251, 146, 60}, functions = {125, 211, 252}, variables = {241, 245, 249},
        types = {165, 180, 252}, operators = {148, 163, 184}, errors = {248, 113, 113}, warnings = {251, 191, 36},
        info = {56, 189, 248}, search = {3, 105, 161}, sidebar = {15, 23, 42}, tabs = {30, 41, 59},
        statusline = {2, 132, 199}, popup = {30, 41, 59}, borders = {51, 65, 85}, git_added = {52, 211, 153},
        git_modified = {251, 191, 36}, git_deleted = {248, 113, 113}
    }),

    -- 6. RVM Blue
    make_theme("rvm-blue", "6. RVM Blue", {
        background = {10, 25, 47}, foreground = {204, 214, 246}, cursor = {100, 255, 218}, selection = {23, 42, 69},
        line_numbers = {70, 90, 120}, current_line = {17, 34, 64}, comments = {136, 146, 176}, keywords = {100, 255, 218},
        strings = {149, 222, 100}, numbers = {255, 193, 7}, functions = {97, 218, 251}, variables = {230, 241, 255},
        types = {187, 134, 252}, operators = {100, 255, 218}, errors = {255, 107, 107}, warnings = {255, 209, 102},
        info = {97, 218, 251}, search = {10, 75, 120}, sidebar = {13, 30, 55}, tabs = {17, 34, 64},
        statusline = {13, 71, 161}, popup = {17, 34, 64}, borders = {28, 55, 90}, git_added = {100, 255, 218},
        git_modified = {255, 209, 102}, git_deleted = {255, 107, 107}
    }),

    -- 7. RVM Cyan
    make_theme("rvm-cyan", "7. RVM Cyan", {
        background = {8, 28, 36}, foreground = {207, 250, 254}, cursor = {34, 211, 238}, selection = {22, 78, 99},
        line_numbers = {21, 94, 117}, current_line = {14, 45, 57}, comments = {77, 124, 138}, keywords = {34, 211, 238},
        strings = {45, 212, 191}, numbers = {251, 146, 60}, functions = {103, 232, 249}, variables = {236, 254, 255},
        types = {165, 243, 252}, operators = {165, 243, 252}, errors = {251, 113, 133}, warnings = {250, 204, 21},
        info = {34, 211, 238}, search = {14, 116, 144}, sidebar = {10, 36, 46}, tabs = {15, 50, 62},
        statusline = {8, 145, 178}, popup = {14, 45, 57}, borders = {21, 94, 117}, git_added = {45, 212, 191},
        git_modified = {250, 204, 21}, git_deleted = {251, 113, 133}
    }),

    -- 8. RVM Teal
    make_theme("rvm-teal", "8. RVM Teal", {
        background = {6, 30, 28}, foreground = {204, 251, 241}, cursor = {45, 212, 191}, selection = {19, 78, 74},
        line_numbers = {17, 94, 89}, current_line = {15, 45, 42}, comments = {75, 120, 115}, keywords = {45, 212, 191},
        strings = {52, 211, 153}, numbers = {251, 191, 36}, functions = {94, 234, 212}, variables = {240, 253, 250},
        types = {153, 246, 228}, operators = {153, 246, 228}, errors = {248, 113, 113}, warnings = {251, 191, 36},
        info = {45, 212, 191}, search = {15, 118, 110}, sidebar = {8, 38, 35}, tabs = {13, 50, 46},
        statusline = {13, 148, 136}, popup = {15, 45, 42}, borders = {19, 78, 74}, git_added = {52, 211, 153},
        git_modified = {251, 191, 36}, git_deleted = {248, 113, 113}
    }),

    -- 9. RVM Emerald
    make_theme("rvm-emerald", "9. RVM Emerald", {
        background = {6, 28, 20}, foreground = {209, 250, 229}, cursor = {52, 211, 153}, selection = {6, 78, 59},
        line_numbers = {16, 90, 65}, current_line = {12, 44, 32}, comments = {70, 120, 95}, keywords = {52, 211, 153},
        strings = {110, 231, 183}, numbers = {251, 191, 36}, functions = {167, 243, 208}, variables = {236, 253, 245},
        types = {52, 211, 153}, operators = {167, 243, 208}, errors = {248, 113, 113}, warnings = {251, 191, 36},
        info = {52, 211, 153}, search = {5, 150, 105}, sidebar = {8, 35, 25}, tabs = {12, 48, 35},
        statusline = {5, 150, 105}, popup = {12, 44, 32}, borders = {6, 78, 59}, git_added = {52, 211, 153},
        git_modified = {251, 191, 36}, git_deleted = {248, 113, 113}
    }),

    -- 10. RVM Forest
    make_theme("rvm-forest", "10. RVM Forest", {
        background = {20, 30, 22}, foreground = {218, 235, 220}, cursor = {74, 222, 128}, selection = {35, 60, 40},
        line_numbers = {70, 100, 75}, current_line = {28, 42, 32}, comments = {90, 125, 95}, keywords = {74, 222, 128},
        strings = {187, 247, 208}, numbers = {253, 224, 71}, functions = {134, 239, 172}, variables = {240, 253, 244},
        types = {163, 230, 53}, operators = {187, 247, 208}, errors = {248, 113, 113}, warnings = {250, 204, 21},
        info = {74, 222, 128}, search = {22, 101, 52}, sidebar = {24, 36, 27}, tabs = {30, 48, 35},
        statusline = {22, 101, 52}, popup = {28, 42, 32}, borders = {40, 65, 45}, git_added = {74, 222, 128},
        git_modified = {250, 204, 21}, git_deleted = {248, 113, 113}
    }),

    -- 11. RVM Green
    make_theme("rvm-green", "11. RVM Green", {
        background = {10, 24, 14}, foreground = {220, 252, 231}, cursor = {34, 197, 94}, selection = {20, 83, 45},
        line_numbers = {22, 101, 52}, current_line = {15, 38, 22}, comments = {65, 120, 75}, keywords = {34, 197, 94},
        strings = {134, 239, 172}, numbers = {250, 204, 21}, functions = {74, 222, 128}, variables = {240, 253, 244},
        types = {163, 230, 53}, operators = {187, 247, 208}, errors = {239, 68, 68}, warnings = {245, 158, 11},
        info = {34, 197, 94}, search = {21, 128, 61}, sidebar = {13, 30, 18}, tabs = {18, 44, 26},
        statusline = {21, 128, 61}, popup = {15, 38, 22}, borders = {20, 83, 45}, git_added = {34, 197, 94},
        git_modified = {250, 204, 21}, git_deleted = {239, 68, 68}
    }),

    -- 12. RVM Matrix
    make_theme("rvm-matrix", "12. RVM Matrix", {
        background = {0, 0, 0}, foreground = {0, 255, 102}, cursor = {0, 255, 102}, selection = {0, 50, 20},
        line_numbers = {0, 100, 40}, current_line = {5, 25, 10}, comments = {0, 140, 50}, keywords = {0, 255, 102},
        strings = {102, 255, 153}, numbers = {153, 255, 187}, functions = {0, 255, 102}, variables = {179, 255, 204},
        types = {0, 204, 82}, operators = {102, 255, 153}, errors = {255, 50, 50}, warnings = {255, 200, 50},
        info = {0, 255, 102}, search = {0, 80, 30}, sidebar = {3, 15, 7}, tabs = {5, 25, 10},
        statusline = {0, 180, 60}, popup = {5, 25, 10}, borders = {0, 150, 60}, git_added = {0, 255, 102},
        git_modified = {255, 200, 50}, git_deleted = {255, 50, 50}
    }),

    -- 13. RVM Purple
    make_theme("rvm-purple", "13. RVM Purple", {
        background = {24, 14, 38}, foreground = {243, 232, 255}, cursor = {192, 132, 252}, selection = {59, 28, 92},
        line_numbers = {107, 70, 145}, current_line = {36, 21, 56}, comments = {130, 95, 165}, keywords = {192, 132, 252},
        strings = {216, 180, 254}, numbers = {251, 146, 60}, functions = {233, 213, 255}, variables = {250, 245, 255},
        types = {168, 85, 247}, operators = {216, 180, 254}, errors = {248, 113, 113}, warnings = {250, 204, 21},
        info = {192, 132, 252}, search = {88, 28, 135}, sidebar = {28, 16, 44}, tabs = {36, 21, 56},
        statusline = {147, 51, 234}, popup = {36, 21, 56}, borders = {74, 35, 115}, git_added = {74, 222, 128},
        git_modified = {250, 204, 21}, git_deleted = {248, 113, 113}
    }),

    -- 14. RVM Violet
    make_theme("rvm-violet", "14. RVM Violet", {
        background = {20, 12, 34}, foreground = {237, 233, 254}, cursor = {167, 139, 250}, selection = {46, 16, 101},
        line_numbers = {91, 33, 182}, current_line = {30, 18, 51}, comments = {124, 58, 237}, keywords = {167, 139, 250},
        strings = {196, 181, 253}, numbers = {251, 191, 36}, functions = {139, 92, 246}, variables = {245, 243, 255},
        types = {196, 181, 253}, operators = {221, 214, 254}, errors = {248, 113, 113}, warnings = {251, 191, 36},
        info = {167, 139, 250}, search = {76, 29, 149}, sidebar = {24, 14, 40}, tabs = {32, 20, 54},
        statusline = {124, 58, 237}, popup = {30, 18, 51}, borders = {67, 24, 120}, git_added = {52, 211, 153},
        git_modified = {251, 191, 36}, git_deleted = {248, 113, 113}
    }),

    -- 15. RVM Indigo
    make_theme("rvm-indigo", "15. RVM Indigo", {
        background = {15, 18, 38}, foreground = {224, 231, 255}, cursor = {129, 140, 248}, selection = {30, 27, 75},
        line_numbers = {67, 56, 202}, current_line = {24, 28, 56}, comments = {99, 102, 241}, keywords = {129, 140, 248},
        strings = {165, 180, 252}, numbers = {251, 146, 60}, functions = {199, 210, 254}, variables = {238, 242, 255},
        types = {99, 102, 241}, operators = {199, 210, 254}, errors = {248, 113, 113}, warnings = {251, 191, 36},
        info = {129, 140, 248}, search = {49, 46, 129}, sidebar = {18, 22, 46}, tabs = {26, 31, 64},
        statusline = {79, 70, 229}, popup = {24, 28, 56}, borders = {49, 46, 129}, git_added = {74, 222, 128},
        git_modified = {251, 191, 36}, git_deleted = {248, 113, 113}
    }),

    -- 16. RVM Rose
    make_theme("rvm-rose", "16. RVM Rose", {
        background = {32, 14, 22}, foreground = {255, 228, 230}, cursor = {251, 113, 133}, selection = {76, 5, 25},
        line_numbers = {136, 19, 55}, current_line = {48, 20, 32}, comments = {159, 18, 57}, keywords = {251, 113, 133},
        strings = {253, 164, 175}, numbers = {251, 146, 60}, functions = {244, 63, 94}, variables = {255, 241, 242},
        types = {225, 29, 72}, operators = {254, 205, 211}, errors = {239, 68, 68}, warnings = {250, 204, 21},
        info = {251, 113, 133}, search = {100, 10, 35}, sidebar = {38, 16, 26}, tabs = {50, 22, 34},
        statusline = {225, 29, 72}, popup = {48, 20, 32}, borders = {88, 28, 48}, git_added = {74, 222, 128},
        git_modified = {250, 204, 21}, git_deleted = {239, 68, 68}
    }),

    -- 17. RVM Red
    make_theme("rvm-red", "17. RVM Red", {
        background = {30, 12, 12}, foreground = {254, 226, 226}, cursor = {248, 113, 113}, selection = {69, 10, 10},
        line_numbers = {127, 29, 29}, current_line = {45, 18, 18}, comments = {153, 27, 27}, keywords = {248, 113, 113},
        strings = {252, 165, 165}, numbers = {251, 146, 60}, functions = {239, 68, 68}, variables = {254, 242, 242},
        types = {220, 38, 38}, operators = {254, 202, 202}, errors = {239, 68, 68}, warnings = {245, 158, 11},
        info = {96, 165, 250}, search = {90, 15, 15}, sidebar = {36, 14, 14}, tabs = {48, 20, 20},
        statusline = {220, 38, 38}, popup = {45, 18, 18}, borders = {85, 20, 20}, git_added = {74, 222, 128},
        git_modified = {251, 191, 36}, git_deleted = {239, 68, 68}
    }),

    -- 18. RVM Orange
    make_theme("rvm-orange", "18. RVM Orange", {
        background = {30, 18, 10}, foreground = {255, 237, 213}, cursor = {251, 146, 60}, selection = {67, 26, 6},
        line_numbers = {124, 45, 18}, current_line = {44, 26, 15}, comments = {154, 52, 18}, keywords = {251, 146, 60},
        strings = {253, 186, 116}, numbers = {250, 204, 21}, functions = {249, 115, 22}, variables = {255, 247, 237},
        types = {234, 88, 12}, operators = {254, 215, 170}, errors = {239, 68, 68}, warnings = {250, 204, 21},
        info = {96, 165, 250}, search = {95, 35, 10}, sidebar = {36, 22, 12}, tabs = {48, 28, 16},
        statusline = {234, 88, 12}, popup = {44, 26, 15}, borders = {85, 38, 18}, git_added = {74, 222, 128},
        git_modified = {250, 204, 21}, git_deleted = {239, 68, 68}
    }),

    -- 19. RVM Amber
    make_theme("rvm-amber", "19. RVM Amber", {
        background = {28, 20, 8}, foreground = {254, 243, 199}, cursor = {251, 191, 36}, selection = {69, 39, 4},
        line_numbers = {120, 53, 15}, current_line = {42, 30, 12}, comments = {146, 64, 14}, keywords = {251, 191, 36},
        strings = {252, 211, 77}, numbers = {248, 113, 113}, functions = {245, 158, 11}, variables = {255, 251, 235},
        types = {217, 119, 6}, operators = {253, 230, 138}, errors = {239, 68, 68}, warnings = {245, 158, 11},
        info = {96, 165, 250}, search = {95, 50, 8}, sidebar = {34, 24, 10}, tabs = {46, 32, 14},
        statusline = {217, 119, 6}, popup = {42, 30, 12}, borders = {80, 48, 15}, git_added = {74, 222, 128},
        git_modified = {251, 191, 36}, git_deleted = {239, 68, 68}
    }),

    -- 20. RVM Sunset
    make_theme("rvm-sunset", "20. RVM Sunset", {
        background = {26, 15, 30}, foreground = {253, 230, 240}, cursor = {244, 114, 182}, selection = {65, 20, 60},
        line_numbers = {120, 50, 100}, current_line = {38, 22, 44}, comments = {140, 65, 110}, keywords = {251, 146, 60},
        strings = {244, 114, 182}, numbers = {250, 204, 21}, functions = {244, 63, 94}, variables = {255, 240, 248},
        types = {192, 132, 252}, operators = {253, 186, 116}, errors = {239, 68, 68}, warnings = {250, 204, 21},
        info = {147, 197, 253}, search = {90, 25, 75}, sidebar = {32, 18, 36}, tabs = {42, 24, 48},
        statusline = {225, 29, 72}, popup = {38, 22, 44}, borders = {75, 30, 70}, git_added = {74, 222, 128},
        git_modified = {250, 204, 21}, git_deleted = {239, 68, 68}
    }),

    -- 21. RVM Neon
    make_theme("rvm-neon", "21. RVM Neon", {
        background = {10, 10, 20}, foreground = {0, 255, 242}, cursor = {255, 0, 128}, selection = {40, 10, 60},
        line_numbers = {60, 60, 100}, current_line = {20, 20, 40}, comments = {80, 80, 130}, keywords = {255, 0, 128},
        strings = {0, 255, 128}, numbers = {255, 238, 0}, functions = {0, 255, 242}, variables = {240, 240, 255},
        types = {180, 0, 255}, operators = {0, 255, 242}, errors = {255, 0, 80}, warnings = {255, 200, 0},
        info = {0, 200, 255}, search = {80, 0, 120}, sidebar = {15, 15, 30}, tabs = {25, 25, 50},
        statusline = {255, 0, 128}, popup = {20, 20, 40}, borders = {60, 30, 90}, git_added = {0, 255, 128},
        git_modified = {255, 238, 0}, git_deleted = {255, 0, 80}
    }),

    -- 22. RVM Cyber
    make_theme("rvm-cyber", "22. RVM Cyber", {
        background = {13, 2, 33}, foreground = {0, 240, 255}, cursor = {255, 0, 127}, selection = {58, 0, 125},
        line_numbers = {90, 0, 180}, current_line = {28, 5, 60}, comments = {112, 0, 255}, keywords = {255, 0, 127},
        strings = {0, 240, 255}, numbers = {255, 230, 0}, functions = {0, 255, 102}, variables = {230, 240, 255},
        types = {180, 0, 255}, operators = {255, 0, 127}, errors = {255, 0, 80}, warnings = {255, 200, 0},
        info = {0, 240, 255}, search = {90, 0, 140}, sidebar = {20, 5, 45}, tabs = {32, 8, 70},
        statusline = {255, 0, 127}, popup = {28, 5, 60}, borders = {120, 0, 180}, git_added = {0, 255, 102},
        git_modified = {255, 230, 0}, git_deleted = {255, 0, 80}
    }),

    -- 23. RVM Terminal (green-on-black CRT look — NOT terminal-native)
    -- Renamed from rvm-terminal to rvm-crt-terminal to free the rvm-terminal id
    -- for the actual terminal-native theme (#41).
    make_theme("rvm-crt-terminal", "23. RVM CRT Terminal", {
        background = {10, 16, 13}, foreground = {0, 255, 102}, cursor = {0, 255, 102}, selection = {0, 68, 27},
        line_numbers = {0, 102, 41}, current_line = {15, 25, 20}, comments = {0, 136, 55}, keywords = {0, 255, 102},
        strings = {102, 255, 153}, numbers = {153, 255, 187}, functions = {0, 255, 102}, variables = {180, 255, 200},
        types = {0, 204, 82}, operators = {102, 255, 153}, errors = {255, 60, 60}, warnings = {255, 200, 40},
        info = {0, 255, 102}, search = {0, 80, 30}, sidebar = {8, 14, 11}, tabs = {15, 25, 20},
        statusline = {0, 102, 41}, popup = {15, 25, 20}, borders = {0, 102, 41}, git_added = {0, 255, 102},
        git_modified = {255, 200, 40}, git_deleted = {255, 60, 60}
    }),

    -- 24. RVM Dracula
    make_theme("rvm-dracula", "24. RVM Dracula", {
        background = {40, 42, 54}, foreground = {248, 248, 242}, cursor = {248, 248, 242}, selection = {68, 71, 90},
        line_numbers = {98, 114, 164}, current_line = {55, 58, 74}, comments = {98, 114, 164}, keywords = {255, 121, 198},
        strings = {241, 250, 140}, numbers = {189, 147, 249}, functions = {80, 250, 123}, variables = {248, 248, 242},
        types = {139, 233, 253}, operators = {255, 121, 198}, errors = {255, 85, 85}, warnings = {255, 184, 108},
        info = {139, 233, 253}, search = {80, 85, 120}, sidebar = {33, 34, 44}, tabs = {50, 52, 65},
        statusline = {98, 114, 164}, popup = {45, 48, 62}, borders = {68, 71, 90}, git_added = {80, 250, 123},
        git_modified = {255, 184, 108}, git_deleted = {255, 85, 85}
    }),

    -- 25. RVM Nord
    make_theme("rvm-nord", "25. RVM Nord", {
        background = {46, 52, 64}, foreground = {216, 222, 233}, cursor = {216, 222, 233}, selection = {67, 76, 94},
        line_numbers = {76, 86, 106}, current_line = {59, 66, 82}, comments = {97, 110, 136}, keywords = {129, 161, 193},
        strings = {163, 190, 140}, numbers = {180, 142, 173}, functions = {136, 192, 208}, variables = {236, 239, 244},
        types = {143, 188, 187}, operators = {129, 161, 193}, errors = {191, 97, 106}, warnings = {235, 203, 139},
        info = {136, 192, 208}, search = {67, 76, 94}, sidebar = {39, 44, 54}, tabs = {59, 66, 82},
        statusline = {94, 129, 172}, popup = {59, 66, 82}, borders = {59, 66, 82}, git_added = {163, 190, 140},
        git_modified = {235, 203, 139}, git_deleted = {191, 97, 106}
    }),

    -- 26. RVM Tokyo Night
    make_theme("rvm-tokyo-night", "26. RVM Tokyo Night", {
        background = {26, 27, 38}, foreground = {169, 177, 214}, cursor = {192, 202, 245}, selection = {40, 52, 87},
        line_numbers = {86, 95, 137}, current_line = {36, 40, 59}, comments = {86, 95, 137}, keywords = {187, 154, 247},
        strings = {158, 206, 106}, numbers = {255, 158, 100}, functions = {122, 162, 247}, variables = {192, 202, 245},
        types = {42, 195, 222}, operators = {137, 221, 255}, errors = {247, 118, 142}, warnings = {224, 175, 104},
        info = {122, 162, 247}, search = {61, 89, 161}, sidebar = {22, 22, 30}, tabs = {36, 40, 59},
        statusline = {122, 162, 247}, popup = {36, 40, 59}, borders = {36, 40, 59}, git_added = {158, 206, 106},
        git_modified = {224, 175, 104}, git_deleted = {247, 118, 142}
    }),

    -- 27. RVM Monokai
    make_theme("rvm-monokai", "27. RVM Monokai", {
        background = {39, 40, 34}, foreground = {248, 248, 242}, cursor = {248, 248, 240}, selection = {73, 72, 62},
        line_numbers = {117, 113, 94}, current_line = {62, 61, 50}, comments = {117, 113, 94}, keywords = {249, 38, 114},
        strings = {230, 219, 116}, numbers = {174, 129, 255}, functions = {166, 226, 46}, variables = {248, 248, 242},
        types = {102, 217, 239}, operators = {249, 38, 114}, errors = {249, 38, 114}, warnings = {253, 151, 31},
        info = {102, 217, 239}, search = {90, 85, 50}, sidebar = {30, 31, 28}, tabs = {62, 61, 50},
        statusline = {249, 38, 114}, popup = {62, 61, 50}, borders = {62, 61, 50}, git_added = {166, 226, 46},
        git_modified = {253, 151, 31}, git_deleted = {249, 38, 114}
    }),

    -- 28. RVM Gruvbox
    make_theme("rvm-gruvbox", "28. RVM Gruvbox", {
        background = {40, 40, 40}, foreground = {235, 219, 178}, cursor = {235, 219, 178}, selection = {80, 73, 69},
        line_numbers = {146, 131, 116}, current_line = {60, 56, 54}, comments = {146, 131, 116}, keywords = {251, 73, 52},
        strings = {184, 187, 38}, numbers = {211, 134, 155}, functions = {184, 187, 38}, variables = {235, 219, 178},
        types = {250, 189, 47}, operators = {254, 128, 25}, errors = {204, 36, 29}, warnings = {215, 153, 33},
        info = {131, 165, 152}, search = {102, 92, 84}, sidebar = {29, 32, 33}, tabs = {60, 56, 54},
        statusline = {254, 128, 25}, popup = {60, 56, 54}, borders = {60, 56, 54}, git_added = {184, 187, 38},
        git_modified = {215, 153, 33}, git_deleted = {204, 36, 29}
    }),

    -- 29. RVM Solarized Dark
    make_theme("rvm-solarized-dark", "29. RVM Solarized Dark", {
        background = {0, 43, 54}, foreground = {131, 148, 150}, cursor = {147, 161, 161}, selection = {7, 54, 66},
        line_numbers = {88, 110, 117}, current_line = {7, 54, 66}, comments = {88, 110, 117}, keywords = {133, 153, 0},
        strings = {42, 161, 152}, numbers = {211, 54, 130}, functions = {38, 139, 210}, variables = {131, 148, 150},
        types = {181, 137, 0}, operators = {133, 153, 0}, errors = {220, 50, 47}, warnings = {181, 137, 0},
        info = {38, 139, 210}, search = {0, 75, 90}, sidebar = {0, 33, 43}, tabs = {7, 54, 66},
        statusline = {38, 139, 210}, popup = {7, 54, 66}, borders = {10, 60, 72}, git_added = {133, 153, 0},
        git_modified = {181, 137, 0}, git_deleted = {220, 50, 47}
    }),

    -- 30. RVM One Dark
    make_theme("rvm-one-dark", "30. RVM One Dark", {
        background = {40, 44, 52}, foreground = {171, 178, 191}, cursor = {82, 139, 255}, selection = {62, 68, 81},
        line_numbers = {92, 99, 112}, current_line = {44, 49, 58}, comments = {92, 99, 112}, keywords = {198, 120, 221},
        strings = {152, 195, 121}, numbers = {209, 154, 102}, functions = {97, 175, 239}, variables = {224, 108, 117},
        types = {229, 192, 123}, operators = {86, 182, 194}, errors = {224, 108, 117}, warnings = {229, 192, 123},
        info = {97, 175, 239}, search = {62, 68, 81}, sidebar = {33, 37, 43}, tabs = {44, 49, 58},
        statusline = {97, 175, 239}, popup = {44, 49, 58}, borders = {62, 68, 81}, git_added = {152, 195, 121},
        git_modified = {229, 192, 123}, git_deleted = {224, 108, 117}
    }),

    -- 31. RVM Catppuccin
    make_theme("rvm-catppuccin", "31. RVM Catppuccin", {
        background = {30, 30, 46}, foreground = {205, 214, 244}, cursor = {245, 224, 220}, selection = {69, 71, 90},
        line_numbers = {108, 112, 134}, current_line = {49, 50, 68}, comments = {108, 112, 134}, keywords = {203, 166, 247},
        strings = {166, 227, 161}, numbers = {250, 179, 135}, functions = {137, 180, 250}, variables = {205, 214, 244},
        types = {249, 226, 175}, operators = {148, 226, 213}, errors = {243, 139, 168}, warnings = {249, 226, 175},
        info = {137, 180, 250}, search = {69, 71, 90}, sidebar = {24, 24, 37}, tabs = {49, 50, 68},
        statusline = {203, 166, 247}, popup = {49, 50, 68}, borders = {49, 50, 68}, git_added = {166, 227, 161},
        git_modified = {249, 226, 175}, git_deleted = {243, 139, 168}
    }),

    -- 32. RVM Synthwave
    make_theme("rvm-synthwave", "32. RVM Synthwave", {
        background = {38, 25, 50}, foreground = {249, 42, 149}, cursor = {254, 228, 64}, selection = {66, 32, 92},
        line_numbers = {110, 60, 130}, current_line = {55, 35, 70}, comments = {110, 80, 140}, keywords = {254, 228, 64},
        strings = {44, 241, 237}, numbers = {254, 154, 0}, functions = {255, 30, 140}, variables = {240, 240, 255},
        types = {36, 241, 169}, operators = {254, 228, 64}, errors = {254, 68, 68}, warnings = {254, 228, 64},
        info = {44, 241, 237}, search = {85, 30, 110}, sidebar = {30, 18, 42}, tabs = {50, 30, 65},
        statusline = {249, 42, 149}, popup = {55, 35, 70}, borders = {90, 45, 115}, git_added = {36, 241, 169},
        git_modified = {254, 228, 64}, git_deleted = {254, 68, 68}
    }),

    -- 33. RVM High Contrast
    make_theme("rvm-high-contrast", "33. RVM High Contrast", {
        background = {0, 0, 0}, foreground = {255, 255, 255}, cursor = {0, 255, 255}, selection = {50, 50, 50},
        line_numbers = {150, 150, 150}, current_line = {20, 20, 20}, comments = {120, 120, 120}, keywords = {0, 255, 255},
        strings = {0, 255, 0}, numbers = {255, 255, 0}, functions = {255, 0, 255}, variables = {255, 255, 255},
        types = {0, 200, 255}, operators = {255, 255, 255}, errors = {255, 0, 0}, warnings = {255, 255, 0},
        info = {0, 255, 255}, search = {80, 80, 0}, sidebar = {5, 5, 5}, tabs = {20, 20, 20},
        statusline = {255, 255, 255}, popup = {20, 20, 20}, borders = {100, 100, 100}, git_added = {0, 255, 0},
        git_modified = {255, 255, 0}, git_deleted = {255, 0, 0}
    }),

    -- 34. RVM Light
    make_theme("rvm-light", "34. RVM Light", {
        background = {255, 255, 255}, foreground = {31, 41, 55}, cursor = {31, 41, 55}, selection = {219, 234, 254},
        line_numbers = {156, 163, 175}, current_line = {243, 244, 246}, comments = {156, 163, 175}, keywords = {217, 119, 6},
        strings = {22, 163, 74}, numbers = {147, 51, 234}, functions = {37, 99, 235}, variables = {17, 24, 39},
        types = {13, 148, 136}, operators = {75, 85, 99}, errors = {220, 38, 38}, warnings = {217, 119, 6},
        info = {37, 99, 235}, search = {254, 240, 138}, sidebar = {243, 244, 246}, tabs = {229, 231, 235},
        statusline = {37, 99, 235}, popup = {255, 255, 255}, borders = {209, 213, 219}, git_added = {22, 163, 74},
        git_modified = {217, 119, 6}, git_deleted = {220, 38, 38}
    }),

    -- 35. RVM Light Blue
    make_theme("rvm-light-blue", "35. RVM Light Blue", {
        background = {240, 249, 255}, foreground = {12, 74, 110}, cursor = {2, 132, 199}, selection = {186, 230, 253},
        line_numbers = {125, 211, 252}, current_line = {224, 242, 254}, comments = {56, 189, 248}, keywords = {2, 132, 199},
        strings = {5, 150, 105}, numbers = {217, 119, 6}, functions = {3, 105, 161}, variables = {15, 23, 42},
        types = {14, 116, 144}, operators = {14, 116, 144}, errors = {225, 29, 72}, warnings = {217, 119, 6},
        info = {2, 132, 199}, search = {186, 230, 253}, sidebar = {224, 242, 254}, tabs = {186, 230, 253},
        statusline = {2, 132, 199}, popup = {255, 255, 255}, borders = {125, 211, 252}, git_added = {5, 150, 105},
        git_modified = {217, 119, 6}, git_deleted = {225, 29, 72}
    }),

    -- 36. RVM GitHub Light
    make_theme("rvm-github-light", "36. RVM GitHub Light", {
        background = {255, 255, 255}, foreground = {36, 41, 47}, cursor = {9, 105, 218}, selection = {182, 218, 255},
        line_numbers = {140, 149, 159}, current_line = {246, 248, 250}, comments = {101, 109, 118}, keywords = {207, 34, 46},
        strings = {10, 48, 105}, numbers = {5, 80, 174}, functions = {130, 80, 223}, variables = {36, 41, 47},
        types = {149, 56, 0}, operators = {207, 34, 46}, errors = {207, 34, 46}, warnings = {154, 103, 0},
        info = {9, 105, 218}, search = {255, 248, 197}, sidebar = {246, 248, 250}, tabs = {234, 238, 242},
        statusline = {9, 105, 218}, popup = {255, 255, 255}, borders = {208, 215, 222}, git_added = {26, 127, 55},
        git_modified = {154, 103, 0}, git_deleted = {207, 34, 46}
    }),

    -- 37. RVM Solarized Light
    make_theme("rvm-solarized-light", "37. RVM Solarized Light", {
        background = {253, 246, 227}, foreground = {101, 123, 131}, cursor = {88, 110, 117}, selection = {238, 232, 213},
        line_numbers = {147, 161, 161}, current_line = {238, 232, 213}, comments = {147, 161, 161}, keywords = {133, 153, 0},
        strings = {42, 161, 152}, numbers = {211, 54, 130}, functions = {38, 139, 210}, variables = {101, 123, 131},
        types = {181, 137, 0}, operators = {133, 153, 0}, errors = {220, 50, 47}, warnings = {181, 137, 0},
        info = {38, 139, 210}, search = {245, 235, 180}, sidebar = {238, 232, 213}, tabs = {225, 218, 198},
        statusline = {38, 139, 210}, popup = {253, 246, 227}, borders = {200, 190, 170}, git_added = {133, 153, 0},
        git_modified = {181, 137, 0}, git_deleted = {220, 50, 47}
    }),

    -- 38. RVM Paper
    make_theme("rvm-paper", "38. RVM Paper", {
        background = {248, 245, 236}, foreground = {56, 44, 34}, cursor = {56, 44, 34}, selection = {230, 220, 205},
        line_numbers = {160, 145, 130}, current_line = {238, 232, 220}, comments = {145, 130, 115}, keywords = {140, 60, 20},
        strings = {60, 110, 50}, numbers = {130, 40, 60}, functions = {30, 80, 140}, variables = {56, 44, 34},
        types = {120, 80, 20}, operators = {100, 80, 60}, errors = {180, 30, 30}, warnings = {170, 100, 20},
        info = {30, 80, 140}, search = {240, 220, 140}, sidebar = {238, 232, 220}, tabs = {228, 220, 205},
        statusline = {110, 90, 70}, popup = {248, 245, 236}, borders = {210, 200, 185}, git_added = {60, 110, 50},
        git_modified = {170, 100, 20}, git_deleted = {180, 30, 30}
    }),

    -- 39. RVM Sepia
    make_theme("rvm-sepia", "39. RVM Sepia", {
        background = {43, 30, 22}, foreground = {245, 222, 179}, cursor = {255, 228, 181}, selection = {75, 52, 38},
        line_numbers = {130, 100, 80}, current_line = {55, 40, 30}, comments = {140, 110, 90}, keywords = {255, 180, 100},
        strings = {190, 220, 140}, numbers = {255, 150, 120}, functions = {255, 210, 130}, variables = {245, 222, 179},
        types = {220, 170, 120}, operators = {230, 190, 140}, errors = {240, 100, 100}, warnings = {240, 180, 80},
        info = {170, 200, 240}, search = {100, 70, 45}, sidebar = {35, 24, 18}, tabs = {55, 40, 30},
        statusline = {160, 100, 60}, popup = {55, 40, 30}, borders = {80, 60, 45}, git_added = {190, 220, 140},
        git_modified = {240, 180, 80}, git_deleted = {240, 100, 100}
    }),

    -- 40. RVM Minimal
    make_theme("rvm-minimal", "40. RVM Minimal", {
        background = {18, 18, 18}, foreground = {220, 220, 220}, cursor = {255, 255, 255}, selection = {45, 45, 45},
        line_numbers = {70, 70, 70}, current_line = {26, 26, 26}, comments = {90, 90, 90}, keywords = {220, 220, 220},
        strings = {180, 180, 180}, numbers = {200, 200, 200}, functions = {240, 240, 240}, variables = {210, 210, 210},
        types = {190, 190, 190}, operators = {160, 160, 160}, errors = {255, 100, 100}, warnings = {255, 200, 100},
        info = {100, 200, 255}, search = {60, 60, 60}, sidebar = {14, 14, 14}, tabs = {24, 24, 24},
        statusline = {60, 60, 60}, popup = {26, 26, 26}, borders = {40, 40, 40}, git_added = {150, 220, 150},
        git_modified = {220, 200, 150}, git_deleted = {220, 150, 150}
    }),

    -- 41. RVM Terminal (terminal-native — per spec requirement #13)
    -- This theme intentionally uses ANSI default fg/bg. UI layer detects
    -- `terminal_native = true` and skips bg/fg painting, leaving the
    -- terminal emulator's own background and foreground colors in place.
    -- Syntax highlighting uses RGB truecolor (ANSI 256 / 24-bit compatible).
    -- Required by spec: "Default RVM must visually match the user's terminal."
    make_theme("rvm-terminal", "41. RVM Terminal", {
        -- The values below are placeholders. When `terminal_native == true`,
        -- the UI does NOT emit explicit bg/fg escape codes for editor areas.
        background = {0, 0, 0},       -- ignored when terminal_native == true
        foreground = {255, 255, 255},  -- ignored when terminal_native == true
        cursor = {255, 255, 255},
        selection = {40, 40, 40},       -- a subtle selection band is OK
        line_numbers = {120, 120, 120},
        current_line = {30, 30, 30},
        comments = {120, 120, 120},
        keywords = {99, 102, 241},      -- indigo (ANSI-ish, but RGB-truecolor is fine for syntax)
        strings = {52, 211, 153},       -- green
        numbers = {251, 191, 36},       -- amber
        functions = {56, 189, 248},     -- cyan
        variables = {226, 232, 240},
        types = {167, 139, 250},
        operators = {148, 163, 184},
        errors = {248, 113, 113},
        warnings = {251, 191, 36},
        info = {96, 165, 250},
        search = {67, 56, 202},
        sidebar = {0, 0, 0},            -- ignored (terminal_native)
        tabs = {0, 0, 0},                -- ignored (terminal_native)
        statusline = {60, 60, 60},       -- subtle band for statusline is OK
        popup = {30, 30, 30},           -- popups can have a slight bg for readability
        borders = {80, 80, 80},
        git_added = {52, 211, 153},
        git_modified = {251, 191, 36},
        git_deleted = {248, 113, 113},

        -- Flag for UI: do NOT paint editor background/foreground, defer to terminal emulator.
        -- Required by spec rule: "Default RVM must visually match the user's terminal."
        terminal_native = true,
    }),
}

function Theme.get(index_or_id)
    if type(index_or_id) == "number" then
        local idx = ((index_or_id - 1) % #Theme.list) + 1
        return Theme.list[idx]
    elseif type(index_or_id) == "string" then
        local query = index_or_id:lower():gsub("%s+", ""):gsub("-", "")
        for _, t in ipairs(Theme.list) do
            local tid = t.id:lower():gsub("%s+", ""):gsub("-", "")
            local tname = t.name:lower():gsub("%s+", ""):gsub("-", "")
            if tid == query or tname == query or tname:find(query, 1, true) then
                return t
            end
        end
    end
    return Theme.list[1]
end

-- Default theme is the terminal-native one (per spec: "Default RVM theme: terminal")
function Theme.default()
    return Theme.get("rvm-terminal") or Theme.list[1]
end

return Theme
