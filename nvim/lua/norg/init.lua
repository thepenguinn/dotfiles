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

M.get_node = function()

    local cur_node = vim.treesitter.get_node()

    local tmp_node = cur_node

    while tmp_node do
        if tmp_node:type():len() == 8 then
            if tmp_node:type():sub(1, 7) == "heading" then
                break
            end
        end

        if tmp_node:type() == "document" then tmp_node = nil
        else
            tmp_node = tmp_node:parent()
        end

    end

    if tmp_node then
        return tmp_node
    end

    -- could be nil or a valid node
    return tmp_node

end

M.get_heading_metadata = function (heading_node)

    if heading_node == nil then return end

    print(heading_node)

end

M.add_todo_schedule = function ()

    local cur_node = M.get_node()

    meta = {
        scheduled = {
            year = nil,
            month = nil,
            day = nil,
            start_hour = nil,
            start_minute = nil,
            end_hour = nil,
            end_minute = nil,
        },
        closed = {
            year = nil,
            month = nil,
            day = nil,
            hour = nil,
            minute = nil,
        },
        deadline = {
            year = nil,
            month = nil,
            day = nil,
            hour = nil,
            minute = nil,
        },
        cancelled = {
            year = nil,
            month = nil,
            day = nil,
            hour = nil,
            minute = nil,
        },
    }

    local meta = M.get_heading_metadata(cur_node)

end

return M
