return {
    {
        "L3MON4D3/LuaSnip",
        -- follow latest release.
        -- Replace <CurrentMajor> by the latest released major (first number of latest release)
        version = "v2.*",
        -- install jsregexp (optional!).
        build = "make install_jsregexp",

        config = function ()
            local ls = require("luasnip")

            vim.keymap.set({"i", "s"}, "<C-K>", function()
                if ls.expand_or_jumpable() then
                    ls.expand_or_jump()
                end
            end,
                {silent = true}
            )

            vim.keymap.set({"i", "s"}, "<C-J>", function() ls.jump(-1) end, {silent = true})

            vim.keymap.set({"i", "s"}, "<C-L>", function()
                if ls.choice_active() then
                    ls.change_choice(1)
                end
            end, {silent = true})

            ls.config.set_config({
                updateevents = "TextChanged,TextChangedI",
            })

            -- TESTING SNIPPETS --

            local s = ls.snippet
            local sn = ls.snippet_node
            local t = ls.text_node
            local i = ls.insert_node
            local f = ls.function_node
            local c = ls.choice_node
            local events = require("luasnip.util.events")
            -- local d = ls.dynamic_node
            -- local r = ls.restore_node
            local fmt = require("luasnip.extras.fmt").fmt
            local rep = require("luasnip.extras").rep
            --
            local function copy (st)
                return st[1]
            end

            local function get_first_arg ()

                local pnode
                local node = vim.treesitter.get_node()

                if node:type() == "class_definition" then
                    return "self"

                elseif node:type() == "block" then
                    node = node:parent()
                    if node and node:type() == "class_definition" then
                        return "self"
                    end
                end

                pnode = node

                while true
                do
                    if pnode == nil then
                        break
                    elseif pnode:type() == "function_definition" then
                        break
                    end
                    pnode = pnode:parent()
                end

                if pnode then
                    pnode = pnode:parent()
                    if pnode and pnode:type() == "block" then
                        pnode = pnode:parent()
                        if pnode and pnode:type() == "class_definition" then
                            return "self"
                        end
                    end

                end

                return ""
            end

            -- Apparently we don't need this
            local function create_norg_dir()
                local node = vim.treesitter.get_node()
                node = node:parent()
                node = node:child(0)
                node = node:named_child(0)

                if node:type() == "link_file_text" then

                    local line, col_start = node:start()
                    local _, col_end = node:end_()

                    local rel_file_name = vim.api.nvim_buf_get_text(
                        0, line, col_start, line, col_end, {}
                    )[1]

                    local parent_dir = vim.api.nvim_buf_get_name(0)

                    if string.match(rel_file_name, "^/.*") or parent_dir == nil or parent_dir == "" then
                        return
                    end

                    parent_dir = string.gsub(parent_dir, "/[^/]+$", "")
                    local rel_dir = string.gsub(rel_file_name, "/[^/]+$", "")

                    vim.fn.mkdir(parent_dir .. "/" .. rel_dir, "p")

                end
            end

            local function norg_meta_get_date()
                return os.date("%Y-%m-%dT%H:%M:%S+0530")
            end

            local function norg_create_desc(args)
                local title = string.lower(args[1][1])

                local all_cate = {}
                local cat = ""

                for _, line in ipairs(args[2]) do
                    local tcate = string.gsub(line, "^ *", "")
                    tcate = string.gsub(tcate, " *$", "")
                    tcate = string.gsub(tcate, " +", " ")
                    tcate = vim.split(tcate , " ", {plain = true})

                    for _, cate in ipairs(tcate) do
                        if not string.match(cate, "^ *$") then
                            all_cate[#all_cate + 1] = cate
                        end
                    end
                end

                if #all_cate == 1 then
                    cat = " " .. all_cate[1]
                elseif #all_cate == 2 then
                    cat = " " .. all_cate[1] .. ", and " .. all_cate[2]
                elseif #all_cate > 2 then
                    cat = " " .. all_cate[1]
                    for i = 2, #all_cate - 1 do
                        cat = cat .. ", " .. all_cate[i]
                    end
                    cat = cat .. ", and " .. all_cate[#all_cate]
                end

                if cat ~= "" then
                    cat = " (" .. cat .. " )"
                end

                return title .. cat
            end

            local function norg_get_mod_num()
                local node = vim.treesitter.get_node()

                if node:type() == "document" then
                    return "1"
                elseif node:type() == "heading1" then
                    node = node:named_child(3) -- paragraph
                    if node == nil then return "" end

                    node = node:named_child(0) -- paragraph_segment
                    if node == nil then return "" end
                    node = node:named_child(0) -- link
                    if node == nil then return "" end
                    node = node:named_child(0) -- link_location
                    if node == nil then return "" end
                    node = node:named_child(0) -- link_file_text
                    if node == nil then return "" end

                    if node:type() == "link_file_text" then
                        local line, col_start = node:start()
                        local _, col_end = node:end_()

                        local pre_idx = vim.api.nvim_buf_get_text(
                            0, line, col_start, line, col_end, {}
                        )[1]

                        pre_idx = vim.split(pre_idx, "_")
                        pre_idx = pre_idx[#pre_idx]

                        if pre_idx then
                            -- hopefull it will be a number
                            -- notes_mod_<number>
                            pre_idx = tonumber(pre_idx)
                            return tostring(pre_idx + 1)
                        end

                    end

                end
            end

            local function norg_tangle_file(arg)
                local splited_path
                if arg[1] ~= "" then
                    splited_path = vim.split(arg[1][1] , "/", {plain = true})
                    return splited_path[#splited_path]
                end

                return ""
            end

            local function tex_get_figure_options(args)
                if args[1][1] == "figure" then
                    return { "    \\centering", ""}
                else
                    return ""
                end
            end

            ls.add_snippets("python", {

                s("shit", fmt("just something \nelse {here}", {
                    here = t("hai")
                })),

                s("adef", fmt(
                    "async def {func_name} ({first_arg}{more_args}) -> {return_type}:\n\t{func_body}\n\t{return_statement}",
                    {
                        func_name = i(1),
                        first_arg = f(get_first_arg, nil),
                        more_args = i(2),
                        return_type = i(3, "None"),
                        func_body = i(0),
                        return_statement = c(4, {t("return"), t("")})
                    }
                )),

                s("def", fmt(
                    "def {func_name} ({first_arg}{more_args}) -> {return_type}:\n\t{func_body}\n\t{return_statement}",
                    {
                        func_name = i(1),
                        first_arg = f(get_first_arg, nil),
                        more_args = i(2),
                        return_type = i(3, "None"),
                        func_body = i(0),
                        return_statement = c(4, {t("return"), t("")})
                    }
                )),

                s("vr", {
                    i(1),
                    t(": "),
                    i(0),
                }),

                s("cls", fmt("class {class_name} ({super_classes}):\n\t{class_body}", {
                    class_name = i(1),
                    super_classes = i(2),
                    class_body = i(0)

                })),

            })

            ls.add_snippets("tex", {

                s("bl", fmt(
                    "\\begin{{{block_name_begin}}}{optional_args}\n"
                    .. "\t{block_body}\n"
                    .. "\\end{{{block_name_end}}}",
                    {
                        block_name_begin = i(1),
                        optional_args = c(2, {
                            t(""),
                            sn(nil, { t(" ["), i(1), t("]") })
                        }),
                        block_body = i(0),
                        block_name_end = rep(1),
                    })),

                s("sctk", fmt(
                    "\\ctikzsubcircuitdef{{{subctk_def_name}}} {{\n"
                    .. "\torigin{subctk_anchors}%\n"
                    .. "}} {{\n"
                    .. "\tcoordinate (#1-origin)\n"
                    .. "\t{subctk_body}\n"
                    .. "}}\n"
                    .. "\n"
                    .. "\\ctikzsubcircuitactivate{{{subctk_act_name}}}\n",
                    {
                        subctk_def_name = i(1),
                        subctk_anchors = i(2),
                        subctk_body = i(0),
                        subctk_act_name = rep(1)
                    })),

                s("wtin", fmt(
                    "node ({node_name}) [{optional_node_args}] {{\n"
                    .. "\t\\begin{{tikzpicture}} [{optional_tikz_args}]\n"
                    .. "\t\t\\draw [{optional_draw_args}]\n"
                    .. "\t\t{draw_body}\n"
                    .. "\t\t;\n"
                    .. "\t\\end{{tikzpicture}}\n"
                    .. "}}",
                    {
                        node_name = i(1, "#1"),
                        optional_node_args = c(2, {
                            sn(nil, fmt("inner sep = {inner_sep}, anchor = center", {
                                inner_sep = i(1, "0pt"),
                            })),
                            i(nil),
                        }),
                        optional_tikz_args = i(3),
                        optional_draw_args = i(4),
                        draw_body = i(0),
                    })),

                s("ncmd", fmt(
                    "\\newcommand\\{command_name} [{arg_count}] {{\n"
                    .. "\t{command_body}\n"
                    .. "}}",
                    {
                        command_name = i(1),
                        arg_count = i(2, "1"),
                        command_body = i(0),
                    })),

                s("bcrs", fmt(
                    "\\documentclass[11pt] {{report}}\n"
                    .. "\n"
                    .. "\\input{{preamble.tex}}\n"
                    .. "\n"
                    .. "\\title{{{course_title}}}\n"
                    .. "\n"
                    .. "\\begin{{document}}\n"
                    .. "\n"
                    .. "%% \\maketitle\n"
                    .. "%% \\tableofcontents\n"
                    .. "\n"
                    .. "{course_end}\n"
                    .. "\n"
                    .. "\\end{{document}}\n"
                    ,
                    {
                        course_title = i(1, "An Interesting Title"),
                        course_end = i(0),

                    })),


                s("bchp", fmt(
                    "\\documentclass[../course]{{subfiles}}\n"
                    .. "\n"
                    .. "\\begin{{document}}\n"
                    .. "\n"
                    .. "\\chapter{{{chapter_title}}}\n"
                    .. "\n"
                    .. "\\subfile{{syllabus.tex}}\n"
                    .. "\n"
                    .. "{chapter_end}\n"
                    .. "\n"
                    .. "\\end{{document}}\n"
                    ,
                    {
                        chapter_title = i(1, "An Interesting Title"),
                        chapter_end = i(0),
                    })),

                s("bsyl", fmt(
                    "\\documentclass[../course]{{subfiles}}\n"
                    .. "\n"
                    .. "\\begin{{document}}\n"
                    .. "\n"
                    .. "\\section{{{syllabus_title}}}\n"
                    .. "\n"
                    .. "{syllabus_end}\n"
                    .. "\n"
                    .. "\\end{{document}}\n"
                    ,
                    {
                        syllabus_title = i(1, "Syllabus"),
                        syllabus_end = i(0),
                    })),

                s("bsec", fmt(
                    "\\documentclass[../../course]{{subfiles}}\n"
                    .. "\n"
                    .. "\\begin{{document}}\n"
                    .. "\n"
                    .. "\\section{{{section_title}}}\n"
                    .. "\n"
                    .. "{section_end}\n"
                    .. "\n"
                    .. "\\end{{document}}\n"
                    ,
                    {
                        section_title = i(1),
                        section_end = i(0),
                    })),

                s("cbp", fmt(
                    "%{minted_tangle_file}%\n"
                    .. "\\begin{{minted}}[{minted_optionals}] {{python}}\n"
                    .. "    {minted_end}\n"
                    .. "\\end{{minted}}\n"
                    ,
                    {
                        minted_tangle_file = i(1),
                        minted_optionals = i(2, "breaklines"),
                        minted_end = i(0),

                    })),

                s("mb", fmt(
                    "\\begin{{align}}\n"
                    .. "    {math_end}\n"
                    .. "\\end{{align}}\n"
                    ,
                    {
                        math_end = i(0),

                    })),

                s("igx", { c(1, {
                    sn(nil, fmt(
                        "\\begin{{{wrap_begin}}}\n"
                        .. "{figure_options}"
                        .. "    \\adjustbox{{max width = {max_width}}}\n"
                        .. "        \\includegraphics[height = {max_height}] {{{image}}}\n"
                        .. "    }}\n"
                        .. "    \\captionof {{figure}} {{{caption}}}\n"
                        .. "\\end{{{wrap_end}}}\n"
                        .. "\n"
                        .. "{include_end}"
                        ,
                        {
                            wrap_begin = c(1, {i(nil, "center"), i(nil,  "figure"), i(nil)}),
                            figure_options = f(tex_get_figure_options, { 1 }),
                            max_width = c(2, {
                                i(nil, "0.7\\textwidth"),
                                sn(nil, {i(1, "0.7"), t("\\textwidth")}),
                                i(nil),
                            }),
                            max_height = c(3, {
                                i(nil, "0.8\\textheight"),
                                sn(nil, {i(1, "0.8"), t("\\textheight")}),
                                i(nil),
                            }),
                            image = i(4),
                            caption = i(5),
                            wrap_end = rep(1),
                            include_end = i(0)

                        })),
                    sn(nil, fmt(
                        "\\includegraphics[{options}] {{{image}}}\n"
                        .. "\n"
                        .. "{include_end}"
                        ,
                        {
                            options = i(1),
                            image = i(2),
                            include_end = i(0),
                        })),
                })
                }),

            })

            ls.add_snippets("norg", {

                s("ncl", fmt(
                    "{{:{dirctory_name}/index:}}[{link_name}] notes\n"
                    .. "{link_end}",
                    {
                        dirctory_name = i(1),
                        link_name = i(2),
                        link_end = i(0),
                    })
                ),

                s("meta", fmt(
                    "@document.meta\n"
                    .. "title: {title}\n"
                    .. "description: {description}\n"
                    .. "authors: Daniel\n"
                    .. "categories: [\n"
                    .. "\t{categories}\n"
                    .. "]\n"
                    .. "created: {created}\n"
                    .. "updated: {updated}\n"
                    .. "version: 1.1.1\n"
                    .. "@end\n\n{snip_end}"
                    ,
                    {
                        title = i(1),
                        description = c(2, {
                            f(norg_create_desc, { 1, 3 }),
                            f(function(args) return string.lower(args[1][1]) end, { 1 }),
                            i(nil)
                        }),
                        categories = i(3),
                        created = f(norg_meta_get_date, nil),
                        updated = f(norg_meta_get_date, nil),
                        snip_end = i(0),
                    })
                ),

                s("mod", fmt(
                    "* {module_number}\n"
                    .. "\n"
                    .. "** Syllabus\n"
                    .. "\n"
                    .. "   {{:syllabus_mod_{smodule_number}:}}[{smodule_name}] syllabus\n"
                    .. "\n"
                    .. "   ---\n"
                    .. "\n"
                    .. "  {{:notes_mod_{nmodule_number}:}}[{nmodule_name}] notes\n"
                    .. "\n"
                    .. "{snip_end}"
                    ,
                    {
                        module_number = i(1),
                        smodule_number = f(norg_get_mod_num, nil),
                        smodule_name = rep(1),
                        nmodule_number = f(norg_get_mod_num, nil),
                        nmodule_name = rep(1),
                        snip_end = i(0),

                    })
                ),

                s("cb", fmt(
                    "@code {lang}\n"
                    .. "{snip_end}\n"
                    .. "@end\n"
                    ,
                    {
                        lang = i(1),
                        snip_end = i(0),
                    })
                ),

                s("cbp", fmt(
                    "%{tangle_rel_path}%\n"
                    .. "#tangle {tangle_file}\n"
                    .. "@code python\n"
                    .. "{snip_end}\n"
                    .. "@end\n"
                    ,
                    {
                        tangle_file = f(norg_tangle_file, {1}),
                        tangle_rel_path = i(1),
                        snip_end = i(0),
                    })
                ),

                s("mb", fmt(
                    "@math\n"
                    .. "{snip_end}\n"
                    .. "@end\n"
                    ,
                    {
                        snip_end = i(0),
                    })
                ),
            })

        end
    }
}
