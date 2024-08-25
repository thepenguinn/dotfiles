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

M._init_chapter = function(parent_dir, file_base)

    -- files to copy
    -- create the parent directory
    -- chapter_makefile, syllabus.tex, chapter.tex
    -- directories to create
    -- plots, tikzpics, data

    local tmp = io.open(parent_dir .. "/chapter.tex", "r")
    if tmp then
        tmp:close()
        vim.cmd("e " .. parent_dir .. "/chapter.tex")
        return
    end

    -- init the chapter dir

    local path = require("pathlib")

    vim.fn.mkdir(parent_dir .. "/plots", "p")
    vim.fn.mkdir(parent_dir .. "/tikzpics", "p")
    vim.fn.mkdir(parent_dir .. "/data", "p")

    tmp = path("~/.config/notes/chapter_makefile")
    tmp:copy(path(parent_dir .. "/Makefile"))

    tmp = path(parent_dir .. "/syllabus.tex")
    tmp:touch()

    vim.cmd("e " .. parent_dir .. "/chapter.tex")
    -- snippet for beginning the chapter
    vim.cmd("norm ibchp")

end

M._init_work = function(parent_dir, file_base)

    -- files to copy
    -- create the parent directory
    -- work_makefile, abstract.tex, work.tex
    -- directories to create
    -- plots, tikzpics, data

    local tmp = io.open(parent_dir .. "/work.tex", "r")
    if tmp then
        tmp:close()
        vim.cmd("e " .. parent_dir .. "/work.tex")
        return
    end

    -- init the chapter dir

    local path = require("pathlib")

    vim.fn.mkdir(parent_dir .. "/plots", "p")
    vim.fn.mkdir(parent_dir .. "/tikzpics", "p")
    vim.fn.mkdir(parent_dir .. "/data", "p")

    tmp = path("~/.config/notes/work_makefile")
    tmp:copy(path(parent_dir .. "/Makefile"))

    tmp = path("~/.config/notes/abstract.tex")
    tmp:copy(path(parent_dir .. "/abstract.tex"))

    vim.cmd("e " .. parent_dir .. "/work.tex")
    -- snippet for beginning the work
    vim.cmd("norm ibwrk")

end

M._init_section = function(parent_dir, file_base)

    -- files to copy
    -- create the parent directory
    -- section_makefile, section.tex
    -- directories to create
    -- plots, tikzpics, data

    local tmp = io.open(parent_dir .. "/section.tex", "r")
    if tmp then
        tmp:close()
        vim.cmd("e " .. parent_dir .. "/section.tex")
        return
    end

    -- init the section dir

    local path = require("pathlib")

    vim.fn.mkdir(parent_dir .. "/plots", "p")
    vim.fn.mkdir(parent_dir .. "/tikzpics", "p")
    vim.fn.mkdir(parent_dir .. "/data", "p")

    tmp = path("~/.config/notes/section_makefile")
    tmp:copy(path(parent_dir .. "/Makefile"))

    vim.cmd("e " .. parent_dir .. "/section.tex")
    -- snippet for beginning the section
    vim.cmd("norm ibsec")

end

M._init_syllabus = function(parent_dir, file_base)
    print("from _init_syllabus", parent_dir, file_base)
end

M._jump_to_file = function(parent_dir, file_base)

    local path = require("pathlib")
    local tmp

    tmp = path(parent_dir .. "/" .. file_base .. ".tex")
    tmp:touch(nil, true)

    vim.cmd("e " .. parent_dir .. "/" .. file_base .. ".tex")

    print("from _jump_to_file", parent_dir, file_base)
end

M.get_node = function()

    local cur_node = vim.treesitter.get_node()

    local tmp_node = cur_node

    while tmp_node do
        if tmp_node:type() == "latex_include" or tmp_node:type() == "graphics_include" then
            break
        end
        if tmp_node:type() == "generic_environment" then
            tmp_node = nil
        else
            tmp_node = tmp_node:parent()
        end
    end

    if tmp_node then
        return tmp_node
    end

    tmp_node = cur_node:named_child(0)

    while tmp_node do
        if tmp_node:type() == "latex_include" or tmp_node:type() == "graphics_include" then
            break
        end
        if tmp_node:type() == "generic_environment" then
            tmp_node = nil
        else
            tmp_node = tmp_node:next_named_sibling()
        end
    end

    -- could be nil or a valid node
    return tmp_node

end

M.jump = function()

    local cur_node = M.get_node()

    if not cur_node then
        print("press <cr>")
        return
    end

    local cur_file_parent
    local cur_file_base

    cur_file_parent = vim.api.nvim_buf_get_name(0)

    cur_file_parent = cur_file_parent:gsub("%.tex$", "")
    cur_file_base = cur_file_parent:gsub("^.*/", "")
    cur_file_parent = cur_file_parent:gsub("/[^/]-$", "")

    if cur_node:type() == "latex_include" then

        cur_node = cur_node:named_child(0):named_child(0)

        local sub_file_parent = M._get_text(cur_node)[1]
        local sub_file_base

        sub_file_parent = sub_file_parent:gsub("^[ \t]*", "")
        sub_file_parent = sub_file_parent:gsub("[ \t]*$", "")

        sub_file_parent = sub_file_parent:gsub("%.tex$", "")
        sub_file_base = sub_file_parent:gsub("^.*/", "")
        sub_file_parent = sub_file_parent:gsub("/[^/]-$", "")

        print(sub_file_parent, sub_file_base)

        sub_file_parent = vim.fn.resolve(
            cur_file_parent .. "/" .. sub_file_parent
        )

        -- local l = {}
        --
        -- for _, buf in ipairs(vim.fn.getbufinfo()) do
        --     l[#l + 1] = buf.name
        -- end
        --
        -- vim.api.nvim_buf_set_lines(
        --     0, -1, -1, {strict_indexing = true}, l
        -- )

        if cur_file_base == "course" then
            if sub_file_base == "chapter" then
                M._init_chapter(sub_file_parent, sub_file_base)
            elseif sub_file_base == "work" then
                M._init_work(sub_file_parent, sub_file_base)
            end
        elseif cur_file_base == "chapter" then
            if sub_file_base == "section" then
                M._init_section(sub_file_parent, sub_file_base)
            elseif sub_file_base == "syllabus" then
                M._init_syllabus(sub_file_parent, sub_file_base)
            end
        elseif cur_file_parent == "work" then
            if sub_file_base == "section" then
                M._init_section(sub_file_parent, sub_file_base)
            end
        else
            M._jump_to_file(sub_file_parent, sub_file_base)
        end

        -- chapter.tex, section.tex, work.tex, syllabus.tex, abstract.tex
    end

    if cur_node:type() == "graphics_include" then
        -- do the thing
        -- then return
    end


end

return M
