-- ==================================================
-- THEME
-- ==================================================

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
vim.api.nvim_set_hl(0, "TabLine", { bg = "none" })
vim.api.nvim_set_hl(0, "TabLineFill", { bg = "none", fg = "#767676" })
vim.api.nvim_set_hl(0, "TabLineSel", { bg = "none" })
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "none" })

-- ==================================================
-- OPTIONS
-- ==================================================

-- Basics
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.linebreak = true

-- Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Search settings
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Visual settings
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.showmatch = true
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.winblend = 0
vim.opt.lazyredraw = true
vim.opt.synmaxcol = 300
vim.opt.fillchars = { eob = " " }

-- Create undo directory if it doesn't exist
local undodir = vim.fn.expand("~/.vim/undodir")
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end

-- File handling
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")
vim.opt.updatetime = 300
vim.opt.timeoutlen = 500
vim.opt.ttimeoutlen = 0
vim.opt.autoread = true
vim.opt.autowrite = false

-- Behavior settings
vim.opt.hidden = true
vim.opt.errorbells = false
vim.opt.autochdir = false
vim.opt.iskeyword:append("-")
vim.opt.path:append("**")
vim.opt.selection = "exclusive"
vim.opt.mouse = ""
vim.opt.clipboard:append("unnamedplus")
vim.opt.modifiable = true
vim.opt.encoding = "UTF-8"

-- Performance improvements
vim.opt.redrawtime = 10000
vim.opt.maxmempattern = 20000

-- Cursor settings
vim.opt.guicursor = "n-v-c:block,i-ci-ve:block,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"

-- Folding settings
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldlevel = 99

-- Split behavior
vim.opt.splitbelow = true
vim.opt.splitright = true

-- ==================================================
-- KEYS
-- ==================================================

-- Key mappings
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Normal mode mappings
vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "Clear search highlights" })

-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Buffer navigation
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "Previous buffer" })

-- Resizing (edge-aware: moves the active split border in the pressed direction)
local function resize_win(dir)
  if vim.api.nvim_win_get_config(0).relative ~= "" then
    return
  end

  local cur = vim.fn.winnr()
  if dir == "h" or dir == "l" then
    local at_right = vim.fn.winnr("l") == cur
    if at_right and vim.fn.winnr("h") == cur then
      return
    end
    local grow = (dir == "l") ~= at_right
    vim.cmd("vertical resize " .. (grow and "+4" or "-4"))
  elseif dir == "j" or dir == "k" then
    local at_bottom = vim.fn.winnr("j") == cur
    if at_bottom and vim.fn.winnr("k") == cur then
      return
    end
    local grow = (dir == "j") ~= at_bottom
    vim.cmd("resize " .. (grow and "+2" or "-2"))
  end
end

vim.keymap.set({ "n", "t" }, "<A-H>", function() resize_win("h") end, { desc = "Resize window left" })
vim.keymap.set({ "n", "t" }, "<A-J>", function() resize_win("j") end, { desc = "Resize window down" })
vim.keymap.set({ "n", "t" }, "<A-K>", function() resize_win("k") end, { desc = "Resize window up" })
vim.keymap.set({ "n", "t" }, "<A-L>", function() resize_win("l") end, { desc = "Resize window right" })
vim.keymap.set({ "n", "t" }, "<A-=>", function() vim.cmd("wincmd =") end, { desc = "Equalize window sizes" })

vim.keymap.set("n", "<C-f>", ":lua MiniFiles.open()<cr>", { silent = true })

vim.keymap.set("n", "<A-h>", "<C-w>h")
vim.keymap.set("n", "<A-j>", "<C-w>j")
vim.keymap.set("n", "<A-k>", "<C-w>k")
vim.keymap.set("n", "<A-l>", "<C-w>l")

-- Resize-based window fullscreen toggle (<A-z>)
local tab_zoom = {} -- [tabpage] = { win = integer, restore_cmd = string, win_count = integer }
local zoom_augroup = vim.api.nvim_create_augroup("WinZoom", { clear = true })

local function list_normal_wins(tab)
  local wins = {}
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
    if vim.api.nvim_win_get_config(w).relative == "" then
      wins[#wins + 1] = w
    end
  end
  return wins
end

local function toggle_win_zoom()
  local cur_win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_config(cur_win).relative ~= "" then
    return
  end

  local tab = vim.api.nvim_get_current_tabpage()
  local wins = list_normal_wins(tab)
  if #wins <= 1 then
    tab_zoom[tab] = nil
    return
  end

  local was_term_mode = vim.api.nvim_get_mode().mode == "t"
  local state = tab_zoom[tab]

  if state and state.win == cur_win then
    tab_zoom[tab] = nil
    if #wins == state.win_count and state.restore_cmd and state.restore_cmd ~= "" then
      local ok = pcall(vim.cmd, state.restore_cmd)
      if not ok then
        vim.cmd("wincmd =")
      end
    else
      vim.cmd("wincmd =")
    end
    if vim.api.nvim_win_is_valid(cur_win) then
      vim.api.nvim_set_current_win(cur_win)
    end
  else
    if not state then
      tab_zoom[tab] = {
        win = cur_win,
        restore_cmd = vim.fn.winrestcmd(),
        win_count = #wins,
      }
    else
      state.win = cur_win
    end
    vim.cmd("wincmd |")
    vim.cmd("wincmd _")
  end

  if was_term_mode and vim.api.nvim_win_is_valid(cur_win) then
    if vim.bo[vim.api.nvim_win_get_buf(cur_win)].buftype == "terminal" then
      vim.cmd.startinsert()
    end
  end
end

vim.api.nvim_create_autocmd("TabClosed", {
  group = zoom_augroup,
  callback = function()
    local valid = {}
    for _, t in ipairs(vim.api.nvim_list_tabpages()) do
      valid[t] = true
    end
    for t in pairs(tab_zoom) do
      if not valid[t] then
        tab_zoom[t] = nil
      end
    end
  end,
})

vim.api.nvim_create_autocmd("WinClosed", {
  group = zoom_augroup,
  callback = function(ev)
    local closed_win = tonumber(ev.match)
    if not closed_win then
      return
    end
    for t, st in pairs(tab_zoom) do
      if st.win == closed_win then
        tab_zoom[t] = nil
      end
    end
  end,
})

vim.keymap.set({ "n", "t" }, "<A-z>", toggle_win_zoom, { desc = "Toggle window fullscreen" })

vim.keymap.set('n', 'S', '_V/{<C-m>%o', { silent = true })

vim.keymap.set('n', '<C-m>', '@m')
vim.keymap.set('v', '<C-m>', '"ky')
vim.keymap.set('n', '<leader><C-m>', '"kp')

vim.keymap.set('v', '<C-c>', ':s/')
vim.keymap.set('v', '<leader><C-c>', ':s/<C-r>0/')

vim.keymap.set('x', '<leader>p', "\"_dP")

vim.keymap.set({ 'n', 'v' }, '<leader>y', "\"+y")
vim.keymap.set('n', '<leader>Y', "\"+Y")

vim.keymap.set({ 'n', 'v' }, '<leader>d', "\"_d")

vim.keymap.set("n", "j", [[v:count > 5 ? "m'" . v:count . 'j' : 'gj']], { noremap = true, expr = true })
vim.keymap.set("n", "k", [[v:count > 5 ? "m'" . v:count . 'k' : 'gk']], { noremap = true, expr = true })

vim.keymap.set("n", "<leader>pa", function()
	local path = vim.fn.expand("%:p")
	vim.fn.setreg("+", path)
	print("file:", path)
end)

-- ==================================================
-- TABS
-- ==================================================

-- Tab display settings
vim.opt.showtabline = 1  -- Show tabline when multiple tabs are open (0=never, 1=multiple, 2=always)

-- Custom tabline: show active process name for <A-t> terminals, default-style label otherwise
local term_tabline_timer = nil
local term_tabline_augroup = vim.api.nvim_create_augroup("TermTabline", { clear = true })

local function read_proc_file(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local data = f:read("*a")
  f:close()
  return data
end

local function get_term_proc_name(shell_pid)
  if not shell_pid or shell_pid <= 0 then
    return nil
  end
  local stat = read_proc_file("/proc/" .. shell_pid .. "/stat")
  if stat then
    local rest = stat:match(".*%) (.+)")
    if rest then
      local tpgid = tonumber(rest:match("^%S+%s+%S+%s+%S+%s+%S+%s+%S+%s+(%-?%d+)"))
      if tpgid and tpgid > 0 then
        local comm = read_proc_file("/proc/" .. tpgid .. "/comm")
        if comm then
          local name = vim.trim(comm)
          if name ~= "" then
            return name
          end
        end
      end
    end
  end
  local fallback = read_proc_file("/proc/" .. shell_pid .. "/comm")
  if fallback then
    local name = vim.trim(fallback)
    if name ~= "" then
      return name
    end
  end
  return nil
end

local function stop_term_tabline_timer()
  if term_tabline_timer then
    term_tabline_timer:stop()
  end
end

local function refresh_term_tabline(force_redraw)
  local tabs = vim.api.nvim_list_tabpages()
  local has_active_term = false
  local changed = false

  for _, tab in ipairs(tabs) do
    local win = vim.api.nvim_tabpage_get_win(tab)
    if vim.api.nvim_win_is_valid(win) then
      local buf = vim.api.nvim_win_get_buf(win)
      local pid = vim.b[buf].win_term_pid
      if pid then
        has_active_term = true
        local proc = get_term_proc_name(pid)
        if proc and proc ~= vim.b[buf].win_term_proc then
          vim.b[buf].win_term_proc = proc
          changed = true
        end
      end
    end
  end

  if has_active_term then
    if not term_tabline_timer then
      term_tabline_timer = vim.uv.new_timer()
    end
    if term_tabline_timer and not term_tabline_timer:is_active() then
      term_tabline_timer:start(5000, 5000, vim.schedule_wrap(function()
        refresh_term_tabline(false)
      end))
    end
  else
    stop_term_tabline_timer()
  end

  if (changed or force_redraw) and #tabs > 1 then
    vim.cmd.redrawtabline()
  end
end

local function truncate_tab_label(str, max_len)
  if max_len <= 0 then
    return ""
  end
  if vim.fn.strchars(str) <= max_len then
    return str
  end
  if max_len == 1 then
    return "…"
  end
  return vim.fn.strcharpart(str, 0, max_len - 1) .. "…"
end

function _G.custom_tabline()
  local tabs = vim.api.nvim_list_tabpages()
  local cur_tab = vim.api.nvim_get_current_tabpage()
  local max_label_len = 10
  local parts = {}

  for i, tab in ipairs(tabs) do
    local hl = (tab == cur_tab) and "%#TabLineSel#" or "%#TabLine#"
    local win = vim.api.nvim_tabpage_get_win(tab)
    local buf = vim.api.nvim_win_get_buf(win)
    local label
    local suffix = ""

    local pid = vim.b[buf].win_term_pid
    if pid then
      label = vim.b[buf].win_term_proc or get_term_proc_name(pid) or vim.fn.fnamemodify(vim.o.shell, ":t")
    else
      local name = vim.api.nvim_buf_get_name(buf)
      if name == "" then
        label = "[No Name]"
      else
        local tail = vim.fn.fnamemodify(name, ":t")
        label = tail ~= "" and tail or name
      end
      if vim.bo[buf].modified then
        suffix = " +"
      end
    end

    label = truncate_tab_label(label, max_label_len - #suffix) .. suffix
    label = label:gsub("%%", "%%%%")
    parts[#parts + 1] = string.format("%s%%%dT %d %s %%T", hl, i, i, label)
  end

  parts[#parts + 1] = "%#TabLineFill#"
  return table.concat(parts)
end

vim.o.tabline = "%!v:lua.custom_tabline()"

vim.api.nvim_create_autocmd({ "TabEnter", "WinEnter", "BufEnter" }, {
  group = term_tabline_augroup,
  callback = function()
    refresh_term_tabline(false)
  end,
})

-- Alternative navigation (more intuitive)
vim.keymap.set('n', '<C-t>', ':tabnew<CR>', { desc = 'New tab' })

vim.keymap.set("n", "<A-1>", "1gt")
vim.keymap.set("n", "<A-2>", "2gt")
vim.keymap.set("n", "<A-3>", "3gt")
vim.keymap.set("n", "<A-4>", "4gt")
vim.keymap.set("n", "<A-5>", "5gt")
vim.keymap.set("n", "<A-6>", "6gt")
vim.keymap.set("n", "<A-7>", "7gt")
vim.keymap.set("n", "<A-8>", "8gt")
vim.keymap.set("n", "<A-9>", "9gt")

-- ==================================================
-- BUFFERS
-- ==================================================

-- Close all buffers except current
vim.keymap.set('n', '<leader>bo', ':%bd|e#|bd#<CR>', { desc = 'Close all buffers except current' })

-- ==================================================
-- AUTOCMDS
-- ==================================================

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- return to last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	desc = "Restore last cursor position",
	callback = function()
		if vim.o.diff then -- except in diff mode
			return
		end

		local last_pos = vim.api.nvim_buf_get_mark(0, '"') -- {line, col}
		local last_line = vim.api.nvim_buf_line_count(0)

		local row = last_pos[1]
		if row < 1 or row > last_line then
			return
		end

		pcall(vim.api.nvim_win_set_cursor, 0, last_pos)
	end,
})

-- wrap, linebreak and spellcheck on markdown and text files
vim.api.nvim_create_autocmd("FileType", {
	group = augroup,
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.spell = true
	end,
})

-- ==================================================
-- PLUGINS
-- ==================================================

vim.pack.add({
	"https://github.com/echasnovski/mini.nvim",
	"https://github.com/ibhagwan/fzf-lua",
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
})

-- ==================================================
-- FZF-LUA PLUGIN
-- ==================================================

local fzflua = require("fzf-lua")

vim.keymap.set("n", "<C-n>", fzflua.files)
vim.keymap.set("n", "<leader>fs", fzflua.resume)
vim.keymap.set("n", "<leader>fb", fzflua.buffers)
vim.keymap.set("n", "<leader>fl", fzflua.blines)
vim.keymap.set("n", "<leader>fg", fzflua.live_grep)

vim.keymap.set('n', '<leader>fcp', fzflua.complete_path)
vim.keymap.set('n', '<leader>fcf', fzflua.complete_file)

-- ==================================================
-- MINI.NVIM PLUGIN
-- ==================================================

require("mini.align").setup({})
require("mini.comment").setup({})
require("mini.completion").setup({})
require("mini.surround").setup({})
require("mini.pairs").setup({})
local function is_text_file(fs_entry)
  if fs_entry.fs_type ~= "file" then
    return true
  end

  local stat = vim.uv.fs_stat(fs_entry.path)
  if not stat or stat.type ~= "file" then
    return false
  end
  if stat.size == 0 then
    return true
  end

  local f = io.open(fs_entry.path, "rb")
  if not f then
    return false
  end
  local chunk = f:read(4096)
  f:close()

  return not (chunk and chunk:find("\0", 1, true))
end

require("mini.files").setup({
  content = {
    filter = is_text_file,
  },
})

local mini_files_show_all = false
local mini_files_augroup = vim.api.nvim_create_augroup("MiniFilesFilterToggle", { clear = true })

vim.api.nvim_create_autocmd("User", {
  group = mini_files_augroup,
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    vim.keymap.set("n", "g.", function()
      mini_files_show_all = not mini_files_show_all
      local filter = mini_files_show_all and function() return true end or is_text_file
      MiniFiles.refresh({ content = { filter = filter } })
    end, { buffer = args.data.buf_id, desc = "Toggle non-text files" })
  end,
})

vim.api.nvim_create_autocmd("User", {
  group = mini_files_augroup,
  pattern = "MiniFilesExplorerClose",
  callback = function()
    mini_files_show_all = false
  end,
})

-- ==================================================
-- LSP CONFIGURATION
-- ==================================================

require("mason").setup({})

local diagnostic_signs = {
	Error = "\u{f057} ",
	Warn = "\u{f071} ",
	Hint = "\u{ea61}",
	Info = "\u{f05a}",
}

vim.diagnostic.config({
	virtual_text = { prefix = "●", spacing = 4 },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
			[vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
			[vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
			[vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
		},
	},
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		border = "rounded",
		source = true,
		header = "",
		prefix = "",
		focusable = false,
		style = "minimal",
	},
})

do
	local orig = vim.lsp.util.open_floating_preview
	function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
		opts = opts or {}
		opts.border = opts.border or "rounded"
		return orig(contents, syntax, opts, ...)
	end
end

local function lsp_on_attach(ev)
	local client = vim.lsp.get_client_by_id(ev.data.client_id)
	if not client then
		return
	end

	local bufnr = ev.buf
	local opts = { noremap = true, silent = true, buffer = bufnr }

	vim.keymap.set("n", "<leader>gd", function()
		require("fzf-lua").lsp_definitions({ jump1 = true })
	end, opts)

	vim.keymap.set("n", "<leader>gD", vim.lsp.buf.definition, opts)

	vim.keymap.set("n", "<leader>gS", function()
		vim.cmd("vsplit")
		vim.lsp.buf.definition()
	end, opts)

	vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
	vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

	vim.keymap.set("n", "<leader>D", function()
		vim.diagnostic.open_float({ scope = "line" })
	end, opts)
	vim.keymap.set("n", "<leader>d", function()
		vim.diagnostic.open_float({ scope = "cursor" })
	end, opts)
	vim.keymap.set("n", "<leader>nd", function()
		vim.diagnostic.jump({ count = 1 })
	end, opts)

	vim.keymap.set("n", "<leader>pd", function()
		vim.diagnostic.jump({ count = -1 })
	end, opts)

	vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

	vim.keymap.set("n", "<leader>fr", function()
		require("fzf-lua").lsp_references()
	end, opts)
	vim.keymap.set("n", "<leader>ft", function()
		require("fzf-lua").lsp_typedefs()
	end, opts)
	vim.keymap.set("n", "<leader>fs", function()
		require("fzf-lua").lsp_document_symbols()
	end, opts)
	vim.keymap.set("n", "<leader>fw", function()
		require("fzf-lua").lsp_workspace_symbols()
	end, opts)
	vim.keymap.set("n", "<leader>fi", function()
		require("fzf-lua").lsp_implementations()
	end, opts)

	if client:supports_method("textDocument/codeAction", bufnr) then
		vim.keymap.set("n", "<leader>oi", function()
			vim.lsp.buf.code_action({
				context = { only = { "source.organizeImports" }, diagnostics = {} },
				apply = true,
				bufnr = bufnr,
			})
			vim.defer_fn(function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end, 50)
		end, opts)
	end
end

vim.api.nvim_create_autocmd("LspAttach", { group = augroup, callback = lsp_on_attach })

vim.keymap.set("n", "<leader>q", function()
	vim.diagnostic.setloclist({ open = true })
end, { desc = "Open diagnostic list" })
vim.keymap.set("n", "<leader>dl", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
			telemetry = { enable = false },
		},
	},
})
vim.lsp.config("pyright", {})
vim.lsp.config("bashls", {})
vim.lsp.config("ts_ls", {})
vim.lsp.config("gopls", {})
vim.lsp.config("clangd", {})
vim.lsp.config("omnisharp", {})

vim.lsp.enable({
	"lua_ls",
	"pyright",
	"bashls",
	"ts_ls",
	"gopls",
	"clangd",
	"omnisharp",
	"efm",
})

-- ==================================================
-- TERMINAL
-- ==================================================

-- Per-window persistent terminal toggle (<A-t>)
local win_terms = {} -- [winid] = { term_buf = integer?, prev_buf = integer? }
local term_augroup = vim.api.nvim_create_augroup("WinTermToggle", { clear = true })

local function get_fallback_buf(exclude_buf)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if buf ~= exclude_buf and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
      return buf
    end
  end
  return vim.api.nvim_create_buf(true, false)
end

local function restore_prev_buf(win, state, closed_term_buf)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  if vim.api.nvim_win_get_buf(win) ~= closed_term_buf then
    return
  end

  local target = state and state.prev_buf
  if not (target and vim.api.nvim_buf_is_valid(target)) then
    target = get_fallback_buf(closed_term_buf)
  end

  if vim.api.nvim_get_current_win() == win and vim.fn.mode() == "t" then
    vim.cmd.stopinsert()
  end
  vim.api.nvim_win_set_buf(win, target)
  refresh_term_tabline(true)
end

local function toggle_win_term()
  local win = vim.api.nvim_get_current_win()
  local cur_buf = vim.api.nvim_win_get_buf(win)
  local state = win_terms[win]

  -- Currently viewing this window's terminal (Normal or Terminal mode) -> swap back to code
  if state and state.term_buf == cur_buf then
    restore_prev_buf(win, state, cur_buf)
    return
  end

  -- Ignore special buffers (quickfix, help, sidebars, other terminals, etc.)
  if vim.bo[cur_buf].buftype ~= "" then
    return
  end

  if not state then
    state = {}
    win_terms[win] = state
  end
  state.prev_buf = cur_buf

  -- Reuse existing live terminal for this window
  if state.term_buf and vim.api.nvim_buf_is_valid(state.term_buf) then
    vim.api.nvim_win_set_buf(win, state.term_buf)
    refresh_term_tabline(true)
    vim.cmd.startinsert()
    return
  end

  -- Start a new terminal in the current file's directory (or cwd if unnamed)
  local file = vim.api.nvim_buf_get_name(cur_buf)
  local dir = file ~= "" and vim.fs.dirname(file) or nil
  local cwd = (dir and vim.fn.isdirectory(dir) == 1) and dir or vim.fn.getcwd()

  local term_buf = vim.api.nvim_create_buf(false, false)
  vim.bo[term_buf].buflisted = false
  vim.bo[term_buf].bufhidden = "hide"

  vim.keymap.set("t", "<A-n>", [[<C-\><C-n>]], { buffer = term_buf, desc = "Terminal normal mode" })

  state.term_buf = term_buf
  vim.api.nvim_win_set_buf(win, term_buf)

  local job_id = vim.fn.jobstart(vim.o.shell, {
    term = true,
    cwd = cwd,
    on_exit = function()
      vim.schedule(function()
        local st = win_terms[win]
        if st and st.term_buf == term_buf then
          st.term_buf = nil
        end
        restore_prev_buf(win, st, term_buf)
        if vim.api.nvim_buf_is_valid(term_buf) then
          vim.api.nvim_buf_delete(term_buf, { force = true })
        end
      end)
    end,
  })

  if job_id <= 0 then
    state.term_buf = nil
    restore_prev_buf(win, state, term_buf)
    if vim.api.nvim_buf_is_valid(term_buf) then
      vim.api.nvim_buf_delete(term_buf, { force = true })
    end
    vim.notify("Failed to start terminal", vim.log.levels.ERROR)
    return
  end

  local ok, pid = pcall(vim.fn.jobpid, job_id)
  if ok and pid and pid > 0 then
    vim.b[term_buf].win_term_pid = pid
    vim.b[term_buf].win_term_proc = get_term_proc_name(pid) or vim.fn.fnamemodify(vim.o.shell, ":t")
  end
  refresh_term_tabline(true)

  vim.cmd.startinsert()
end

vim.api.nvim_create_autocmd("WinClosed", {
  group = term_augroup,
  callback = function(ev)
    local win = tonumber(ev.match)
    local st = win and win_terms[win]
    if not st then
      return
    end
    win_terms[win] = nil

    if st.term_buf and vim.api.nvim_buf_is_valid(st.term_buf) then
      local term_buf = st.term_buf
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(term_buf) then
          vim.api.nvim_buf_delete(term_buf, { force = true })
        end
      end)
    end
  end,
})

vim.keymap.set({ "n", "t" }, "<A-t>", toggle_win_term, { desc = "Toggle window terminal" })

