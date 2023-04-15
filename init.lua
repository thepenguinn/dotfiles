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
--vim.opt.listchars="tab:\|\ "
--vim.opt.list=true
vim.opt.termguicolors=true

vim.cmd('colorscheme catppuccin')
vim.cmd(':command GenNoteHead silent r !get-note-heading %:p')
vim.cmd(":command LuaLineHide silent :lua require('lualine').hide()")

--noremap <leader><leader> /<++><return>c4l
--inoremap <leader><leader> <esc>/<++><return>c4l

--require('feline').setup()
require('lualine').setup{
	options = { theme = 'auto' }
}

-- Testing
-- require('daniel')

--require('lualine').hide({
--	place = {'statusline', 'tabline', 'winbar'}, -- The segment this change applies to.
--	unhide = false,  -- whether to re-enable lualine again/
--})


require 'nvim-treesitter.configs'.setup {
	ensure_installed = { 'c', 'norg', 'bash', 'lua' },
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	}
	--indent = {
		--	enable = false,
		--}
	}

--lua require('colorizer').setup() something is wrong here
require('packer').startup()
require('plugins')
--lua require'colorizer'.setup()

--plugins blah
require('colorizer')




