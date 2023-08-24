-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

_G._packer = _G._packer or {}
_G._packer.inside_compile = true

local time
local profile_info
local should_profile = false
if should_profile then
  local hrtime = vim.loop.hrtime
  profile_info = {}
  time = function(chunk, start)
    if start then
      profile_info[chunk] = hrtime()
    else
      profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
    end
  end
else
  time = function(chunk, start) end
end

local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end
  if threshold then
    table.insert(results, '(Only showing plugins that took longer than ' .. threshold .. ' ms ' .. 'to load)')
  end

  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/data/data/com.termux/files/home/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/data/data/com.termux/files/home/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/data/data/com.termux/files/home/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/data/data/com.termux/files/home/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/data/data/com.termux/files/home/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  catppuccin = {
    loaded = true,
    path = "/data/data/com.termux/files/home/.local/share/nvim/site/pack/packer/start/catppuccin",
    url = "https://github.com/catppuccin/nvim"
  },
  harpoon = {
    loaded = true,
    path = "/data/data/com.termux/files/home/.local/share/nvim/site/pack/packer/start/harpoon",
    url = "https://github.com/ThePrimeagen/harpoon"
  },
  ["lualine.nvim"] = {
    loaded = true,
    path = "/data/data/com.termux/files/home/.local/share/nvim/site/pack/packer/start/lualine.nvim",
    url = "https://github.com/nvim-lualine/lualine.nvim"
  },
  neorg = {
    config = { "\27LJ\2\nµ\3\0\0\a\0\26\0%6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\24\0005\3\3\0004\4\0\0=\4\4\0035\4\6\0005\5\5\0=\5\a\4=\4\b\0034\4\0\0=\4\t\0034\4\0\0=\4\n\0034\4\0\0=\4\v\0035\4\r\0005\5\f\0=\5\a\4=\4\14\0035\4\16\0005\5\15\0=\5\a\4=\4\17\0034\4\0\0=\4\18\0035\4\22\0005\5\20\0005\6\19\0=\6\21\5=\5\a\4=\4\23\3=\3\25\2B\0\2\1K\0\1\0\tload\1\0\0\16core.dirman\1\0\0\15workspaces\1\0\0\1\0\1\nnotes\f~/notes\23core.looking-glass\20core.highlights\1\0\0\1\0\1\27todo_items_match_color\ball\25core.export.markdown\1\0\0\1\0\1\15extensions\ball\16core.export\15core.promo\15core.itero\20core..concealer\vconfig\1\0\0\1\0\1\16icon_preset\nbasic\18core.defaults\1\0\0\nsetup\nneorg\frequire\0" },
    loaded = true,
    path = "/data/data/com.termux/files/home/.local/share/nvim/site/pack/packer/start/neorg",
    url = "https://github.com/nvim-neorg/neorg"
  },
  ["nvim-colorizer.lua"] = {
    loaded = true,
    path = "/data/data/com.termux/files/home/.local/share/nvim/site/pack/packer/start/nvim-colorizer.lua",
    url = "https://github.com/norcalli/nvim-colorizer.lua"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/data/data/com.termux/files/home/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-web-devicons"] = {
    loaded = false,
    needs_bufread = false,
    path = "/data/data/com.termux/files/home/.local/share/nvim/site/pack/packer/opt/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/data/data/com.termux/files/home/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/data/data/com.termux/files/home/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["pretty-fold.nvim"] = {
    config = { "\27LJ\2\n9\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\16pretty-fold\frequire\0" },
    loaded = true,
    path = "/data/data/com.termux/files/home/.local/share/nvim/site/pack/packer/start/pretty-fold.nvim",
    url = "https://github.com/anuvyklack/pretty-fold.nvim"
  },
  ["trim.nvim"] = {
    config = { "\27LJ\2\n6\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\ttrim\frequire\0" },
    loaded = true,
    path = "/data/data/com.termux/files/home/.local/share/nvim/site/pack/packer/start/trim.nvim",
    url = "https://github.com/cappyzawa/trim.nvim"
  },
  ["true-zen.nvim"] = {
    config = { "\27LJ\2\n:\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\rtrue-zen\frequire\0" },
    loaded = true,
    path = "/data/data/com.termux/files/home/.local/share/nvim/site/pack/packer/start/true-zen.nvim",
    url = "https://github.com/Pocco81/true-zen.nvim"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: pretty-fold.nvim
time([[Config for pretty-fold.nvim]], true)
try_loadstring("\27LJ\2\n9\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\16pretty-fold\frequire\0", "config", "pretty-fold.nvim")
time([[Config for pretty-fold.nvim]], false)
-- Config for: neorg
time([[Config for neorg]], true)
try_loadstring("\27LJ\2\nµ\3\0\0\a\0\26\0%6\0\0\0'\2\1\0B\0\2\0029\0\2\0005\2\24\0005\3\3\0004\4\0\0=\4\4\0035\4\6\0005\5\5\0=\5\a\4=\4\b\0034\4\0\0=\4\t\0034\4\0\0=\4\n\0034\4\0\0=\4\v\0035\4\r\0005\5\f\0=\5\a\4=\4\14\0035\4\16\0005\5\15\0=\5\a\4=\4\17\0034\4\0\0=\4\18\0035\4\22\0005\5\20\0005\6\19\0=\6\21\5=\5\a\4=\4\23\3=\3\25\2B\0\2\1K\0\1\0\tload\1\0\0\16core.dirman\1\0\0\15workspaces\1\0\0\1\0\1\nnotes\f~/notes\23core.looking-glass\20core.highlights\1\0\0\1\0\1\27todo_items_match_color\ball\25core.export.markdown\1\0\0\1\0\1\15extensions\ball\16core.export\15core.promo\15core.itero\20core..concealer\vconfig\1\0\0\1\0\1\16icon_preset\nbasic\18core.defaults\1\0\0\nsetup\nneorg\frequire\0", "config", "neorg")
time([[Config for neorg]], false)
-- Config for: trim.nvim
time([[Config for trim.nvim]], true)
try_loadstring("\27LJ\2\n6\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\ttrim\frequire\0", "config", "trim.nvim")
time([[Config for trim.nvim]], false)
-- Config for: true-zen.nvim
time([[Config for true-zen.nvim]], true)
try_loadstring("\27LJ\2\n:\0\0\3\0\3\0\a6\0\0\0'\2\1\0B\0\2\0029\0\2\0004\2\0\0B\0\2\1K\0\1\0\nsetup\rtrue-zen\frequire\0", "config", "true-zen.nvim")
time([[Config for true-zen.nvim]], false)

_G._packer.inside_compile = false
if _G._packer.needs_bufread == true then
  vim.cmd("doautocmd BufRead")
end
_G._packer.needs_bufread = false

if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
