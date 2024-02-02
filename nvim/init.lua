-- init.lua

-- SETTING UP LEADER --

vim.g.mapleader = " "

-- GLOBAL SETTINGS --

vim.opt.rnu = true
vim.opt.nu = true
vim.opt.scrolloff = 6

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.laststatus = 3
vim.opt.expandtab = true

vim.opt.termguicolors = true

-- SETTING UP LAZY --

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup( "plugins" )

-- TODO: FIND A WAY TO PROPERLY LOAD COLORIZER --
require('colorizer')

-- TODO: SEPERATE KEYBINDINGS TO SOME OTHER FILE --
vim.cmd('noremap <leader><leader> /<++><return>c4l')
