if not SCITE then return end

do
	local style = {}

	local translate = {
		number = 4,
		keyword = 5,
		string = 6,
		operator = 10,
		comment = 2,
		comment_multiline = 8,
		plain_text = 11,
		globals = 13,
		libraries = 14,
		meta = 12,
		line_numbers = 33,
		brace_match = 34,
		tab_help = 37,
	}

	function scite.SetStyle(tbl)
		tbl.font = "courier new"

		for key, val in pairs(tbl) do
			if type(val) == "table" then
				for k,v in pairs(val) do
					if typex(v) == "color" then v = v:GetHex() end

					scite.SendEditor(_G["SCI_STYLESET" .. k:upper()], translate[key] or key, v)
				end
			else
				if typex(val) == "color" then val = val:GetHex() end

				for i = 0, 255 do
					scite.SendEditor(_G["SCI_STYLESET" .. key:upper()], i, val)
				end
			end
		end

		scite.SendEditor(SCI_SETSELFORE, false, ColorBytes(255,255,255):GetHex())
		scite.SendEditor(SCI_SETSELBACK, false, ColorBytes(255,255,255):GetHex())
		scite.SendEditor(SCI_SETCARETLINEBACKALPHA, 10)
		scite.SendEditor(SCI_SETCARETLINEVISIBLE, true)

		if tbl.plain_text then
			scite.SendEditor(SCI_SETCARETFORE, tbl.plain_text.fore:GetHex())
		end

		if tbl.back then
			scite.SendEditor(SCI_SETFOLDMARGINCOLOUR, true, (tbl.back * 1.25):GetHex())
			scite.SendEditor(SCI_SETFOLDMARGINHICOLOUR, true, (tbl.back * 1.25):GetHex())
		end

		scite.SendEditor(SCI_MARKERDEFINE, SC_MARKNUM_FOLDER, SC_MARK_BOXPLUS)
		scite.SendEditor(SCI_MARKERDEFINE, SC_MARKNUM_FOLDEROPEN, SC_MARK_BOXMINUS)

		--scite.SendEditor(SCI_MARKERDEFINE, SC_MARKNUM_FOLDERSUB, SC_MARK_BACKGROUND)
		--scite.SendEditor(SCI_MARKERDEFINE, SC_MARKNUM_FOLDERSUB, SC_MARK_BACKGROUND)

		serializer.WriteFile("luadata", "%DATA%/editor_style.txt", tbl)
	end

	local function reload() local tbl = serializer.ReadFile("luadata", "%DATA%/editor_style.txt") if tbl then scite.SetStyle(tbl) end end

	event.AddListener("SciTEUpdateUI", "scite_set_style", function()
		reload()
	end)

	event.AddListener("SciTEUpdateUI", "scite_update_keywords", function()
		local globals = {}

		for k,v in pairs(_G) do
			table.insert(globals, k)
			if type(v) == "table" then
				for _k,v in pairs(v) do
					if type(v) == "function" then
						table.insert(globals, k  .. "." .. _k)
					end
				end
			end
		end

		local done = {}

		for _, meta in pairs(prototype.GetAllRegistered()) do
			for key, val in pairs(meta) do
				if type(val) == "function" and not done[key] then
					table.insert(globals, key)
				end
			end
		end

		scite.SendEditor(SCI_SETKEYWORDS, 1, table.concat(globals, "\n"))
	end)

	reload()

	local translate2 = {
		["Brace Matching (Rectangle)"] = "brace_match"
	}

	function scite.LoadVSStyle(str)
		local tbl = {}

		for key, fg, bg in str:gmatch("<Item Name=\"(.-)\" Foreground=\"(.-)\" Background=\"(.-)\"") do
			key = translate2[key] or key
			key = key:lower():gsub(" ", "_")

			fg = fg:sub(5)
			bg = bg:sub(5)

			if key == "selected_text" then
				tbl.tab_help = tbl.tab_help or {}
				tbl.tab_help.fore = ColorBytes(255,255,255)/4
			end

			if key == "user_types" then
				tbl.globals = tbl.globals or {}
				tbl.globals.fore = ColorHex(fg)
				tbl.meta = tbl.meta or {}
				tbl.meta.fore = ColorHex(fg)
				tbl.libraries = tbl.libraries or {}
				tbl.libraries.fore = ColorHex(fg)
			end

			if translate[key] then
				if fg == "000000" then
					fg = "FFFFFF"
				end

				if key == "comment" then
					tbl.comment_multiline = tbl.comment_multiline or {}
					tbl.comment_multiline.fore = ColorHex(fg)
				end

				tbl[key] = tbl[key] or {}
				tbl[key].fore = ColorHex(fg)

				if key == "plain_text" then
					tbl.back = ColorHex(bg)
				end

				if key == "brace_match" then
					tbl[key].back = ColorHex(bg)
				end
			end
		end

		return tbl
	end
end
