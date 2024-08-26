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

M._init_tikzpic = function(file_path)

    local tmp

    tmp = io.open(file_path, "r")
    if tmp then
        tmp:close()
        vim.cmd("e " .. file_path)
    else
        print("Intializing: Spawning Rexes, Wrapping Raptors, Polishing Ceratops...")
        vim.cmd("e " .. file_path)
        vim.cmd("norm ibpic ")
        require("luasnip").expand()
    end

end

M._init_chapter = function(parent_dir)

    local tmp = io.open(parent_dir .. "/chapter.tex", "r")
    if tmp then
        tmp:close()
        vim.cmd("e " .. parent_dir .. "/chapter.tex")
        return
    end

    local path = require("pathlib")

    vim.fn.mkdir(parent_dir .. "/plots", "p")
    vim.fn.mkdir(parent_dir .. "/tikzpics", "p")
    vim.fn.mkdir(parent_dir .. "/data", "p")

    tmp = path("~/.config/notes/chapter_makefile")
    tmp:copy(path(parent_dir .. "/Makefile"))

    tmp = path(parent_dir .. "/syllabus.tex")
    tmp:touch()

    if vim.fn.bufloaded(parent_dir .. "/chapter.tex") == 0 then
        vim.cmd("e " .. parent_dir .. "/chapter.tex")
        vim.cmd("norm ibchp ")
        require("luasnip").expand()
    else
        vim.cmd("e " .. parent_dir .. "/chapter.tex")
    end

end

M._init_work = function(parent_dir)

    local tmp = io.open(parent_dir .. "/work.tex", "r")
    if tmp then
        tmp:close()
        vim.cmd("e " .. parent_dir .. "/work.tex")
        return
    end

    local path = require("pathlib")

    vim.fn.mkdir(parent_dir .. "/plots", "p")
    vim.fn.mkdir(parent_dir .. "/tikzpics", "p")
    vim.fn.mkdir(parent_dir .. "/data", "p")

    tmp = path("~/.config/notes/work_makefile")
    tmp:copy(path(parent_dir .. "/Makefile"))

    tmp = path("~/.config/notes/work_header.tex")
    tmp:copy(path(parent_dir .. "/work_header.tex"))

    tmp = path("~/.config/notes/abstract.tex")
    tmp:copy(path(parent_dir .. "/abstract.tex"))

    if vim.fn.bufloaded(parent_dir .. "/work.tex") == 0 then
        vim.cmd("e " .. parent_dir .. "/work.tex")
        vim.cmd("norm ibwrk ")
        require("luasnip").expand()
    else
        vim.cmd("e " .. parent_dir .. "/work.tex")
    end

end

M._init_section = function(parent_dir)

    local tmp = io.open(parent_dir .. "/section.tex", "r")
    if tmp then
        tmp:close()
        vim.cmd("e " .. parent_dir .. "/section.tex")
        return
    end

    local path = require("pathlib")

    vim.fn.mkdir(parent_dir .. "/plots", "p")
    vim.fn.mkdir(parent_dir .. "/tikzpics", "p")
    vim.fn.mkdir(parent_dir .. "/data", "p")

    tmp = path("~/.config/notes/section_makefile")
    tmp:copy(path(parent_dir .. "/Makefile"))

    tmp = path("~/.config/notes/section_header.tex")
    tmp:copy(path(parent_dir .. "/section_header.tex"))

    if vim.fn.bufloaded(parent_dir .. "/section.tex") == 0 then
        vim.cmd("e " .. parent_dir .. "/section.tex")
        vim.cmd("norm ibsec ")
        require("luasnip").expand()
    else
        vim.cmd("e " .. parent_dir .. "/section.tex")
    end

end

M._init_syllabus = function(parent_dir)

    local tmp = io.open(parent_dir .. "/syllabus.tex", "r")
    if tmp then
        local content = tmp:read()
        tmp:close()
        if content and content ~= "" then
            vim.cmd("e " .. parent_dir .. "/syllabus.tex")
            return
        end
    end

    if vim.fn.bufloaded(parent_dir .. "/syllabus.tex") == 0 then
        vim.cmd("e " .. parent_dir .. "/syllabus.tex")
        vim.cmd("norm ibsyl ")
        require("luasnip").expand()
    else
        vim.cmd("e " .. parent_dir .. "/syllabus.tex")
    end

end

M._jump_to_file = function(parent_dir, file_base)

    local path = require("pathlib")
    local tmp

    tmp = path(parent_dir .. "/" .. file_base .. ".tex")
    tmp:touch(nil, true)

    vim.cmd("e " .. parent_dir .. "/" .. file_base .. ".tex")
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

        sub_file_parent = vim.fn.resolve(
            cur_file_parent .. "/" .. sub_file_parent
        )

        sub_file_parent = sub_file_parent:gsub("%.tex$", "")
        sub_file_base = sub_file_parent:gsub("^.*/", "")
        sub_file_parent = sub_file_parent:gsub("/[^/]-$", "")

        print("Intializing: Spawning Rexes, Wrapping Raptors, Polishing Ceratops...")

        if cur_file_base == "course" then
            if sub_file_base == "chapter" then
                M._init_chapter(sub_file_parent)
                return
            elseif sub_file_base == "work" then
                M._init_work(sub_file_parent)
                return
            end
        elseif cur_file_base == "chapter" then
            if sub_file_base == "section" then
                M._init_section(sub_file_parent)
                return
            elseif sub_file_base == "syllabus" then
                M._init_syllabus(sub_file_parent)
                return
            end
        elseif cur_file_base == "work" then
            if sub_file_base == "section" then
                M._init_section(sub_file_parent)
                return
            end
        end

        print("Teleporting: Here we go...")
        M._jump_to_file(sub_file_parent, sub_file_base)
        -- chapter.tex, section.tex, work.tex, syllabus.tex, abstract.tex
        return
    end

    if cur_node:type() == "graphics_include" then

        local file_name = cur_node:field("path")[1]

        if file_name and file_name:type() == "curly_group_path" then
            file_name = file_name:named_child(0)
        end

        if file_name then

            file_name = M._get_text(file_name)[1]

            if file_name:sub(-4, -1) == ".pdf" then

                local parent_dir = vim.fn.expand("%:p")

                parent_dir = parent_dir:gsub("/[^/]*$", "")

                file_name = file_name:sub(1, -4) .. "tex"

                M._init_tikzpic(parent_dir .. "/" .. file_name)
            end

        end

        -- do the thing
        -- then return
    end


end

return M
