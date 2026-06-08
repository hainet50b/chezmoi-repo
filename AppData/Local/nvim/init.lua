-- ============================================================
-- Neovim — slim config (no LSP). A fast editor for quick edits.
-- Heavy dev / AI live in Zed / JetBrains / Claude Code.
-- Plugins via vim.pack (built-in); all pure-Lua, no build step.
-- ============================================================

vim.g.mapleader = " "

-- Title
vim.opt.title = true
vim.opt.titlestring = "%t"

-- Editor
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.list = true
vim.opt.listchars = "lead:·,trail:·"

-- Config-file types use 2-space indent
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "json", "jsonc", "yaml", "toml" },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
  end,
})

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.keymap.set("n", "<Space>nhl", vim.cmd.nohlsearch)

-- Clipboard + highlight on yank
vim.opt.clipboard = "unnamedplus"
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight on yank",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Mode
vim.keymap.set("i", "fd", "<Esc>")
vim.keymap.set("t", "fd", "<C-\\><C-n>")

-- Lua eval
vim.keymap.set("n", "<Space><Space>x", ":source %<CR>")
vim.keymap.set("n", "<Space>x", ":.lua<CR>")
vim.keymap.set("v", "<Space>x", ":lua<CR>")

-- Window
vim.keymap.set("n", "<Space>ww", vim.cmd.enew)
vim.keymap.set("n", "<Space>wl", function() vim.cmd.vsplit(); vim.cmd.wincmd("l") end)
vim.keymap.set("n", "<Space>wh", vim.cmd.vsplit)
vim.keymap.set("n", "<Space>wj", function() vim.cmd.split(); vim.cmd.wincmd("j") end)
vim.keymap.set("n", "<Space>wk", vim.cmd.split)

-- Terminal (PowerShell, without changing global &shell)
local function term_pwsh() vim.cmd("term pwsh") end
vim.keymap.set("n", "<Space>tt", term_pwsh)
vim.keymap.set("n", "<Space>tj", function() vim.cmd("belowright split"); term_pwsh() end)
vim.keymap.set("n", "<Space>tk", function() vim.cmd.split(); term_pwsh() end)
vim.keymap.set("n", "<Space>tl", function() vim.cmd("belowright vsplit"); term_pwsh() end)
vim.keymap.set("n", "<Space>th", function() vim.cmd.vsplit(); term_pwsh() end)
vim.api.nvim_create_autocmd("TermOpen", {
  desc = "Terminal starts in insert mode",
  group = vim.api.nvim_create_augroup("term-insert", { clear = true }),
  callback = function() vim.cmd.startinsert() end,
})

-- Quickfix
vim.keymap.set("n", "<M-j>", vim.cmd.cnext)
vim.keymap.set("n", "<M-k>", vim.cmd.cprevious)

-- ============================================================
-- Plugins (vim.pack — built-in manager)
-- ============================================================
vim.pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
  { src = "https://github.com/ibhagwan/fzf-lua" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/nvim-mini/mini.nvim" },
})

-- Colorscheme
require("catppuccin").setup({})
vim.cmd.colorscheme("catppuccin")

-- mini: icons (used by oil / fzf-lua), autopairs, buffer remove
require("mini.icons").setup()
require("mini.pairs").setup()
local bufremove = require("mini.bufremove")
bufremove.setup()
vim.keymap.set("n", "<Space>bd", function() bufremove.delete() end, { desc = "Delete buffer, keep layout" })

-- oil: floating file explorer
require("oil").setup({
  columns = { "icon" },
  keymaps = { ["<Esc>"] = { "actions.close", mode = "n" } },
  view_options = { show_hidden = true },
  float = { max_width = 0.85, max_height = 0.85, border = "single", preview_split = "right" },
})
do
  local oil = require("oil")
  vim.keymap.set("n", "<Space>ee", function() oil.open_float(vim.fn.stdpath("config")) end, { desc = "Explorer: nvim config" })
  vim.keymap.set("n", "<Space>ed", function() oil.open_float(vim.uv.cwd()) end, { desc = "Explorer: cwd" })
  vim.keymap.set("n", "<Space>ef", function() oil.open_float(vim.fn.expand("%:p:h")) end, { desc = "Explorer: current file dir" })
  vim.keymap.set("n", "<Space>eh", function() oil.open_float(vim.fn.expand("~")) end, { desc = "Explorer: home" })
end

-- fzf-lua: fuzzy find + grep (uses installed fzf + ripgrep)
local fzf = require("fzf-lua")
fzf.setup({})
do
  local function files(key, cwd_fn, desc, hidden)
    vim.keymap.set("n", key, function()
      local opts = { cwd = cwd_fn() }
      if hidden then opts.fd_opts = [[--color=never --type f --hidden --follow --exclude .git]] end
      fzf.files(opts)
    end, { desc = desc })
  end
  files("<Space>fd", function() return vim.uv.cwd() end, "Find files (cwd)")
  files("<Space>fD", function() return vim.uv.cwd() end, "Find files (cwd, hidden)", true)
  files("<Space>fe", function() return vim.fn.stdpath("config") end, "Find files (nvim config)")
  files("<Space>fE", function() return vim.fn.stdpath("config") end, "Find files (nvim config, hidden)", true)
  files("<Space>ff", function() return vim.fn.expand("%:p:h") end, "Find files (current file dir)")
  files("<Space>fF", function() return vim.fn.expand("%:p:h") end, "Find files (current file dir, hidden)", true)
  files("<Space>fh", function() return vim.fn.expand("~") end, "Find files (home)")
  files("<Space>fH", function() return vim.fn.expand("~") end, "Find files (home, hidden)", true)
  vim.keymap.set("n", "<Space>fb", fzf.buffers, { desc = "Buffers" })
  vim.keymap.set("n", "<Space>hh", fzf.help_tags, { desc = "Help tags" })
  vim.keymap.set("n", "<Space>hk", fzf.keymaps, { desc = "Keymaps" })

  local function grep(key, cwd_fn, desc)
    vim.keymap.set("n", key, function() fzf.live_grep({ cwd = cwd_fn() }) end, { desc = desc })
  end
  grep("<Space>gd", function() return vim.uv.cwd() end, "Grep (cwd)")
  grep("<Space>ge", function() return vim.fn.stdpath("config") end, "Grep (nvim config)")
  grep("<Space>gf", function() return vim.fn.expand("%:p:h") end, "Grep (current file dir)")
end
