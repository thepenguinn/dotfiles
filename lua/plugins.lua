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
	use 'nvim-treesitter/playground'
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
					["core.esupports.metagen"] = {
						config = {
							type = "auto"
						},
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
					["external.notes"] = {
						config = {
							lol = test,
						},
					},
				},
			}
		end,
		--run = ":Neorg sync-parsers",
		requires = {
			'nvim-lua/notes',
			'nvim-lua/plenary.nvim',
		},
	}
end)
