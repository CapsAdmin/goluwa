local str = vfs.Read([[G:\steam\steamapps\sourcemods\mod_hl2mp\gameinfo.txt]])

-- remove all comments
str = str:gsub("(//.-)\n", " ")

local chunks = {}
local string_capture = nil
local capture = nil

for i = 1, #str do
	local char = str:sub(i, i)
		
	if char == "{" or char == "}" then
		chunks[#chunks + 1] = char
	else			
		if char == [["]] then
			if string_capture then
				string_capture[#string_capture + 1] = char
				chunks[#chunks + 1] = table.concat(string_capture, "")
				string_capture = nil
			else
				string_capture = {}
			end
		end
		
		if string_capture then
			string_capture[#string_capture + 1] = char
		else
			if capture and str:sub(i+1,i+1):find("%s") then
				capture[#capture + 1] = char
				chunks[#chunks + 1] = table.concat(capture, "")
				capture = nil	
			elseif not capture and not char:find("%s") then
				capture = {}
			end
			
			if capture then
				capture[#capture + 1] = char
			end
		end
	end
end

local key = true

local out = {}

local level = {}
local previous_level

for i, chunk in pairs(chunks) do
	if chunk == "{" then
		previous_level = level
		level = {}
		out[chunks[i-1]] = level
	elseif chunk == "}" then
		level = previous_level		
	else
		if not key then
			level[chunks[i-1]] = chunk
		end
		
		key = not key
	end
end

table.print(chunks)