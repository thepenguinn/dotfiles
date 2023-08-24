-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
-- vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
	--  Packer can manage itself
	use 'norcalli/nvim-colorizer.lua'
	use 'wbthomason/packer.nvim'
	use 'nvim-lua/plenary.nvim'
	use 'ThePrimeagen/harpoon'
	use 'nvim-treesitter/nvim-treesitter'
	use({
		"cappyzawa/trim.nvim",
		config = function()
			require("trim").setup({})
		end
	})
	use({
		"Pocco81/true-zen.nvim",
		config = function()
			require("true-zen").setup {
				-- your config goes here
				-- or just leave it empty :)
			}
		end,
	})
	use {
		'anuvyklack/pretty-fold.nvim',
		config = function()
			require('pretty-fold').setup()
		end
	}
	use { "catppuccin/nvim", as = "catppuccin" }
	use {
		'nvim-lualine/lualine.nvim',
		requires = { 'kyazdani42/nvim-web-devicons', opt = true }
	}
	--use {
	--	"folke/zen-mode.nvim",
	--	config = function()
	--		require("zen-mode").setup {
	--			-- your configuration comes here
	--			-- or leave it empty to use the default settings
	--			-- refer to the configuration section below
	--		}
	--	end
	--}
	use {
		"nvim-neorg/neorg",
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
				},
			}
		end,
		--run = ":Neorg sync-parsers",
		requires = "nvim-lua/plenary.nvim",
	}
end)
