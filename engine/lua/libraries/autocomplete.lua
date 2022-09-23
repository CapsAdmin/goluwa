local autocomplete = _G.autocomplete or {}
local env = {}

do -- lists
	autocomplete.lists = autocomplete.lists or {}

	function autocomplete.RemoveList(id)
		env[id] = nil

		for _, v in ipairs(autocomplete.lists) do
			if v.id == id then
				list.remove(autocomplete.lists, 1)
				return true
			end
		end
	end

	function autocomplete.AddList(id, lst)
		autocomplete.RemoveList(id)
		list.insert(autocomplete.lists, {id = id, list = lst})
	end

	function autocomplete.GetList(id)
		for _, v in ipairs(autocomplete.lists) do
			if v.id == id then
				local lst = v.list

				if type(lst) == "function" then lst = lst() end

				return lst
			end
		end
	end

	function autocomplete.GetLists()
		return autocomplete.lists
	end
end

local function search(list, str, found, found_list, id)
	local pattern = "^.-" .. str

	if not pcall(string.find, pattern, pattern) then return found end

	if type(list) == "table" then
		if str == "" then
			for _ = 1, 100 do
				found[#found + 1] = {val = list[math.random(#list)], id = id}
			end
		else
			for i = found_list and 1 or math.max(#str + 1, 1), #list do
				if type(list[i]) == "table" then
					if list[i].val:find(pattern) then found[#found + 1] = list[i] end
				else
					if list[i]:find(pattern) then
						found[#found + 1] = {val = list[i], id = id}
					end
				end
			end
		end
	elseif type(list) == "function" then
		local v = list(str)

		if v then found[#found + 1] = {val = v, id = id} end
	end
end

function autocomplete.Search(str, id)
	local found = {}

	-- check if it's a valid string pattern
	if not pcall(string.find, "", str) then return found end

	if type(id) == "string" then
		search(autocomplete.GetList(id), str, found)
	elseif type(id) == "table" and type(id[1]) == "string" then
		for _, id in ipairs(id) do
			search(autocomplete.GetList(id), str, found, nil, id)
		end
	elseif type(id) == "table" then
		search(id, str, found, true)
	else
		for _, data in ipairs(autocomplete.lists) do
			search(data.list, str, found)
		end
	end

	return found
end

autocomplete.translate_list_id = {}

function autocomplete.DrawFound(id, x, y, found, max, offset)
	if not env[id] then env[id] = {found_autocomplete = {}, scroll = 0} end

	offset = offset or 1
	max = max or 100
	local height_offset = 0
	local width_offset = 0
	render2d.SetColor(1, 1, 1, 1)
	render2d.PushMatrix(x, y)
	local done = {}

	for i = offset, max do
		local v = found[i]

		if not v then break end

		if v.id then
			if not done[v.id] then
				local str = autocomplete.translate_list_id[v.id]

				if type(str) == "function" then str = str() end

				if str then
					local _, h = gfx.GetTextSize(str)
					render2d.SetAlphaMultiplier(0.75)
					gfx.DrawText(str, 5, (i - offset) * h + height_offset)
					height_offset = height_offset + h
					width_offset = 5
				end

				done[v.id] = true
			end
		end

		local alpha = (-(i / max) + 1) ^ 5
		render2d.SetAlphaMultiplier(alpha)
		local _, h = gfx.GetTextSize(v.val)
		gfx.DrawText(
			((env[id].scroll + i - 1) % #found + 1) .. ". " .. v.val,
			5 + width_offset,
			(i - offset) * h + height_offset
		)
	end

	render2d.SetAlphaMultiplier(1)
	render2d.PopMatrix()
end

function autocomplete.ScrollFound(found, offset)
	list.scroll(found, offset)
end

function autocomplete.Query(id, str, scroll, list)
	scroll = scroll or 0

	if not env[id] then env[id] = {found_autocomplete = {}, scroll = 0} end

	if scroll == 0 then
		if env[id].last_str and #env[id].last_str > #str then
			env[id].tab_str = nil
			env[id].tab_autocomplete = nil
			env[id].pause_autocomplete = false
			env[id].last_str = nil
			env[id].scroll = 0
		end
	else
		autocomplete.ScrollFound(env[id].tab_autocomplete or env[id].found_autocomplete, scroll)
	end

	if not env[id].pause_autocomplete then
		env[id].found_autocomplete = autocomplete.Search(env[id].tab_str or str, env[id].tab_autocomplete or list or id)

		if #env[id].found_autocomplete == 0 then
			env[id].pause_autocomplete = str
		end
	else
		if #env[id].pause_autocomplete >= #str then
			env[id].pause_autocomplete = false
		end
	end

	if scroll ~= 0 then
		if #env[id].found_autocomplete > 0 then
			if not env[id].tab_str then
				env[id].tab_str = str
				env[id].tab_autocomplete = env[id].found_autocomplete
			end

			if env[id].last_str then env[id].scroll = env[id].scroll + scroll end

			env[id].last_str = str
		end
	end

	if str == env[id].found_autocomplete[1] then
		autocomplete.ScrollFound(env[id].tab_autocomplete or env[id].found_autocomplete, scroll)
	end

	return env[id].found_autocomplete
end

return autocomplete