return {
    {
        "nvim-neorg/neorg",
        build = ":Neorg sync-parsers",
        -- tag = "*",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require('neorg').setup {
                load = {
                    ["core.defaults"] = {}, -- Loads default behaviour
                    ["core..concealer"] = {
                        config = {
                            icon_preset = "basic",
                        },
                    }, -- Adds pretty icons to your documents
                    ["core.itero"] = {},
                    ["core.promo"] = {},
                    ["core.export"] = {},
                    ["core.esupports.metagen"] = {
                        -- config = {
                        --     type = "auto"
                        -- },
                    },
                    ["core.export.markdown"] = {
                        config = {
                            extensions = "all",
                        },
                    },
                    ["core.highlights"] = {
                        config = {
                            todo_items_match_color = "all",
                        },
                    },
                    ["core.looking-glass"] = {},
                    ["core.dirman"] = { -- Manages Neorg workspaces
                        config = {
                            workspaces = {
                                notes = "~/notes",
                            },
                        },
                    },
                    -- ["external.notes"] = {
                    --     config = {
                    --         lol = test,
                    --     },
                    -- },
                },
            }
        end,
        run = ":Neorg sync-parsers",
        -- requires = {
        -- 	'nvim-lua/notes',
        -- 	'nvim-lua/plenary.nvim',
        -- },
    },
}
