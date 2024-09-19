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

M.exec_all_from_norg = function ()

    print("wip")

    for i = 1, 4 do
        print(i)
    end

    if true then return end

    local query = vim.treesitter.query.parse("norg",
        [[
        (ranged_verbatim_tag
            (tag_parameters) @tag_param
            (#eq? @tag_param "python")
            ) @python_rverb_tag
        ]]
    )

    local ltree = vim.treesitter.get_parser(0, "norg")
    local troot = ltree:parse()[1]:root()


    local count = 0
    for _, cnode in query:iter_captures(troot, 0) do
        if cnode:type() == "ranged_verbatim_tag" then
            M._exec_from_norg(cnode)
        end
    end

end

M.exec_all = function ()

    if vim.bo.filetype == "tex" then
        M.exec_all_from_tex()
    elseif vim.bo.filetype == "norg" then
        print("Sorry, not implemented yet.")
    end

end

M.exec_all_from_tex = function ()

    local query = vim.treesitter.query.parse("latex",
        [[
            (
             (minted_environment
               begin: (begin
                 language: (curly_group_text
                   text: (text) @lang
                   )
                 )
               )
             (#eq? @lang "python")
             ) @minted_python
        ]]
    )

    local start_row = 0
    local exec_count = 0
    local total_exec_count = 0

    local ltree = vim.treesitter.get_parser(0, "latex")
    local troot
    local iter
    local cnode

    local troot = ltree:parse({start_row, -1})[1]:root()

    for _, cnode in query:iter_captures(troot, 0) do
        if cnode:type() == "minted_environment" then
            total_exec_count = total_exec_count + 1
        end
    end

    vim.schedule(function ()
        vim.api.nvim_echo({{
            "Exec Count: [0/" .. tostring(total_exec_count) .. "]"
        }}, true, {})
    end)

    for i = 1, total_exec_count do
        troot = ltree:parse({start_row, -1})[1]:root()

        iter = query:iter_captures(troot, 0)

        local j = exec_count + 1
        while 0 < j do
            _, cnode = iter()
            if cnode then
                if cnode:type() == "minted_environment" then
                    j = j - 1
                end
            else
                break
            end
        end

        if cnode then
            start_row = cnode:end_()
            M._exec_from_tex(cnode)
            exec_count = exec_count + 1

            vim.schedule(function ()
                vim.api.nvim_echo({{
                    "Exec Count: [" .. tostring(exec_count) .. "/" .. tostring(total_exec_count) .. "]"
                }}, true, {})
            end)

            -- print(
            --     "Exec Count: [" .. tostring(exec_count) .. "/" .. tostring(total_exec_count) .. "]"
            -- )
        else
            break
        end
    end

end

M.exec_at_cursor = function ()

    if vim.bo.filetype == "norg" then
        M.exec_at_cursor_from_norg()
    elseif vim.bo.filetype == "tex" then
        M.exec_at_cursor_from_tex()
    end

end

M.exec_at_cursor_from_tex = function()
    -- get the code block

    local node
    local prenode

    node = vim.treesitter.get_node()

    if not node then
        return
    end

    if node:type() == "line_comment" then
        -- if the current node the cursor is at is an line_comment
        -- then there is a chance that we are just above the minted env
        -- btw, this line_comment is used to denote the tangle file
        prenode = node
        node = node:next_named_sibling()

        if node and node:type() == "minted_environment" then
            goto got_node
        end
        node = prenode
    end

    while node do
        prenode = node
        node = node:parent()
        if node and node:type() == "minted_environment" then
            break
        end
    end

    if not node then
        return
    end

    ::got_node::
    M._exec_from_tex(node)

end

M._add_output_block_to_tex = function(code_node, stdout)

    local code_end

    local stdout_start
    local stdout_end

    local paragraph_node
    local paragraph_title
    local minted_node
    local source_node
    local node

    local padding
    local code_node_start_col

    _, code_node_start_col =  code_node:start()
    padding = string.rep(" ", code_node_start_col)

    paragraph_node = code_node:next_named_sibling()

    -- that latex parser is weird, or I'm an idiot
    if not paragraph_node then
        paragraph_node = code_node:parent()
        if paragraph_node then
            paragraph_node = paragraph_node:next_named_sibling()
        end
    end

    if not paragraph_node or paragraph_node:type() ~= "paragraph" then
        -- print("paragraph " .. code_node:type(), paragraph_node)
        goto insert_new
    end

    node = paragraph_node:named_child(0)
    if not node or node:type() ~= "curly_group" then
        -- print("curly_group")
        goto insert_new
    end

    paragraph_title = M._get_text(node)[1]
    if paragraph_title ~= "{Output}" then
        -- print("{Output}")
        goto insert_new
    end

    minted_node = paragraph_node:named_child(1)
    if not minted_node or minted_node:type() ~= "minted_environment" then
        -- print("minted_environment")
        goto insert_new
    end

    node = minted_node:named_child(0)
    node = node:field("language")[1]
    if not node then
        -- print("no node")
        goto insert_new
    end

    if M._get_text(node)[1] ~= "{text}" then
        -- print("{text}")
        goto insert_new
    end

    source_node = minted_node:field("code")[1]
    if not source_node then
        -- print("not source code")
        goto insert_new
    end

    stdout_start = source_node:start() + 1
    stdout_end = source_node:end_()

    goto insert_stdout

    ::insert_new::

    code_end = code_node:end_()

    vim.api.nvim_buf_set_lines(
        0, code_end + 1, code_end + 1, {strict_indexing = true}, {
            "",
            padding .. "\\paragraph{Output}",
            "",
            padding .. "\\begin{minted}[breaklines, autogobble] {text}",
            padding .. "\\end{minted}",
        }
    )

    stdout_start = code_end + 5
    stdout_end = stdout_start

    ::insert_stdout::

    -- padding of the parent node plus padding of 4
    padding = padding .. string.rep(" ", 4)

    for idx in ipairs(stdout) do
        stdout[idx] = padding .. stdout[idx]
    end

    vim.api.nvim_buf_set_lines(
        0, stdout_start, stdout_end, {strict_indexing = true}, stdout
    )

end

M._remove_output_block_from_tex = function (code_node)

    local paragraph_node
    local paragraph_title
    local minted_node
    local source_node
    local node

    paragraph_node = code_node:next_named_sibling()

    -- that latex parser is weird, or I'm an idiot
    if not paragraph_node then
        paragraph_node = code_node:parent()
        if paragraph_node then
            paragraph_node = paragraph_node:next_named_sibling()
        end
    end

    if not paragraph_node or paragraph_node:type() ~= "paragraph" then
        return
    end

    node = paragraph_node:named_child(0)
    if not node or node:type() ~= "curly_group" then
        return
    end

    paragraph_title = M._get_text(node)[1]
    if paragraph_title ~= "{Output}" then
        return
    end

    minted_node = paragraph_node:named_child(1)
    if not minted_node or minted_node:type() ~= "minted_environment" then
        return
    end

    node = minted_node:named_child(0)
    node = node:field("language")[1]
    if not node then
        return
    end

    if M._get_text(node)[1] ~= "{text}" then
        return
    end

    source_node = minted_node:field("code")[1]
    if not source_node then
        return
    end

    -- if we reach here then we need to remove the output block

    local code_end = code_node:end_() + 1
    local output_code_end = minted_node:end_() + 1

    vim.api.nvim_buf_set_lines(
        0, code_end, output_code_end, {strict_indexing = true}, {nil}
    )

end

M._exec_from_tex = function(node)

    local lang_node = node:named_child(0)

    lang_node = lang_node:field("language")
    if not lang_node then
        return
    end

    lang_node = lang_node[1]
    if not lang_node then
        return
    end

    lang_node = lang_node:named_child(0)
    if not lang_node then
        return
    end

    if M._get_text(lang_node)[1] ~= "python" then
        return
    end

    local tangle_file = node:prev_named_sibling()
    if not tangle_file or tangle_file:type() ~= "line_comment" then
        return
    end

    tangle_file = M._get_text(tangle_file)[1]
    tangle_file = tangle_file:sub(2, -2)
    if not tangle_file or tangle_file == "" then
        return
    end

    local parent_dir = vim.api.nvim_buf_get_name(0)
    if not parent_dir or parent_dir == "" then
        return
    end
    parent_dir = string.gsub(parent_dir, "/[^/]+$", "")
    tangle_file = parent_dir .. "/" .. tangle_file

    local content_node = node:field("code")[1]
    local code_block = M._get_text(content_node)

    if code_block[1] == "" then
        table.remove(code_block, 1)
    end

    local trim_size = code_block[1]:match("^[ \t]*")
    trim_size = #trim_size

    for i = 1, #code_block do
        code_block[i] = code_block[i]:sub(trim_size + 1, -1)
    end

    M._tangle_to_file(tangle_file, code_block)

    M._pyexec_file(
        tangle_file, node,
        M._add_output_block_to_tex, M._remove_output_block_from_tex
    )

end

M.exec_at_cursor_from_norg = function()

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

    M._exec_from_norg(node)

end


M._tangle_to_file = function (tangle_file, code_block)

    -- tangle_file: string? absolute file path
    -- code_block: table? table of code lines

    local tmp = code_block
    local tangle_parent_dir
    local tangle_file_fd
    code_block = ""

    for _, line in ipairs(tmp) do
        code_block = code_block .. line .. "\n"
    end

    tangle_parent_dir = string.gsub(tangle_file, "/[^/]+$", "")
    vim.fn.mkdir(tangle_parent_dir, "p")

    tangle_file_fd = io.open(tangle_file, "w")
    tangle_file_fd:write(code_block)
    tangle_file_fd:close()

end

M._pyexec_file = function (tangle_file, code_node, add_output_callback, remove_output_callback)

    -- tangle_file: string? absolute file path
    -- code_node: tsnode? this will be passed to the callbacks as the first arg
    -- add_output_callback: callable? callback to call to add the output
    -- remove_output_callback: callable? callback to call to remove the output

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

    local stdout_file_exists = false

    tmp = io.open(stdout_file)
    if tmp then
        stdout_file_exists = true
        tmp:close()
        tmp = io.popen(
            "stat --printf \"%.Y\" \""
            .. stdout_file
            .. "\""
        )
        nmodt = tonumber(tmp:read())
        tmp:close()
    end

    if not stdout_file_exists and stdout == "" then
        -- remove the output block if exists
        remove_output_callback(code_node)
        return
    elseif nmodt <= lmodt then
        -- simply return
        -- this could mean the exec has failed,
        -- and in that case we won't be removing the previous
        -- output, and simply prints the exceptions generated
        vim.api.nvim_echo({{stdout}}, true, {})
        return
    end

    -- insert the output
    stdout = vim.split(stdout, "\n", {plain = true})
    if stdout[#stdout] == "" then
        stdout[#stdout] = nil
    end
    add_output_callback(code_node, stdout)

end

M._remove_output_block_from_norg = function(code_node)

    local output_head_level = ""
    local parent_node = code_node:parent()

    if parent_node:type():match("document") then
        output_head_level = "*"
    elseif parent_node:type():match("heading[1-6]") then
        output_head_level = M._get_text(parent_node:named_child(0))[1]

        output_head_level = output_head_level:gsub("^ *", "")
        output_head_level = output_head_level:gsub(" *$", "") .. "*"
    end

    local code_end = code_node:end_() + 1
    local node = code_node:next_named_sibling()

    if node and node:type():match("heading[1-6]") then

        local next_head_level
        local next_head_title

        next_head_level = M._get_text(node:named_child(0))[1]

        next_head_level = next_head_level:gsub("^ *", "")
        next_head_level = next_head_level:gsub(" *$", "")

        next_head_title = M._get_text(node:named_child(1))[1]

        if next_head_level == output_head_level
            and next_head_title == "Output" then

            -- look for the output code block, if we find it
            -- just remove till the end of it

            node = node:named_child(2)
            if not node or node:type() ~= "ranged_verbatim_tag" then
                return
            end

            local output_code_end
            local output_code_node = node

            node = node:next_named_sibling()

            if node and node:type() == "weak_paragraph_delimiter" then
                output_code_end = node:end_()
            else
                output_code_end = output_code_node:end_() + 1
            end

            vim.api.nvim_buf_set_lines(
                0, code_end, output_code_end, {strict_indexing = true}, {nil}
            )

        end
    end
end

M._add_output_block_to_norg = function(code_node, stdout)

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
                    "",
                    padding .. "---",

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
                "",
                padding .. "---",
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
                "",
                padding .. "---",
            }
        )

        stdout_start = output_head_start + 3
        stdout_end = stdout_start

        goto insert_stdout

    end

    stdout_start = output_verbatim_node:start() + 1
    stdout_end = output_verbatim_node:end_()

    ::insert_stdout::

    for idx in ipairs(stdout) do
        stdout[idx] = padding .. stdout[idx]
    end

    vim.api.nvim_buf_set_lines(
        0, stdout_start, stdout_end, {strict_indexing = true}, stdout
    )

end

M._exec_from_norg = function (node)

    local content_node

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

    M._tangle_to_file(tangle_file, code_block)

    M._pyexec_file(
        tangle_file, node,
        M._add_output_block_to_norg, M._remove_output_block_from_norg
    )

end

return M
