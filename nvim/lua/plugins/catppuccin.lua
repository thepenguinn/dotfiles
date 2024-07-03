return {
    {
        "catppuccin/nvim", as = "catppuccin",
        -- TODO: move this somewhere else
        config = function ()
            vim.cmd("colorscheme  catppuccin-mocha")
        end,
    }
}
