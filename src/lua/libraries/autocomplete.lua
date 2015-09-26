local autocomplete = _G.autocomplete or {}

local env = {}

do -- lists
	autocomplete.lists = autocomplete.lists or {}

	function autocomplete.RemoveList(id)
		env[id] = nil
		for _, v in ipairs(autocomplete.lists) do
			if v.id == id then
				table.remove(autocomplete.lists, 1)
				return true
			end
		end
	end

	function autocomplete.AddList(id, list)
		autocomplete.RemoveList(id)
		table.insert(autocomplete.lists, {id = id, list = list})
	end

	function autocomplete.GetList(id)
		for _, v in ipairs(autocomplete.lists) do
			if v.id == id then
				local list = v.list
				if type(list) == "function" then list = list() end
				return list
			end
		end
	end

	function autocomplete.GetLists()
		return autocomplete.lists
	end
end

local function search(list, str, found, found_list)
	local pattern = "^.-" .. str

	if not pcall(string.find, pattern, pattern) then return found end

	if type(list) == "table" then
		if str == "" then
			for _ = 1, 100 do
				found[#found + 1] = list[math.random(#list)]
			end
		else
			for i = found_list and 1 or math.max(#str+1, 1), #list do
				if list[i]:find(pattern) then
					found[#found + 1] = list[i]
				end
			end
		end
	elseif type(list) == "function" then
		local v = list(str)
		if v then
			found[#found + 1] = v
		end
	end
end

function autocomplete.Search(str, id)

	local found = {}

	-- check if it's a valid string pattern
	if not pcall(string.find, "", str) then return found end

	if type(id) == "string" then
		local list = autocomplete.GetList(id)
		search(list, str, found)
	elseif type(id) == "table" then
		search(id, str, found, true)
	else
		for _, data in ipairs(autocomplete.lists) do
			search(data.list, str, found)
		end
	end

	return found
end

function autocomplete.DrawFound(x, y, found, max, offset)
	offset = offset or 1
	max = max or 100

	surface.SetFont("default")
	surface.SetColor(1,1,1,1)

	surface.PushMatrix(x, y)
		for i = offset-1, max do
			local v = found[i]

			if not v then break end

			local _, h = surface.GetTextSize(v)
			local alpha = (-(i / max) + 1) ^ 15

			surface.SetAlphaMultiplier(alpha)
			surface.SetTextPosition(5, (i-offset+1) * h)
			surface.DrawText(i .. ". " ..  v)
		end

		surface.SetAlphaMultiplier(1)
	surface.PopMatrix()
end

function autocomplete.ScrollFound(found, offset)
	table.scroll(found, offset)
end

function autocomplete.Query(id, str, scroll, list)
	scroll = scroll or 0

	if not env[id] then
		env[id] = {found_autocomplete = {}}
	end

	if scroll == 0 then
		if env[id].last_str and #env[id].last_str > #str then
			env[id].tab_str = nil
			env[id].tab_autocomplete = nil
			env[id].pause_autocomplete = false
			env[id].last_str = nil
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
		if #env[id].pause_autocomplete > #str then
			env[id].pause_autocomplete = false
		end
	end

	if scroll ~= 0 then
		if #env[id].found_autocomplete > 0 then

			if not env[id].tab_str then
				env[id].tab_str = str
				env[id].tab_autocomplete = env[id].found_autocomplete
			end

			env[id].last_str = str
		end
	end

	return env[id].found_autocomplete
end

return autocomplete