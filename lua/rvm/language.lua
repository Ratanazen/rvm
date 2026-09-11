-- lua/rvm/language.lua
-- RVM Khmer (km) / English (en) localization engine.
-- Purposeful translation layer without over-translating code symbols or breaking Unicode/UTF-8 editing.

local M = {}

M.current = "en"

M.dict = {
  en = {
    system_health = "System Health",
    system_ok = "SYSTEM OK",
    mode_normal = "NORMAL",
    mode_insert = "INSERT",
    mode_visual = "VISUAL",
    mode_command = "COMMAND",
    open_project = "Open Project",
    find_file = "Find File",
    recent_files = "Recent Files",
    git_status = "Git",
    configuration = "Configuration",
    terminal = "Terminal",
    lsp = "LSP",
    plugins = "Plugins",
    settings = "Settings",
    health = "Health",
    language = "Language",
    diagnostics = "Diagnostics",
    version = "Version",
    theme = "Theme",
  },
  km = {
    system_health = "សុខភាពប្រព័ន្ធ",
    system_ok = "ប្រព័ន្ធដំណើរការល្អ",
    mode_normal = "ធម្មតា",
    mode_insert = "បញ្ចូល",
    mode_visual = "មើលឃើញ",
    mode_command = "ពាក្យបញ្ជា",
    open_project = "បើកគម្រោង",
    find_file = "ស្វែងរកឯកសារ",
    recent_files = "ឯកសារថ្មីៗ",
    git_status = "ហ្គីត",
    configuration = "ការកំណត់",
    terminal = "ស្ថានីយ",
    lsp = "ម៉ាស៊ីនបម្រើភាសា (LSP)",
    plugins = "កម្មវិធីជំនួយ",
    settings = "ការកំណត់",
    health = "សុខភាព",
    language = "ភាសា",
    diagnostics = "ការធ្វើរោគវិនិច្ឆ័យ",
    version = "កំណែ",
    theme = "រូបរាង",
  },
}

--- Get localized string
--- @param key string
--- @return string
function M.t(key)
  local lang = M.dict[M.current] or M.dict.en
  return lang[key] or M.dict.en[key] or key
end

--- Set current language
--- @param lang string 'km' or 'en'
function M.set(lang)
  if lang == "km" or lang == "khmer" then
    M.current = "km"
    vim.notify("RVM Language: Khmer (ភាសាខ្មែរ)", vim.log.levels.INFO, { title = "RVM" })
  else
    M.current = "en"
    vim.notify("RVM Language: English", vim.log.levels.INFO, { title = "RVM" })
  end
end

return M
