local list = {}

for k,v in pairs(_G) do
	table.insert(list, k)
end

local str = ""

local function update_current_string()
	str = {}
	
	for i = 1, 100 do
		local char = string.char(scite.SendEditor(SCI_GETCHARAT, scite.SendEditor(SCI_GETCURRENTPOS)-i))
		if not char:find("[%a_%.1-9]") then
			break 
		end
		table.insert(str, 1, char)
	end
	
	str = table.concat(str)
	
	local found = {}
	local node = _G
	local keys = str:trim():explode(".")
	--table.insert(keys, "")

	for i, index in ipairs(keys) do
		if node[index] and type(node[index]) == "table" then
			node = node[index]
		else
			
			for key, val in pairs(node) do
				if key:find("^.-" .. str) then
					if type(val) == "table" then
						key = key .. "."
					end
				
					table.insert(found, key)
				end
			end
		end
	end

	scite.SendEditor(SCI_AUTOCSHOW, #str, table.concat(found, "\n"))
	scite.SendEditor(SCI_AUTOCSETAUTOHIDE, false)
end

event.AddListener("SciTEKey", "scite_autocomplete", function(key)
	if key == 8 then 
		update_current_string()
	end
end)

event.AddListener("SciTEChar", "scite_autocomplete", function(char)
	update_current_string()
end)