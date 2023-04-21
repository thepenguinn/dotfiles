
local gethead = {}

function gethead.inject ()

	local notes_path
	local syllabus_path
	local pre_io_stream
	local new_io_stream

	notes_path = vim.api.nvim_buf_get_name(0)

	if not string.match(notes_path, "%.norg$") then
		return 1
	end

	syllabus_path = string.gsub(notes_path, "notes_mod_(%d+.norg)$", "syllabus_mod_%1")

	if notes_path == syllabus_path then
		return 1
	end

	pre_io_stream = io.input()
	new_io_stream = io.open(syllabus_path, "r")

	if not new_io_stream then
		return 1
	else
		io.input(new_io_stream)
	end

	local notes_head = {}
	local line

	line = io.read("l")

	while line == '' do
		line = io.read("l")
	end

	local line_num = 1
	local line_col = 0

	if line == "@document.meta" then
		local time = os.date("%Y-%m-%d")
		while line ~= "@end" and not string.match(line, "^ *%*+") do
			if string.match(line , "^description: ") then
				notes_head[#notes_head + 1] = string.gsub(line, "[Ss]yllabus$", "Notes")
			elseif string.match(line , "^categories: ") then
				notes_head[#notes_head + 1] = string.gsub(line, "[Ss]yllabus", "notes")
			elseif string.match(line , "^created: ") then
				notes_head[#notes_head + 1] = string.gsub(line, "%d+-%d+-%d+", time)
			elseif string.match(line , "^updated: ") then
				notes_head[#notes_head + 1] = string.gsub(line, "%d+-%d+-%d+", time)
			else
				notes_head[#notes_head + 1] = line
			end
			line_num = line_num + 1
			line = io.read("l")
		end

		notes_head[#notes_head + 1] = line
		line_num = line_num + 1
		line = io.read("l")
	end

	while line == '' do
		line_num = line_num + 1
		notes_head[#notes_head + 1] = line
		line = io.read("l")
	end

	line_col = math.floor(string.len(line) / 2)

	local pre_head = 0
	local cur_head
	local list_level

	--[[ local no_cap = {
		"and",
		"as",
		"as if",
		"as long as",
		"at",
		"but",
		"by",
		"even if",
		"for",
		"from",
		"if",
		"if only",
		"in",
		"into",
		"like",
		"near",
		"now that",
		"nor",
		"of",
		"off",
		"on",
		"on top of",
		"once",
		"onto",
		"or",
		"out of",
		"over",
		"past",
		"so",
		"so that",
		"than",
		"that",
		"till",
		"to",
		"up",
		"upon",
		"with",
		"when",
		"yet"
	}
	]]

	local function get_cap(word)
		local no_cap = {
			["and"] = "yes",
			["of"] = "yes",
			["for"] = "yes",
			["to"] = "yes",
			["its"] = "yes",
			["in"] = "yes",
			["by"] = "yes",
			["on"] = "yes",
			["as"] = "yes",
			["out"] = "yes",
		}

		if no_cap[word] then
			return word
		else
			return string.gsub(word, "^%l", string.upper)
		end

	end

	local function capitalize_word (line)
		local word
		local cap_line = nil
		for word in string.gmatch(line, "%g+") do
			if cap_line then
				cap_line = cap_line .. " " .. get_cap(word)
			else
				cap_line = get_cap(word)
			end
		end
		return cap_line
	end

	while line do
		cur_head = string.match(line, "^*+")
		list_level = string.match(line, "^ *-+ ")
		if cur_head then
			pre_head = #cur_head
			notes_head[#notes_head + 1] = line
		elseif list_level then
			list_level = string.match(list_level, "-+")
			notes_head[#notes_head + 1] = capitalize_word(string.gsub(line, "^ *-+", string.rep("*", #list_level + pre_head)))
		else
			notes_head[#notes_head + 1] = line
		end
		line = io.read("l")
	end

	io.input():close()
	io.input(pre_io_stream)

	vim.api.nvim_buf_set_lines(0, 0, 0, 0, notes_head)
	vim.api.nvim_win_set_cursor(0, {line_num, line_col})

end

return gethead
