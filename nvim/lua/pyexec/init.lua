local M = {}

M.exec = function ()
    local node
    local prenode
    local content_node

    node = vim.treesitter.get_node()

    while node do
        prenode = node
        node = node:parent()
        if node and node:type() == "ranged_verbatim_tag" then
            break
        end
    end

    if not node then
        return
    end

    content_node = node:named_child(0)

    while content_node do
        if content_node:type() == "ranged_verbatim_tag_content" then
            break
        end

        content_node = content_node:next_named_sibling()
    end

    if not content_node then
        return
    end

    local heading_level
    local tmp

    local tangle_file

    local start_row, start_col, end_row, end_col

    tmp = node:prev_named_sibling()
    if not tmp or tmp:type() ~= "paragraph" then
        return
    end

    tmp = tmp:named_child(0)
    if not tmp or tmp:type() ~= "paragraph_segment" then
        return
    end

    tmp = tmp:named_child(0)
    if not tmp or tmp:type() ~= "inline_comment" then
        return
    end

    start_row, start_col, end_row, end_col = tmp:range()
    tangle_file = vim.api.nvim_buf_get_text(
        0, start_row, start_col, end_row, end_col, {}
    )
    tangle_file = tangle_file[1]:sub(2, -2)

    local parent_dir = vim.api.nvim_buf_get_name(0)
    if not parent_dir or parent_dir == "" then
        return
    end
    parent_dir = string.gsub(parent_dir, "/[^/]+$", "")
    tangle_file = parent_dir .. "/" .. tangle_file

    start_row, start_col, end_row, end_col = content_node:range()

    local code_block = vim.api.nvim_buf_get_text(
        0, start_row, start_col, end_row, end_col, {}
    )

    if #code_block > 2 then
        for i = 2, #code_block do
            code_block[i] = code_block[i]:sub(start_col + 1, -1)
        end
    end

    tmp = code_block
    code_block = ""

    for _, line in ipairs(tmp) do
        code_block = code_block .. line .. "\n"
    end

    local tangle_parent_dir
    tangle_parent_dir = string.gsub(tangle_file, "/[^/]+$", "")
    vim.fn.mkdir(tangle_parent_dir, "p")

    print(tangle_file)
    tangle_file_fd = io.open(tangle_file, "w")
    tangle_file_fd:write(code_block)
    tangle_file_fd:close()

    vim.api.nvim_buf_set_lines(0, -1, -1, {strict_indexing = true}, tmp)

end

return M
