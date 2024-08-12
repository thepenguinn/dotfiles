local M = {}

M._get_text = function (node)

    local start_row, start_col, end_row, end_col

    start_row, start_col, end_row, end_col = node:range()
    -- print(start_row, start_col, end_row, end_col)
    local text = vim.api.nvim_buf_get_text(
        0, start_row, start_col, end_row, end_col, {}
    )

    return text
end

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

    tangle_file_fd = io.open(tangle_file, "w")
    tangle_file_fd:write(code_block)
    tangle_file_fd:close()

    local lmodt = 0
    local nmodt = 0
    local tmp
    local stdout_file

    stdout_file = string.gsub(tangle_file, "%.py$", ".stdout")

    tmp = io.open(stdout_file)
    if tmp then
        tmp:close()
        tmp = io.popen(
            "stat --printf \"%.Y\" \""
            .. stdout_file
            .. "\""
        )
        lmodt = tonumber(tmp:read())
        tmp:close()
    end

    -- now pass this file to pyexec, so it can execute the file
    local pyexec = io.popen("pyexec \"" .. tangle_file .. "\"")
    local stdout = pyexec:read("a")

    tmp = io.open(stdout_file)
    if tmp then
        tmp:close()
        tmp = io.popen(
            "stat --printf \"%.Y\" \""
            .. stdout_file
            .. "\""
        )
        nmodt = tonumber(tmp:read())
        tmp:close()
    end

    if nmodt <= lmodt then
        return
    end

    -- insert the output
    stdout = vim.split(stdout, "\n", {plain = true})
    M._add_output_block(node, stdout)

end

M._add_output_block = function(code_node, stdout)

    local output_head_level = ""
    local parent_node = code_node:parent()

    if parent_node:type():match("document") then
        output_head_level = "*"
    elseif parent_node:type():match("heading[1-6]") then
        output_head_level = M._get_text(parent_node:named_child(0))[1]

        output_head_level = output_head_level:gsub("^ *", "")
        output_head_level = output_head_level:gsub(" *$", "") .. "*"
    end

    local code_end = code_node:end_()
    local node = code_node:next_named_sibling()

    local padding = string.rep(" ", #output_head_level + 1)

    local stdout_start
    local stdout_end

    local output_head_node
    local output_head_start
    local output_verbatim_node

    if node and node:type():match("heading[1-6]") then

        local next_head_level
        local next_head_title

        next_head_level = M._get_text(node:named_child(0))[1]

        next_head_level = next_head_level:gsub("^ *", "")
        next_head_level = next_head_level:gsub(" *$", "")

        next_head_title = M._get_text(node:named_child(1))[1]

        if next_head_level ~= output_head_level
            or next_head_title ~= "Output" then

            vim.api.nvim_buf_set_lines(
                0, code_end + 1, code_end + 1, {strict_indexing = true}, {
                    "",
                    output_head_level .. " Output",
                    "",
                    padding .. "@code",
                    padding .. "@end",

                }
            )

            stdout_start = code_end + 5
            stdout_end = stdout_start

            goto insert_stdout

        end
    else

        vim.api.nvim_buf_set_lines(
            0, code_end + 1, code_end + 1, {strict_indexing = true}, {
                "",
                output_head_level .. " Output",
                "",
                padding .. "@code",
                padding .. "@end",
            }
        )

        stdout_start = code_end + 5
        stdout_end = stdout_start

        goto insert_stdout

    end

    output_head_node = code_node:next_named_sibling()
    -- third will be the ranged_verbatim_tag
    output_verbatim_node = output_head_node:named_child(2)
    output_head_start = output_head_node:start()

    padding = M._get_text(output_head_node:named_child(0))[1]
    padding = string.rep(" ", #padding)

    if not output_verbatim_node or output_verbatim_node:type() ~= "ranged_verbatim_tag" then
        -- print("adding new block")

        vim.api.nvim_buf_set_lines(
            0, output_head_start + 1, output_head_start + 1,
            {strict_indexing = true}, {
                "",
                padding .. "@code",
                padding .. "@end",
            }
        )

        stdout_start = output_head_start + 3
        stdout_end = stdout_start

        goto insert_stdout

    end

    stdout_start = output_verbatim_node:start() + 1
    stdout_end = output_verbatim_node:end_()

    ::insert_stdout::

    if stdout[#stdout] == "" then
        stdout[#stdout] = nil
    end

    for idx in ipairs(stdout) do
        stdout[idx] = padding .. stdout[idx]
    end

    vim.api.nvim_buf_set_lines(
        0, stdout_start, stdout_end, {strict_indexing = true}, stdout
    )

end

return M
