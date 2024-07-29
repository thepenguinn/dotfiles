return {
    {
        Math = function (display_math)
            local cleaned = display_math.text:gsub("\\mathhfill", "\\;\\;")
            cleaned = cleaned:gsub("\\hfill", "\\;\\;")
            display_math.text = cleaned
            return display_math
        end,

        Image = function (image)

            local tmp
            local lmodt_pdf
            local lmodt_svg

            local svg_file_name

            if image.src:match("%.pdf$") then
                tmp = io.open(image.src, "r")
                if tmp == nil then
                    return image
                end
                tmp:close()

                tmp = io.popen("stat --printf \"%Y\" " .. image.src)
                if tmp ~= nil then
                    lmodt_pdf = tmp:read()
                    lmodt_pdf = tonumber(lmodt_pdf)
                    tmp:close()
                else
                    return image
                end

                svg_file_name = image.src:gsub("%.pdf", ".svg")

                tmp = io.open(svg_file_name, "r")
                if tmp ~= nil then
                    tmp:close()

                    tmp = io.popen("stat --printf \"%Y\" " .. svg_file_name)
                    if tmp == nil then
                        return image
                    end

                    lmodt_svg = tmp:read()
                    lmodt_svg = tonumber(lmodt_svg)
                    tmp:close()

                    if lmodt_svg > lmodt_pdf then
                        -- do nothing, just replace image.src with svg_file_name
                        image.src = svg_file_name
                        return image
                    end
                end

                -- build the svg file
                os.execute("pdf2svg \"" .. image.src .. "\" \"" .. svg_file_name .. "\"")

                image.src = svg_file_name
                return image

            end
        end,
    }
}
