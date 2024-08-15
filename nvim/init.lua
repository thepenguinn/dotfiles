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

vim.opt.inccommand = "split"

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
vim.keymap.set('n', '<leader><leader>', '/<++><return>c4l', { noremap = true })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { noremap = true })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { noremap = true })
vim.keymap.set('v', '<leader>p', '\"_dP', nil)

vim.keymap.set("x", "<C-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("x", "<C-k>", ":m '<-2<CR>gv=gv")

-- REMOVE THIS --

vim.api.nvim_create_user_command("W", function()

    local parent_dir = vim.api.nvim_buf_get_name(0)

    if parent_dir ~= nil and parent_dir ~= "" then
        parent_dir = string.gsub(parent_dir, "/[^/]+$", "")

        vim.fn.mkdir(parent_dir, "p")
    end

    vim.cmd("w")

end, {})

-- REMOVE THIS FROM HERE
--
-- SLIDES

local slides_group = vim.api.nvim_create_augroup("SlidesGroup", {clear = true})

require("slides")

vim.api.nvim_create_autocmd({"BufEnter"}, {
    pattern = {"*.md"},
    callback = function()
        vim.keymap.set("n", "<leader>og", require("slides").create_graph)
        vim.api.nvim_create_user_command("ExportGraph", require("slides").export_graph, {})
    end,
    group = slides_group,
})

vim.api.nvim_create_autocmd({"BufLeave"}, {
    pattern = {"*.md"},
    callback = function()
        vim.keymap.del("n", "<leader>og")
        vim.api.nvim_del_user_command("ExportGraph")
    end,
    group = slides_group,
})

-- PYEXEC

local pyexec_group = vim.api.nvim_create_augroup("PyExecGroup", {clear = true})

require("pyexec")

vim.api.nvim_create_autocmd({"BufEnter"}, {
    pattern = {"*.norg"},
    callback = function()
        vim.keymap.set("n", "<leader>og", require("pyexec").exec_at_cursor)
        vim.api.nvim_create_user_command("PyexecAall", require("pyexec").exec_all, {})
    end,
    group = pyexec_group,
})

vim.api.nvim_create_autocmd({"BufLeave"}, {
    pattern = {"*.norg"},
    callback = function()
        vim.keymap.del("n", "<leader>og")
        vim.api.nvim_del_user_command("PyexecAall")
    end,
    group = pyexec_group,
})
--
--
