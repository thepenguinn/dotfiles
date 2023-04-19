
local gethead = {}

function gethead.inject ()

	local notes_path
	local syllabus_path
	local pre_io_stream
	local new_io_stream

	notes_path = vim.api.nvim_buf_get_name(0)

	syllabus_path = string.gsub(notes_path, "notes_mod_(%d+.norg)$", "syllabus_mod_%1")

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
			line = io.read("l")
		end

		notes_head[#notes_head + 1] = string.gsub(line, "[Ss]yllabus$", "Notes")
		line = io.read("l")
	end

	local pre_head = 0
	local cur_head
	local list_level

	while line do
		cur_head = string.match(line, "^*+")
		list_level = string.match(line, "^ *-+ ")
		if cur_head then
			pre_head = #cur_head
			notes_head[#notes_head + 1] = line
		elseif list_level then
			list_level = string.match(list_level, "-+")
			notes_head[#notes_head + 1] = string.gsub(line, "^ *-+", string.rep("*", #list_level + pre_head))
		else
			notes_head[#notes_head + 1] = line
		end
		line = io.read("l")
	end

	io.input():close()
	io.input(pre_io_stream)

	vim.api.nvim_buf_set_lines(0, 0, 0, 0, notes_head)

end

return gethead
