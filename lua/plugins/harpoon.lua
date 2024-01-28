local function config()
    local harpoon_mark = require("harpoon.mark")
    local harpoon_ui = require("harpoon.ui")

    -- KEYBINDINGS FOR HARPOON --

    vim.keymap.set("n", "<leader>hn", function () harpoon_mark.add_file() end)
    vim.keymap.set("n", "<leader>hq", function () harpoon_ui.toggle_quick_menu() end)
    vim.keymap.set("n", "<leader>hf", function () harpoon_ui.nav_file(1) end)
    vim.keymap.set("n", "<leader>hd", function () harpoon_ui.nav_file(2) end)
    vim.keymap.set("n", "<leader>hs", function () harpoon_ui.nav_file(3) end)
    vim.keymap.set("n", "<leader>ha", function () harpoon_ui.nav_file(4) end)
end

return {
    {
        "ThePrimeagen/harpoon",
        config = config
    }
}
