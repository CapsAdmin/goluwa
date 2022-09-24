function utility.TableToColumns(title, tbl, columns, check, sort_key)
	if false and gui then
		local frame = gui.CreatePanel("frame", nil, "table_to_columns_" .. title)
		frame:SetSize(Vec2() + 300)
		frame:SetTitle(title)
		local list = frame:CreatePanel("list")
		list:SetupLayout("fill")
		local keys = {}

		for i, v in ipairs(columns) do
			keys[i] = v.friendly or v.key
		end

		list:SetupSorted(unpack(keys))

		for _, data in ipairs(tbl) do
			local args = {}

			for i, info in ipairs(columns) do
				if info.tostring then
					args[i] = info.tostring(data[info.key], data, tbl)
				else
					args[i] = data[info.key]
				end

				if type(args[i]) == "string" then args[i] = args[i]:trim() end
			end

			list:AddEntry(unpack(args))
		end

		return
	end

	local top = {}

	for k, v in pairs(tbl) do
		if not check or check(v) then list.insert(top, {key = k, val = v}) end
	end

	if type(sort_key) == "function" then
		list.sort(top, function(a, b)
			return sort_key(a.val, b.val)
		end)
	else
		list.sort(top, function(a, b)
			return a.val[sort_key] > b.val[sort_key]
		end)
	end

	local max_lengths = {}
	local temp = {}

	for _, column in ipairs(top) do
		for key, data in ipairs(columns) do
			data.tostring = data.tostring or function(...)
				return ...
			end
			data.friendly = data.friendly or data.key
			max_lengths[data.key] = max_lengths[data.key] or 0
			local str = tostring(data.tostring(column.val[data.key], column.val, top))
			column.str = column.str or {}
			column.str[data.key] = str

			if #str > max_lengths[data.key] then max_lengths[data.key] = #str end

			temp[key] = data
		end
	end

	columns = temp
	local width = 0

	for _, v in pairs(columns) do
		if max_lengths[v.key] > #v.friendly then
			v.length = max_lengths[v.key]
		else
			v.length = #v.friendly + 1
		end

		width = width + #v.friendly + max_lengths[v.key] - 2
	end

	local out = " "
	out = out .. ("_"):rep(width - 1) .. "\n"
	out = out .. "|" .. (
			" "
		):rep(width / 2 - math.floor(#title / 2)) .. title .. (
			" "
		):rep(math.floor(width / 2) - #title + math.floor(#title / 2)) .. "|\n"
	out = out .. "|" .. ("_"):rep(width - 1) .. "|\n"

	for _, v in ipairs(columns) do
		out = out .. "| " .. v.friendly .. ": " .. (
				" "
			):rep(-#v.friendly + max_lengths[v.key] - 1) -- 2 = : + |
	end

	out = out .. "|\n"

	for _, v in ipairs(columns) do
		out = out .. "|" .. ("_"):rep(v.length + 2)
	end

	out = out .. "|\n"

	for _, v in ipairs(top) do
		for _, column in ipairs(columns) do
			out = out .. "| " .. v.str[column.key] .. (
					" "
				):rep(-#v.str[column.key] + column.length + 1)
		end

		out = out .. "|\n"
	end

	out = out .. "|"
	out = out .. ("_"):rep(width - 1) .. "|\n"
	return out
end

do
	-- http://cakesaddons.googlecode.com/svn/trunk/glib/lua/glib/stage1.lua
	local size_units = {
		"B",
		"KiB",
		"MiB",
		"GiB",
		"TiB",
		"PiB",
		"EiB",
		"ZiB",
		"YiB",
	}

	function utility.FormatFileSize(size)
		local unit_index = 1

		while size >= 1024 and size_units[unit_index + 1] do
			size = size / 1024
			unit_index = unit_index + 1
		end

		return tostring(math.floor(size * 100 + 0.5) / 100) .. " " .. size_units[unit_index]
	end
end