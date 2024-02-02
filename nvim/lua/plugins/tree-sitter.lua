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
                },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = true,
                },
                indent = {
                    enable = true,
                }
            }
        end
    }
}
