local gettemplate = {}

function gettemplate.inject ()


	local index_template = {
		"* <++>",
		"",
		"** Syllabus",
		"",
		"{:syllabus_mod_1:}[Module-1-S] syllabus",
		"",
		"---",
		"",
		"{:notes_mod_1:}[Module-1-N] notes",
		"",
		"* <++>",
		"",
		"** Syllabus",
		"",
		"{:syllabus_mod_2:}[Module-2-S] syllabus",
		"",
		"---",
		"",
		"{:notes_mod_2:}[Module-2-N] notes",
		"",
		"* <++>",
		"",
		"** Syllabus",
		"",
		"{:syllabus_mod_3:}[Module-3-S] syllabus",
		"",
		"---",
		"",
		"{:notes_mod_3:}[Module-3-N] notes",
		"",
		"* <++>",
		"",
		"** Syllabus",
		"",
		"{:syllabus_mod_4:}[Module-4-S] syllabus",
		"",
		"---",
		"",
		"{:notes_mod_4:}[Module-4-N] notes",
		"",
		"* <++>",
		"",
		"** Syllabus",
		"",
		"{:syllabus_mod_5:}[Module-5-S] syllabus",
		"",
		"---",
		"",
		"{:notes_mod_5:}[Module-5-N] notes"
	}

	vim.api.nvim_buf_set_lines(0, 0, 0, 0, index_template)

end

return gettemplate
