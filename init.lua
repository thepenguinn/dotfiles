--     _       _ _     _
--   (_)_ __ (_) |_  | |_   _  __ _
--  | | '_ \| | __| | | | | |/ _` |
-- | | | | | | |_ _| | |_| | (_| |
--|_|_| |_|_|\__(_)_|\__,_|\__,_|
--
--

vim.g.mapleader = " "
vim.opt.rnu=true
vim.opt.nu=true
vim.opt.scrolloff=6
vim.opt.tabstop=4
vim.opt.softtabstop=4
vim.opt.shiftwidth=4
vim.opt.laststatus=3
vim.opt.expandtab=true
--vim.opt.listchars="tab:\|\ "
--vim.opt.list=true
vim.opt.termguicolors=true

vim.cmd('colorscheme catppuccin')
vim.api.nvim_set_hl(0, "Normal", {bg = "none"})
vim.api.nvim_set_hl(0, "NormalFloat", {bg = "none"})
vim.cmd(":command LuaLineHide silent :lua require('lualine').hide()")
vim.api.nvim_create_user_command(
	'GenNoteHead',
	function () require('getnotehead').inject() end,
	{ nargs = 0 }
)

vim.api.nvim_create_user_command(
	'GenNoteTemplate',
	function () require('getnotetemplate').inject() end,
	{ nargs = 0 }
)

-- Testing --

-- require('noteconverter').testing()

vim.api.nvim_create_user_command(
	'NotesTesting',
	function () require('neorg.modules.external.notes.module').public.ok() end,
	{ nargs = 0 }
)

vim.api.nvim_create_user_command(
	'AddNode',
	function () require('neorg.modules.external.notes.module').public.read_config() end,
	{ nargs = 0 }
)
-- Keymaps --

-- Harpoon --
vim.keymap.set("n", "<leader>hn", function () require("harpoon.mark").add_file() end)
vim.keymap.set("n", "<leader>hq", function () require("harpoon.ui").toggle_quick_menu() end)
vim.keymap.set("n", "<leader>hf", function () require("harpoon.ui").nav_file(1) end)
vim.keymap.set("n", "<leader>hd", function () require("harpoon.ui").nav_file(2) end)
vim.keymap.set("n", "<leader>hs", function () require("harpoon.ui").nav_file(3) end)
vim.keymap.set("n", "<leader>ha", function () require("harpoon.ui").nav_file(4) end)

-- colorizer --
require('colorizer').setup()

-- clean this --
vim.api.nvim_create_user_command(
	'SpaceJumpInsertEnable',
	function () vim.cmd('inoremap <leader><leader> <esc>/<++><return>c4l') end,
	{ nargs = 0 }
)

vim.api.nvim_create_user_command(
	'SpaceJumpInsertDisable',
	function () vim.cmd('iunmap <leader><leader>') end,
	{ nargs = 0 }
)

vim.cmd('noremap <leader><leader> /<++><return>c4l')
-- vim.cmd('inoremap <leader><leader> <esc>/<++><return>c4l')

--require('feline').setup()
require('lualine').setup{
	options = { theme = 'auto' }
}

--require('lualine').hide({
--	place = {'statusline', 'tabline', 'winbar'}, -- The segment this change applies to.
--	unhide = false,  -- whether to re-enable lualine again/
--})


require 'nvim-treesitter.configs'.setup {
	ensure_installed = { 'c', 'kotlin', 'markdown', 'python', 'java', 'cpp', 'norg', 'bash', 'lua', 'make', 'latex' },
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = true,
	},
	indent = {
		enable = true,
	}
}

--lua require('colorizer').setup() something is wrong here
require('packer').startup()
require('plugins')
--lua require'colorizer'.setup()

--plugins blah
require('colorizer')
