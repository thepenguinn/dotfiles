local M = {}

M.create_graph = function()

    local node = vim.treesitter.get_node()

    if node:type() == "code_fence_content" then
        M._create_graph(0, node)
    end

end

M._create_graph = function(buf_num, node)

    local start_line
    local end_line
    local lines
    local graph_lines = {}
    local fd
    local cmd_str = "printf \""
    local graph_str
    local ia, ib

    start_line, _, end_line = node:range()
    lines = vim.api.nvim_buf_get_lines(
        buf_num, start_line, end_line, {strict_indexing = true}
    )

    ia, ib = ipairs(lines)

    if lines[1]:match("^~~~[ ]*graph$") then
        for _, line in ia, ib, 1 do
            cmd_str = cmd_str .. line .. "\n"
        end
        cmd_str = cmd_str .. "\" | graph-easy --as=boxart 2>&1"
        -- cmd_str = cmd_str .. "\" | graph-easy --ascii 2>&1"

        fd = io.popen(cmd_str)
        graph_str = fd:read("a")
        fd:close()

        graph_lines = vim.split(graph_str, "\n")

        vim.api.nvim_buf_set_lines(
            buf_num, start_line, end_line, {strict_indexing = true}, graph_lines
        )

    end
end


M.export_graph = function ()

    local start_line
    local end_line

    local query = vim.treesitter.query.parse("markdown",
        [[
        (code_fence_content) @shit
        ]])

    local scratch_buf_num = vim.api.nvim_create_buf(false, true)

    -- read and write the contents of the current buffer to scratchpad
    local cur_buf_content = vim.api.nvim_buf_get_lines(
        0, 0, -1, {strict_indexing = true}
    )
    vim.api.nvim_buf_set_lines(
        scratch_buf_num, 0, 0, {strict_indexing = true}, cur_buf_content
    )

    local ltree = vim.treesitter.get_parser(scratch_buf_num, "markdown")
    local troot= ltree:parse()[1]:root()

    for _, cnode in query:iter_captures(troot, scratch_buf_num) do
        M._create_graph(scratch_buf_num, cnode)
    end

    local scratch_buf_content = vim.api.nvim_buf_get_lines(
        scratch_buf_num, 0, -1, {strict_indexing = true}
    )

    local scratch_buf_str = ""

    local export_file_name = vim.api.nvim_buf_get_name(0):gsub(".md$", "_export.md")

    for _, line in ipairs(scratch_buf_content) do
        scratch_buf_str = scratch_buf_str .. line .. "\n"
    end

    local export_file = io.open(export_file_name, "w")

    export_file:write(scratch_buf_str)

    export_file:close()

    vim.api.nvim_buf_delete(scratch_buf_num, {})

end


return M
