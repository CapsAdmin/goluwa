local list = {}

for k,v in pairs(_G) do
	table.insert(list, k)
end

local str = ""

local function update_current_string()
	str = {}

	for i = 1, 100 do
		local byte = scite.SendEditor(SCI_GETCHARAT, scite.SendEditor(SCI_GETCURRENTPOS) - i)
		if byte < 0 then byte = byte + 128 end
		local char = utf8.char(byte)
		if not char:find("[%a_%.1-9%(,]") then
			break
		end
		table.insert(str, 1, char)
	end

	str = table.concat(str)

	if #str < 3 then return end

	local found = {}
	local node = _G
	local keys = str:trim():explode(".")
	local found_string = ""


	local current_func

	for i, index in ipairs(keys) do
		if node[index] and type(node[index]) == "table" then
			last_node = node
			node = node[index]

			found_string  = found_string  .. index

			if type(node) == "table" then
				found_string = found_string .. "."
			end
		else
			for key, val in pairs(node) do
				local str = tostring(key)
				if current_func then
					local params = debug.getparams(current_func)
					--event.AddListener(
				elseif str:find("^.-" .. index) then

					if type(val) == "table" then
						str = str .. "."
					elseif type(val) == "function" then
						str = str .. "("
						current_func	= val
					elseif type(val) == "number" then
						str = str .. "["
					end

					table.insert(found, found_string .. str)
				end
			end
		end
	end

	--event.AddListener(

	if #found > 0 then
		scite.SendEditor(SCI_AUTOCSETTYPESEPARATOR, ("\n"):byte())
		scite.SendEditor(SCI_AUTOCSETSEPARATOR, ("\n"):byte())
		scite.SendEditor(SCI_AUTOCSHOW, #str, table.concat(found, "\n"))
		scite.SendEditor(SCI_AUTOCSETAUTOHIDE, false)
	end
end

event.AddListener("SciTEClick", "scite_autocomplete", function(...)

end)

event.AddListener("SciTEKey", "scite_autocomplete", function(key)
	if key == 8 then
		event.Delay(0, function() update_current_string() end)
	end
end)

event.AddListener("SciTEChar", "scite_autocomplete", function(char)
	update_current_string()
end)