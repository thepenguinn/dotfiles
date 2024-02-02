local function config()
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>if', builtin.find_files, {})
    vim.keymap.set('n', '<leader>ig', builtin.live_grep, {})
    vim.keymap.set('n', '<leader>ib', builtin.buffers, {})
    vim.keymap.set('n', '<leader>ih', builtin.help_tags, {})
end

return {
    'nvim-telescope/telescope.nvim', tag = '0.1.5',
    -- or                              , branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = config
}
