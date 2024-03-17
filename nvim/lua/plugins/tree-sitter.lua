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
                    'asm',
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
                    url = 'https://github.com/rush-rs/tree-sitter-asm.git',
                    files = { 'src/parser.c' },
                    branch = 'main',
                },
            }
        end
    }
}
