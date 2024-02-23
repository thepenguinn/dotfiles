local group = vim.api.nvim_create_augroup("SlidesGroup", {clear = true})

local function create_graph()

    local node = vim.treesitter.get_node()
    local start_line
    local end_line
    local lines
    local graph_lines = {}
    local fd
    local cmd_str = "printf \""
    local graph_str
    local ia, ib

    if node:type() == "code_fence_content" then
        start_line, _, end_line = node:range()
        lines = vim.api.nvim_buf_get_lines(
            0, start_line, end_line, {strict_indexing = true}
        )

        ia, ib = ipairs(lines)

        if lines[1]:match("^~~~[ ]*graph$") then
            for _, line in ia, ib, 1 do
                cmd_str = cmd_str .. line .. "\n"
            end
            cmd_str = cmd_str .. "\" | graph-easy --ascii 2>&1"
            -- cmd_str = cmd_str .. "\" | graph-easy --as=boxart 2>&1"

            fd = io.popen(cmd_str)
            graph_str = fd:read("a")
            fd:close()

            graph_lines = vim.split(graph_str, "\n")

            vim.api.nvim_buf_set_lines(
                0, start_line, end_line, {strict_indexing = true}, graph_lines
            )

        end
    end
end

vim.api.nvim_create_autocmd({"BufEnter"}, {
    pattern = {"*.md"},
    callback = function()
        vim.keymap.set("n", "<leader>og", create_graph)
    end,
    group = group,
})

vim.api.nvim_create_autocmd({"BufLeave"}, {
    pattern = {"*.md"},
    callback = function()
        vim.keymap.del("n", "<leader>og")
    end,
    group = group,
})
