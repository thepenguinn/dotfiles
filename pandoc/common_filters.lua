return {
    {
        Math = function (math_obj)

            if math_obj["mathtype"] == "InlineMath" then
                math_obj.text = math_obj.text:gsub("\\\\", "\\")
            end

            return math_obj

        end,
    }
}
