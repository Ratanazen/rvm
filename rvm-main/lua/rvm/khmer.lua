-- lua/rvm/khmer.lua
-- First-class Khmer localization & translation layer for RVM (Ratana Vim)
-- Supports English ('en') and Khmer ('km') with non-breaking fallback.

local M = {}

M.current_lang = "en" -- default language

M.translations = {
  en = {
    save = "Save",
    open = "Open",
    search = "Search",
    files = "Files",
    project = "Project",
    terminal = "Terminal",
    git = "Git",
    diagnostics = "Diagnostics",
    errors = "Errors",
    warnings = "Warnings",
    success = "Success",
    update = "Update",
    settings = "Settings",
    plugins = "Plugins",
    language = "Language",
    health = "Health",
    version = "Version",
    welcome = "Welcome to RVM (Ratana Vim) — Khmer-Friendly Neovim Distribution!",
    mode_normal = "NORMAL",
    mode_insert = "INSERT",
    mode_visual = "VISUAL",
    mode_command = "COMMAND",
  },
  km = {
    save = "រក្សាទុក",
    open = "បើក",
    search = "ស្វែងរក",
    files = "ឯកសារ",
    project = "គម្រោង",
    terminal = "ស្ថានីយ",
    git = "ហ្គីត",
    diagnostics = "ការធ្វើរោគវិនិច្ឆ័យ",
    errors = "កំហុស",
    warnings = "ការព្រមាន",
    success = "ជោគជ័យ",
    update = "បច្ចុប្បន្នភាព",
    settings = "ការកំណត់",
    plugins = "កម្មវិធីជំនួយ",
    language = "ភាសា",
    health = "សុខភាព",
    version = "កំណែ",
    welcome = "សូមស្វាគមន៍មកកាន់ RVM (Ratana Vim) — កម្មវិធីនិពន្ធ Neovim ភាសាខ្មែរ!",
    mode_normal = "ធម្មតា",
    mode_insert = "បញ្ចូល",
    mode_visual = "មើលឃើញ",
    mode_command = "ពាក្យបញ្ជា",
  },
}

--- Translate a key into the active language
--- @param key string
--- @return string
function M.t(key)
  local lang_table = M.translations[M.current_lang] or M.translations.en
  return lang_table[key] or M.translations.en[key] or key
end

--- Set current language mode
--- @param lang string 'en' or 'km'
function M.set_lang(lang)
  if lang == "km" or lang == "khmer" then
    M.current_lang = "km"
    vim.notify("RVM Language set to Khmer (ភាសាខ្មែរ)", vim.log.levels.INFO, { title = "RVM Localization" })
  else
    M.current_lang = "en"
    vim.notify("RVM Language set to English", vim.log.levels.INFO, { title = "RVM Localization" })
  end
end

return M
