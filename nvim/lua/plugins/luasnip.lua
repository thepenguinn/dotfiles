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
            -- local d = ls.dynamic_node
            -- local r = ls.restore_node
            local fmt = require("luasnip.extras.fmt").fmt
            local rep = require("luasnip.extras").rep
            --
            local function copy (st)
                return st[0]
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

            })

        end
    }
}
