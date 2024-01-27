local converter = {}

converter.testing = function ()
	-- for i in vim.fs.parents(vim.api.nvim_buf_get_name(0))
	-- do
	-- 	print(i)
	-- end
	-- local table = {
	-- 	["hai"] = 'woo',
	-- 	["shi"] = 'lo',
	-- 	["hki"] = 'wwa',
	-- 	["ldklf"] = 'wao',
	-- }
	-- print(vim.inspect(
	-- 	vim.fn.json_encode(table)
	-- ))


	local popup = require("plenary.popup")

	-- local win_id = popup.create({"hai", "lol", "woo"}, {})

	-- print(vim.inspect(getmetatable(vim.fn).__index))
	-- print(vim.fn.system({"stat", "--printf %Y\n", vim.api.nvim_buf_get_name(0)}))


    local width = 60
    local height = 10
    local borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
    local bufnr = vim.api.nvim_create_buf(false, false)

    local Harpoon_win_id, win = popup.create(bufnr, {
        title = "Harpoon",
        highlight = "HarpoonWindow",
        line = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor((vim.o.columns - width) / 2),
        minwidth = width,
        minheight = height,
        borderchars = borderchars,
    })

    vim.api.nvim_win_set_option(
        win.border.win_id,
        "winhl",
        "Normal:HarpoonBorder"
    )

    local curr_file = vim.api.nvim_buf_get_name(0)
    vim.cmd(
        string.format(
            "autocmd Filetype harpoon "
                .. "let path = '%s' | call clearmatches() | "
                -- move the cursor to the line containing the current filename
                .. "call search('\\V'.path.'\\$') | "
                -- add a hl group to that line
                .. "call matchadd('HarpoonCurrentFile', '\\V'.path.'\\$')",
            curr_file:gsub("\\", "\\\\")
        )
    )

    local Harpoon_bufh = bufnr

	local contents = {
		[1] = '* woo',
		[2] = '- ( ) lo',
		[3] = 'wwa',
		[4] = 'wao',
	}

    vim.api.nvim_win_set_option(Harpoon_win_id, "number", true)
    vim.api.nvim_buf_set_name(Harpoon_bufh, "harpoon-menu")
    vim.api.nvim_buf_set_lines(Harpoon_bufh, 0, #contents, false, contents)
    vim.api.nvim_buf_set_option(Harpoon_bufh, "filetype", "text")
    vim.api.nvim_buf_set_option(Harpoon_bufh, "buftype", "acwrite")
    vim.api.nvim_buf_set_option(Harpoon_bufh, "bufhidden", "delete")
    vim.api.nvim_buf_set_keymap(
        Harpoon_bufh,
        "n",
        "q",
        "<Cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>",
        { silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        Harpoon_bufh,
        "n",
        "<ESC>",
        "<Cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>",
        { silent = true }
    )
    vim.api.nvim_buf_set_keymap(
        Harpoon_bufh,
        "n",
        "<CR>",
        "<Cmd>lua require('harpoon.ui').select_menu_item()<CR>",
        {}
    )

	-- print(vim.api.nvim_set_current_buf(Harpoon_bufh))
	-- print(vim.inspect(vim.api.nvim_list_bufs()))
	-- vim.api.nvim_set_current_buf(3)
	-- print(Harpoon_bufh)

    -- vim.cmd(
    --     string.format(
    --         "autocmd BufWriteCmd <buffer=%s> lua require('harpoon.ui').on_menu_save()",
    --         Harpoon_bufh
    --     )
    -- )
    -- if global_config.save_on_change then
    --     vim.cmd(
    --         string.format(
    --             "autocmd TextChanged,TextChangedI <buffer=%s> lua require('harpoon.ui').on_menu_save()",
    --             Harpoon_bufh
    --         )
    --     )
    -- end
    -- vim.cmd(
    --     string.format(
    --         "autocmd BufModifiedSet <buffer=%s> set nomodified",
    --         Harpoon_bufh
    --     )
    -- )
    -- vim.cmd(
    --     "autocmd BufLeave <buffer> ++nested ++once silent lua require('harpoon.ui').toggle_quick_menu()"
    -- )

end


return converter
