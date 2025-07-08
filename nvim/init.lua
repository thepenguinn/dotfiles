-- init.lua

-- SETTING UP LEADER --

vim.g.mapleader = " "

vim.g.maplocalleader = " "

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

vim.g.tex_flavor = "latex"

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

vim.keymap.set("i", "<C-f>", "<C-g>u<Esc>[s1z=`]a<C-g>U", { noremap = true })

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

local test_fn = function ()

    local calendar = require("neorg").modules.get_module("core.ui.calendar")

    if not calendar then
        return
    end

    calendar.select_date({
        callback = function(arg)
            print(vim.inspect(arg))
        end
    })
    -- print(vim.inspect(calendar))

end

require("norg")

vim.api.nvim_create_autocmd({"BufEnter"}, {
    pattern = {"*.norg", "*.tex"},
    callback = function()
        vim.keymap.set("n", "<leader>tt", test_fn)
        vim.keymap.set("n", "<leader>tas", require("norg").add_todo_schedule)
        vim.keymap.set("n", "<leader>og", require("pyexec").exec_at_cursor)
        vim.api.nvim_create_user_command("PyExecAll", require("pyexec").exec_all, {})
    end,
    group = pyexec_group,
})

-- vim.api.nvim_create_autocmd({"BufLeave"}, {
--     pattern = {"*.norg", "*.tex"},
--     callback = function()
--         vim.keymap.del("n", "<leader>og")
--         vim.api.nvim_del_user_command("PyExecAll")
--     end,
--     group = pyexec_group,
-- })

local tex_notes_group = vim.api.nvim_create_augroup("TexNotesGroup", {clear = true})

require("texnotes")

vim.api.nvim_create_autocmd({"BufEnter"}, {
    pattern = {"*.tex"},
    callback = function()
        vim.keymap.set("n", "<cr>", require("texnotes").jump)
        vim.keymap.set("n", "<leader>tm", require("texnotes").view_binary)
        vim.keymap.set("n", "<leader>tn", require("texnotes").new_tikzpic)
        vim.keymap.set("n", "<leader>tb", require("texnotes").build_and_view_tikzpic)
        -- vim.api.nvim_create_user_command("Tex", require("texnotes").exec_all, {})
    end,
    group = tex_notes_group,
})

vim.api.nvim_create_autocmd({"BufLeave"}, {
    pattern = {"*.tex"},
    callback = function()
        vim.keymap.del("n", "<cr>")
        vim.keymap.del("n", "<leader>tm")
        vim.keymap.del("n", "<leader>tn")
        vim.keymap.del("n", "<leader>tb")
    end,
    group = tex_notes_group,
})

-- for openscad

local openscad_group = vim.api.nvim_create_augroup("OpenSCadGroup", {clear = true})

vim.api.nvim_create_autocmd({"BufEnter"}, {
    pattern = {"*.scad"},
    callback = function()
        vim.cmd("set commentstring=/*%s*/")
    end,
    group = openscad_group,
})

vim.api.nvim_create_autocmd({"BufLeave"}, {
    pattern = {"*.scad"},
    callback = function()
        vim.cmd("set commentstring=")
    end,
    group = openscad_group,
})

--
--
