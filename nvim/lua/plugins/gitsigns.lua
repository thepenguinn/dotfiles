return {
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require('gitsigns').setup {
                signs = {
                    -- delete       = { text = '_' },
                    --
                    --
                    -- ─	━	│	┃	┄	┅	┆	┇	┈	┉	┊	┋	┌	┍	┎	┏
                    -- U+251x	┐	┑	┒	┓	└	┕	┖	┗	┘	┙	┚	┛	├	┝	┞	┟
                    -- U+252x	┠	┡	┢	┣	┤	┥	┦	┧	┨	┩	┪	┫	┬	┭	┮	┯
                    -- U+253x	┰	┱	┲	┳	┴	┵	┶	┷	┸	┹	┺	┻	┼	┽	┾	┿
                    -- U+254x	╀	╁	╂	╃	╄	╅	╆	╇	╈	╉	╊	╋	╌	╍	╎	╏
                    -- U+255x	═	║	╒	╓	╔	╕	╖	╗	╘	╙	╚	╛	╜	╝	╞	╟
                    -- U+256x	╠	╡	╢	╣	╤	╥	╦	╧	╨	╩	╪	╫	╬	╭	╮	╯
                    -- U+257x	╰	╱	╲	╳	╴	╵	╶	╷	╸	╹	╺	╻	╼	╽	╾	╿
                    -- ▲
                    --U+25BC	▼
                    --	White down-pointing triangle
                    -- U+25BE	▾	Black down-pointing small triangle
                    -- U+25BF	▿	White down-pointing small
                    --U+25C6	◆	Black diamond
                    -- U+25C7	◇	White diamond
                    -- U+25C8	◈	White diamond containing small black diamond
                    -- U+25C9	◉	Fisheye
                    -- U+25CA	◊	Lozenge
                    -- U+25CB	○	White circle
                    -- U+25CC	◌	Dotted circle
                    -- U+25CD	◍	Circle with vertical fill
                    -- U+25CE	◎	Bullseye
                    -- U+25CF	●	Black
                    add          = { text = '┃' },
                    change       = { text = '┃' },
                    -- delete       = { text = '╻' },
                    delete       = { text = '▼' },
                    topdelete    = { text = '●' },
                    -- changedelete = { text = '╹' },
                    changedelete = { text = '▲' },
                    untracked    = { text = '┇' },
                },
                signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
                numhl      = true, -- Toggle with `:Gitsigns toggle_numhl`
                linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
                word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
                watch_gitdir = {
                    follow_files = true
                },
                auto_attach = true,
                attach_to_untracked = true,
                current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
                current_line_blame_opts = {
                    virt_text = true,
                    virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
                    delay = 1000,
                    ignore_whitespace = false,
                    virt_text_priority = 100,
                },
                current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
                sign_priority = 6,
                update_debounce = 100,
                status_formatter = nil, -- Use default
                max_file_length = 40000, -- Disable if file is longer than this (in lines)
                preview_config = {
                    -- Options passed to nvim_open_win
                    border = 'single',
                    style = 'minimal',
                    relative = 'cursor',
                    row = 0,
                    col = 1
                },
            }
        end
    },
}
