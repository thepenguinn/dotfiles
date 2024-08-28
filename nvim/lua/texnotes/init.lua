local M = {}

M.tikzpics_dir = "tikzpics"

M._get_text = function (node)

    local start_row, start_col, end_row, end_col

    start_row, start_col, end_row, end_col = node:range()
    -- print(start_row, start_col, end_row, end_col)
    local text = vim.api.nvim_buf_get_text(
        0, start_row, start_col, end_row, end_col, {}
    )

    return text
end

M._init_tikzpic = function(parent_dir, file_name)

    local path = require("pathlib")
    local file_path = parent_dir .. "/" .. file_name

    local file = path(file_path)

    if not file:is_file() then

        file:touch(nil, true)

        local pre_cwd = vim.loop.cwd()
        local cur_file_dir = vim.fn.expand("%:p")
        cur_file_dir = cur_file_dir:gsub("/[^/]*$", "")

        vim.loop.chdir(vim.fn.resolve(cur_file_dir))

        print("Adding file to Lunatikz: " .. file_name)
        vim.system({"lunatikz", "add", file_path})

        vim.loop.chdir(pre_cwd)

        print("Intializing: Spawning Rexes, Wrapping Raptors, Polishing Ceratops...")
        vim.cmd("e " .. file_path)
        vim.cmd("norm ibpic ")
        require("luasnip").expand()
    else
        vim.cmd("e " .. file_path)
    end

end

M._init_chapter = function(parent_dir)

    local path = require("pathlib")
    local chp = io.open(parent_dir .. "/chapter.tex", "r")
    local tmp
    local content

    if not chp then

        vim.fn.mkdir(parent_dir .. "/plots", "p")
        vim.fn.mkdir(parent_dir .. "/tikzpics", "p")
        vim.fn.mkdir(parent_dir .. "/data", "p")

        tmp = path("~/.config/notes/chapter_makefile")
        tmp:copy(path(parent_dir .. "/Makefile"))

        tmp = path(parent_dir .. "/syllabus.tex")
        tmp:touch()

        tmp = path(parent_dir .. "/chapter.tex")
        tmp:touch()

        vim.system(
            {"lunatikz", "add", "--build-entry", "chapter.tex"},
            {cwd = parent_dir}
        )

    else
        content = chp:read()
        chp:close()
    end

    print("") -- clears the msg
    vim.cmd("e " .. parent_dir .. "/chapter.tex")

    if not content then
        vim.cmd("norm ibchp ")
        require("luasnip").expand()
    end

end

M._init_work = function(parent_dir)

    local path = require("pathlib")
    local wrk = io.open(parent_dir .. "/work.tex", "r")
    local tmp
    local content

    if not wrk then

        vim.fn.mkdir(parent_dir .. "/plots", "p")
        vim.fn.mkdir(parent_dir .. "/tikzpics", "p")
        vim.fn.mkdir(parent_dir .. "/data", "p")

        tmp = path("~/.config/notes/work_makefile")
        tmp:copy(path(parent_dir .. "/Makefile"))

        tmp = path("~/.config/notes/work_header.tex")
        tmp:copy(path(parent_dir .. "/work_header.tex"))

        tmp = path("~/.config/notes/abstract.tex")
        tmp:copy(path(parent_dir .. "/abstract.tex"))

        tmp = path(parent_dir .. "/work.tex")
        tmp:touch()

        vim.system(
            {"lunatikz", "add", "--build-entry", "work.tex"},
            {cwd = parent_dir}
        )

    else
        content = wrk:read()
        wrk:close()
    end

    print("") -- clears the msg
    vim.cmd("e " .. parent_dir .. "/work.tex")

    if not content then
        vim.cmd("norm ibwrk ")
        require("luasnip").expand()
    end

end

M._init_section = function(parent_dir)

    local path = require("pathlib")
    local sec = io.open(parent_dir .. "/section.tex", "r")
    local tmp
    local content

    if not sec then

        vim.fn.mkdir(parent_dir .. "/plots", "p")
        vim.fn.mkdir(parent_dir .. "/tikzpics", "p")
        vim.fn.mkdir(parent_dir .. "/data", "p")

        tmp = path("~/.config/notes/section_makefile")
        tmp:copy(path(parent_dir .. "/Makefile"))

        tmp = path("~/.config/notes/section_header.tex")
        tmp:copy(path(parent_dir .. "/section_header.tex"))

        tmp = path(parent_dir .. "/section.tex")
        tmp:touch()

        vim.system(
            {"lunatikz", "add", "--build-entry", "section.tex"},
            {cwd = parent_dir}
        )

    else
        content = sec:read()
        sec:close()
    end

    print("") -- clears the msg
    vim.cmd("e " .. parent_dir .. "/section.tex")

    if not content then
        vim.cmd("norm ibsec ")
        require("luasnip").expand()
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

                M._init_tikzpic(parent_dir, file_name)
            end

        end

        -- do the thing
        -- then return
    end


end

M.view_binary = function()

    local cur_node = M.get_node()

    if not cur_node then
        print("Not in graphics_include")
        return
    end

    if cur_node:type() == "graphics_include" then

        local file_name = cur_node:field("path")[1]
        local tmp
        local parent_dir = vim.fn.expand("%:p")

        parent_dir = parent_dir:gsub("/[^/]*$", "")

        if file_name and file_name:type() == "curly_group_path" then
            file_name = file_name:named_child(0)
        end

        if file_name then

            file_name = M._get_text(file_name)[1]

            if file_name ~= "" then

                file_name = parent_dir .. "/" .. file_name
                tmp = io.open(file_name)
                if tmp then
                    tmp:close()
                    vim.system({"termux-share", "-d", file_name})
                    print("Opening " .. file_name)
                else
                    print("File doesn't exist: " .. file_name)
                end

            end

        end

    end

end

M.new_tikzpic = function ()

    vim.ui.input(
        { prompt = "Tikzpic Name: " },
        function (input)

            local path = require("pathlib")

            local parent_dir = vim.fn.expand("%:p")
            local parent_just_above

            parent_dir = parent_dir:gsub("/[^/]*$", "")
            parent_just_above = parent_dir:gsub("^.*/", "")

            if not input or input == "" then
                print("No inputs given, bailing out...")
                return
            end

            if not input:match("%.tex$") then
                input = input .. ".tex"
            end

            local file
            local input_parent

            if input:match("/") then
                -- relative
                input_parent = input:gsub("/[^/]*$", "")
                input = input:gsub("^.*/", "")
                parent_dir = parent_dir .. "/" .. input_parent
            else
                if parent_just_above ~= M.tikzpics_dir then
                    parent_dir = parent_dir .. "/" .. M.tikzpics_dir
                end
            end

            parent_dir = vim.fn.resolve(parent_dir)
            parent_dir = path(parent_dir)

            if not parent_dir:is_dir() then
                local yes = vim.fn.input("Do you want to create: " .. tostring(parent_dir) .. " ?(y/n): " )
                if yes ~= "y" then
                    return
                end

                parent_dir:mkdir(nil, true)

            end

            file = path(tostring(parent_dir) .. "/" .. input)
            if not file:is_file() then
                vim.cmd("e " .. tostring(file))
                vim.cmd("norm ibpic ")
                require("luasnip").expand()
            else
                vim.cmd("e " .. tostring(file))
            end

        end
    )

end

M.build_and_view_tikzpic = function()

    local cur_node = M.get_node()

    if not cur_node or cur_node:type() ~= "graphics_include" then
        print("Not inside graphics_include")
        return
    end

    local file_name = cur_node:field("path")[1]
    local tex_file_name


    if file_name and file_name:type() == "curly_group_path" then
        file_name = file_name:named_child(0)
    end

    if file_name then

        file_name = M._get_text(file_name)[1]

        if file_name:sub(-4, -1) == ".pdf" then

            local parent_dir = vim.fn.expand("%:p")

            parent_dir = parent_dir:gsub("/[^/]*$", "")

            tex_file_name = file_name:sub(1, -4) .. "tex"

            -- build the entire tex file and then view the current file
            local cur_file_dir = vim.fn.expand("%:p")

            -- assuming we are not in a tikzpic file
            cur_file_dir = cur_file_dir:gsub("/[^/]*$", "")
            -- if we need this to work, we should add the default build-entry for the cur_file_dir
            print("Building pics for " .. cur_file_dir .. "...")
            vim.system(
                {"lunatikz", "build"},
                {cwd = cur_file_dir, text = true},
                function (obj)

                    if obj.code == 0 then
                        print("Lunatikz ran successfully, opening " .. parent_dir .. "/" .. file_name)
                        vim.system({"termux-share", "-d", parent_dir .. "/" .. file_name})
                    else
                        vim.schedule(function ()
                            vim.api.nvim_echo({{obj.stdout .. obj.stderr}}, true, {})
                        end)
                    end

                end
            )

        end

    end

end

return M
