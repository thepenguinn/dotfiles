return {
    {
        "Pocco81/true-zen.nvim",
        config = function()
            require("true-zen").setup {
                -- configurations per mode
                modes = {
                    ataraxis = {
                        -- if `dark` then dim the padding windows, otherwise if it's `light` it
                        -- 'll brighten said windows
                        shade = "dark",
                        -- percentage by which padding windows should be dimmed/brightened.
                        -- Must be a number between 0 and 1. Set to 0 to keep the same
                        -- background color
                        backdrop = 0,
                        minimum_writing_area = { -- minimum size of main window
                            width = 90,
                            height = 44,
                        },
                        quit_untoggles = true, -- type :q or :qa to quit Ataraxis mode
                        padding = { -- padding windows
                            left = 52,
                            right = 52,
                            top = 0,
                            bottom = 0,
                        },
                        callbacks = { -- run functions when opening/closing Ataraxis mode
                            open_pre = nil,
                            open_pos = nil,
                            close_pre = nil,
                            close_pos = nil
                        },
                    },
                    minimalist = {
                        -- save current options from any window except ones displaying these kinds of buffers
                        ignored_buf_types = { "nofile" },
                        -- options to be disabled when entering Minimalist mode
                        options = {
                            number = false,
                            relativenumber = false,
                            showtabline = 0,
                            signcolumn = "no",
                            statusline = "",
                            cmdheight = 1,
                            laststatus = 0,
                            showcmd = false,
                            showmode = false,
                            ruler = false,
                            numberwidth = 1
                        },
                        -- run functions when opening/closing Minimalist mode
                        callbacks = {
                            open_pre = nil,
                            open_pos = nil,
                            close_pre = nil,
                            close_pos = nil
                        },
                    },
                },
                integrations = {
                    tmux = false, -- hide tmux status bar in (minimalist, ataraxis)
                    kitty = { -- increment font size in Kitty. Note: you must set `allow_remote_control socket-only` and `listen_on unix:/tmp/kitty` in your personal config (ataraxis)
                        enabled = false,
                        font = "+3"
                    },
                    twilight = false, -- enable twilight (ataraxis)
                    lualine = true -- hide nvim-lualine (ataraxis)
                },
            }
        end,
    }
}
