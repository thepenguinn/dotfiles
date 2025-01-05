local M = {}

M.tikzpics_dir = "tikzpics"

M.local_config = nil
M.global_config = nil
M.config = nil
M.default_config = {
    -- base names for different files
    MAIN_FILE_BASE = "course",
    CHAPTER_FILE_BASE = "chapter",
    WORK_FILE_BASE = "work",
    SECTION_FILE_BASE = "section",
    SYLLABUS_FILE_BASE = "syllabus",
    ABSTRACT_FILE_BASE = "abstract",
}

M.load_local_config = function ()
    local path = require("pathlib")
    -- local parent_dir = vim.fn.expand("%:p")
    local parent_dir
    local local_config_file
    local tmp

    tmp = io.popen("pwd")
    if not tmp then
        return
    end

    parent_dir = tmp:read("a"):gsub("\n$", "")
    tmp:close()

    parent_dir = path(parent_dir)

    -- first arg --> pathlib dir
    -- returns --> pathlib config file, else nil
    local function find_local_config(dir)
        local config_file

        if not dir then
            return nil
        end

        -- looking for .lunatikz directory in the parent directories,
        -- because, it could the root directory of the project.

        if dir:child(".lunatikz"):is_dir() then
            config_file = dir:child("texno.config")
            if config_file:is_file() then
                return config_file
            else
                return nil
            end
        else
            return find_local_config(dir:parent())
        end
    end

    local_config_file = find_local_config(parent_dir)

    if local_config_file then
        return dofile(tostring(local_config_file)) or {}
    else
        return {}
    end

end

M.local_config = M.load_local_config()
setmetatable(M.local_config, {
    __index = M.default_config,
})
M.config = M.local_config

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
    local chp = io.open(parent_dir .. "/" .. M.config.CHAPTER_FILE_BASE .. ".tex", "r")
    local tmp
    local content

    if not chp then

        vim.fn.mkdir(parent_dir .. "/plots", "p")
        vim.fn.mkdir(parent_dir .. "/tikzpics", "p")
        vim.fn.mkdir(parent_dir .. "/data", "p")

        tmp = path("~/.config/notes/" .. M.config.MAIN_FILE_BASE .. "/chapter_makefile")
        tmp:copy(path(parent_dir .. "/Makefile"))

        tmp = path(parent_dir .. "/" .. M.config.SYLLABUS_FILE_BASE .. ".tex")
        tmp:touch()

        tmp = path(parent_dir .. "/" .. M.config.CHAPTER_FILE_BASE .. ".tex")
        tmp:touch()

        vim.system(
            {"lunatikz", "add", "--build-entry", M.config.CHAPTER_FILE_BASE .. ".tex"},
            {cwd = parent_dir}
        )

    else
        content = chp:read()
        chp:close()
    end

    print("") -- clears the msg
    vim.cmd("e " .. parent_dir .. "/" .. M.config.CHAPTER_FILE_BASE .. ".tex")

    if not content then
        vim.cmd("norm ibchp ")
        require("luasnip").expand()
    end

end

M._init_work = function(parent_dir)

    local path = require("pathlib")
    local wrk = io.open(parent_dir .. "/" .. M.config.WORK_FILE_BASE .. "work.tex", "r")
    local tmp
    local content

    if not wrk then

        vim.fn.mkdir(parent_dir .. "/plots", "p")
        vim.fn.mkdir(parent_dir .. "/tikzpics", "p")
        vim.fn.mkdir(parent_dir .. "/data", "p")

        tmp = path("~/.config/notes/" .. M.config.MAIN_FILE_BASE .. "/work_makefile")
        tmp:copy(path(parent_dir .. "/Makefile"))

        tmp = path("~/.config/notes/work_header.tex")
        tmp:copy(path(parent_dir .. "/work_header.tex"))

        tmp = path("~/.config/notes/abstract.tex")
        tmp:copy(path(parent_dir .. "/" .. M.config.ABSTRACT_FILE_BASE .. ".tex"))

        tmp = path(parent_dir .. "/" .. M.config.WORK_FILE_BASE .. ".tex")
        tmp:touch()

        vim.system(
            {"lunatikz", "add", "--build-entry", M.config.WORK_FILE_BASE .. ".tex"},
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

M._init_abstract = function(parent_dir)
    local path = require("pathlib")
    local abt = io.open(parent_dir .. "/abstract.tex", "r")
    local content

    if not abt then
        print(parent_dir .. "/abstract.tex does not exists.")
    else
        content = abt:read()
        abt:close()
    end

    vim.cmd("e " .. parent_dir .. "/" .. M.config.ABSTRACT_FILE_BASE .. ".tex")

    if not content then
        vim.cmd("norm ibabt ")
        require("luasnip").expand()
    end
end

M._init_section = function(parent_dir)

    local path = require("pathlib")
    local sec = io.open(parent_dir .. "/" .. M.config.SECTION_FILE_BASE .. ".tex", "r")
    local tmp
    local content

    if not sec then

        vim.fn.mkdir(parent_dir .. "/plots", "p")
        vim.fn.mkdir(parent_dir .. "/tikzpics", "p")
        vim.fn.mkdir(parent_dir .. "/data", "p")

        tmp = path("~/.config/notes/" .. M.config.MAIN_FILE_BASE .. "/section_makefile")
        tmp:copy(path(parent_dir .. "/Makefile"))

        tmp = path("~/.config/notes/section_header.tex")
        tmp:copy(path(parent_dir .. "/section_header.tex"))

        tmp = path(parent_dir .. "/" .. M.config.SECTION_FILE_BASE .. ".tex")
        tmp:touch()

        vim.system(
            {"lunatikz", "add", "--build-entry", M.config.SECTION_FILE_BASE .. ".tex"},
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

    local tmp = io.open(parent_dir .. "/" .. M.config.SYLLABUS_FILE_BASE .. ".tex", "r")
    if tmp then
        local content = tmp:read()
        tmp:close()
        if content and content ~= "" then
            vim.cmd("e " .. parent_dir .. "/" .. M.config.SYLLABUS_FILE_BASE .. ".tex")
            return
        end
    end

    if vim.fn.bufloaded(parent_dir .. "/" .. M.config.SYLLABUS_FILE_BASE .. ".tex") == 0 then
        vim.cmd("e " .. parent_dir .. "/" .. M.config.SYLLABUS_FILE_BASE .. ".tex")
        vim.cmd("norm ibsyl ")
        require("luasnip").expand()
    else
        vim.cmd("e " .. parent_dir .. "/" .. M.config.SYLLABUS_FILE_BASE .. ".tex")
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

M.jump_to_sub_pic = function()
    local line = vim.api.nvim_get_current_line()
    -- local cur_node = vim.treesitter.get_node()
    local tmp_fd
    local root_dir = vim.fn.expand("%:p"):gsub("/[^/]*$", "")
    local dep_list

    while root_dir ~= "" do
        tmp_fd = io.open(root_dir .. "/.lunatikz/dep_list", "r")
        if tmp_fd then
            tmp_fd:close()
            dep_list = dofile(root_dir .. "/.lunatikz/dep_list")
            break
        end
        root_dir = root_dir:gsub("/[^/]*$", "")
    end

    if not dep_list then
        return false
    end

    -- for k, v in pairs(dep_list) do
    --     print(k, v)
    -- end
    local sub_pic_name
    local sub_pic_parent

    for macro in line:gmatch("\\([%w%-_]*)") do
        if dep_list[macro] then
            sub_pic_name = macro
            sub_pic_parent = dep_list[macro].parent_dir
            break
        end
    end

    if not sub_pic_name then
        return false
    end

    local col = line:find(sub_pic_name) - 1
    local row = vim.api.nvim_win_get_cursor(0)[1]

    vim.api.nvim_win_set_cursor(0, {row, col})
    print("Opening PROJECT_ROOT:" .. sub_pic_parent .. "/" .. sub_pic_name .. ".tex")
    vim.cmd("e " .. root_dir .. "/" .. sub_pic_parent .. "/" .. sub_pic_name .. ".tex")

    return true
end

M.jump = function()

    local cur_node = M.get_node()

    if not cur_node then
        if not M.jump_to_sub_pic() then
            print("press <cr>")
        end
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

        if cur_file_base == M.config.MAIN_FILE_BASE then
            if sub_file_base == M.config.CHAPTER_FILE_BASE then
                M._init_chapter(sub_file_parent)
                return
            elseif sub_file_base == M.config.WORK_FILE_BASE then
                M._init_work(sub_file_parent)
                return
            elseif sub_file_base == M.config.ABSTRACT_FILE_BASE then
                M._init_abstract(sub_file_parent)
                return
            end
        elseif cur_file_base == M.config.CHAPTER_FILE_BASE then
            if sub_file_base == M.config.SECTION_FILE_BASE then
                M._init_section(sub_file_parent)
                return
            elseif sub_file_base == M.config.SYLLABUS_FILE_BASE then
                M._init_syllabus(sub_file_parent)
                return
            end
        elseif cur_file_base == M.config.WORK_FILE_BASE then
            if sub_file_base == M.config.SECTION_FILE_BASE then
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

                parent_dir:mkdir(path.permission("rwx------"), true)

            end

            file = path(tostring(parent_dir) .. "/" .. input)
            if not file:is_file() then

                vim.system({"touch", tostring(file)})

                vim.cmd("e " .. tostring(file))

                vim.cmd("norm ibpic ")
                require("luasnip").expand()

                vim.system(
                    {"lunatikz", "add", tostring(file)},
                    {cwd = tostring(parent_dir)},
                    nil
                )

            else
                vim.cmd("e " .. tostring(file))
            end

        end
    )

end

M.build_and_view_tikzpic = function()

    local file_name
    local parent_dir
    local parent_just_above

    file_name = vim.fn.expand("%:p")
    parent_dir = file_name:gsub("/[^/]*$", "")

    parent_just_above = parent_dir:gsub("^.*/", "")

    if parent_just_above == M.tikzpics_dir then
        parent_dir = parent_dir:gsub("/[^/]*$", "")
        file_name = M.tikzpics_dir .. "/" .. file_name:gsub("^.*/", "")
        file_name = file_name:gsub("%.tex$", ".pdf")
    else
        local cur_node = M.get_node()

        if not cur_node or cur_node:type() ~= "graphics_include" then
            print("Not inside graphics_include")
            return
        end

        local file_name = cur_node:field("path")[1]

        if file_name and file_name:type() == "curly_group_path" then
            file_name = file_name:named_child(0)
        else
            print("Couldn't find the pdf name.")
            return
        end

        file_name = M._get_text(file_name)[1]

        if not file_name or file_name == "" or file_name:sub(-4, -1) ~= ".pdf" then
            print("Not a valid pdf name")
            return
        end

    end

    local file_path = parent_dir .. "/" .. file_name

    -- if we need this to work, we should add the default build-entry for the parent_dir
    print("Building pics for " .. parent_dir .. "...")
    vim.system(
        {"lunatikz", "build"},
        {cwd = parent_dir, text = true},
        function (obj)

            local path = require("pathlib")
            local tmp

            if obj.code == 0 then

                tmp = path(file_path)

                if tmp:is_file() then
                    print("Lunatikz ran successfully, opening " .. file_path)
                    vim.system({"termux-share", "-d", file_path})
                else
                    print("Lunatikz ran successfully, but pdf doesn't exist " .. file_path)
                end

            else
                vim.schedule(function ()
                    vim.api.nvim_echo({{obj.stdout .. obj.stderr}}, true, {})
                end)
            end

        end
    )

end



return M
