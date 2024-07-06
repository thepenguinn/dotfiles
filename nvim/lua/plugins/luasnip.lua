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

            -- TESTING SNIPPETS --

            local s = ls.snippet
            -- local sn = ls.snippet_node
            local t = ls.text_node
            local i = ls.insert_node
            local f = ls.function_node
            local c = ls.choice_node
            -- local d = ls.dynamic_node
            -- local r = ls.restore_node
            local fmt = require("luasnip.extras.fmt").fmt
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

        end
    }
}
