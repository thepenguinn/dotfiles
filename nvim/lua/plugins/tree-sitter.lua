return {
    "nvim-treesitter/nvim-treesitter",
    "nvim-treesitter/playground",
    {
        "nvim-treesitter/nvim-treesitter",
        config = function()
            require 'nvim-treesitter.configs'.setup {
                ensure_installed = { 'c', 'kotlin', 'markdown',
                    'python', 'java', 'cpp', 'norg', 'bash',
                    'lua', 'make', 'latex', 'verilog', 'scheme',
                    'asm', 'cmake', 'tcl', 'matlab', 'rust', 'html',
                    'xml', 'groovy', 'markdown_inline',
                },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = true,
                },
                indent = {
                    enable = true,
                }
            }
            -- Generic asm parser for tree-sitter
            require('nvim-treesitter.parsers').get_parser_configs().asm = {
                install_info = {
                    url = 'https://github.com/thepenguinn/tree-sitter-mc51.git',
                    files = { 'src/parser.c' },
                    branch = 'main',
                },
            }

            local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
            parser_config.openscad = {
                install_info = {
                    url = "https://github.com/bollian/tree-sitter-openscad", -- local path or git repo
                    files = {"src/parser.c"}, -- note that some parsers also require src/scanner.c or src/scanner.cc
                    -- optional entries:
                    branch = "master", -- default branch in case of git repo if different from master
                    generate_requires_npm = false, -- if stand-alone parser without npm dependencies
                    requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
                },
                filetype = "scad", -- if filetype does not match the parser name
            }

        end
    }
}
