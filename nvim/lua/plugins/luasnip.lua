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

            -- vim.keymap.set({"i", "s"}, "<C-L>", function() ls.jump( 1) end, {silent = true})
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
            -- local c = ls.choice_node
            -- local d = ls.dynamic_node
            -- local r = ls.restore_node
            --
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

            ls.add_snippets("all", {
                s("def", {
                    t("def "),
                    i(1),

                    t(" ("),
                    f(get_first_arg, nil),

                    i(2),
                    t(") -> "),
                    i(3, "None"),
                    t({":", "\t"}),
                    i(0),
                    t({"", "\t"}),
                    t("return"),
                }),

                s("vr", {
                    i(1),
                    t(": "),
                    i(0),
                }),

                s("cls", {
                    t("class "),
                    i(1),
                    t(" ("),
                    i(0),
                    t("):"),
                }),

            })

        end
    }
}
