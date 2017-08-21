do
	local function replace(start, stop, def)
		local os = def:match("%$(.+)")

		if not os then return end

		if os == "WIN32" or os == "WINDOWS" then
			os = "Windows"
		elseif os == "LINUX" then
			os = "Linux"
		elseif os == "OSX" then
			os = "OSX"
		elseif os == "POSIX" then
			os = "Posix,BSD"
		else
			os = "Other" -- xbox360 ?
		end

		if def:startswith("!") then
			if os:find(jit.os, nil, true) then
				return ""
			else
				return start .. stop
			end
		end

		if os:find(jit.os, nil, true) then
			return start .. stop
		else
			return ""
		end
	end

	local function replace_1(start, stop, def)
		return replace(start, stop, def)
	end

	local function replace_2(start, def, stop)
		return replace(start, stop, def)
	end

	function utility.VDFToTable(str, lower_or_modify_keys, preprocess)
		if not str or str == "" then return nil, "data is empty" end
		if lower_or_modify_keys == true then lower_or_modify_keys = string.lower end

		str = str:gsub("[\r\n]", "\n")
		str = str:replace("http://", "___L_O_L___")
		str = str:replace("https://", "___L_O_L_2___")

		str = str:gsub("//.-\n", "\n")

		str = str:replace("___L_O_L___", "http://")
		str = str:replace("___L_O_L_2___", "https://")

		str = str:gsub("([%d%a.\"_]+%s-)(%b\"\"%s-)%[(%p+%S-)%]", replace_1)
		str = str:gsub("([%d%a.\"_]+%s-)%[(%p+%S-)%](%s-%b{})", replace_2)

		local in_string = false
		local capture = {}
		local no_quotes = false

		local out = {}
		local current = out
		local stack = {current}

		local key

		local chars = str:utotable()

		for i, char in ipairs(chars) do
			if (char == [["]] or (no_quotes and char:find("%s"))) and chars[i-1] ~= "\\" then
				if in_string then
					if key then
						if lower_or_modify_keys then
							key = lower_or_modify_keys(key)
						end

						local val = table.concat(capture, "")

						if preprocess and val:find("|") then
							for k, v in pairs(preprocess) do
								val = val:gsub("|" .. k .. "|", v)
							end
						end

						if val:lower() == "false" then
							val = false
						elseif val:lower() ==  "true" then
							val =  true
						elseif val:find("%b{}") then
							local values = val:match("{(.+)}"):trim():split(" ")
							if #values == 3 or #values == 4 then
								val = ColorBytes(tonumber(values[1]), tonumber(values[2]), tonumber(values[3]), values[4] or 255)
							end
						elseif val:find("%b[]") then
							local values = val:match("%[(.+)%]"):trim():split(" ")
							if #values == 3 and tonumber(values[1]) and tonumber(values[2]) and tonumber(values[3]) then
								val = Vec3(tonumber(values[1]), tonumber(values[2]), tonumber(values[3]))
							end
						else
							val = tonumber(val) or val
						end

						if type(current[key]) == "table" then
							table.insert(current[key], val)
						elseif current[key] and current[key] ~= val then
							current[key] = {current[key], val}
						else
							if key:find("+", nil, true) then
								for _, key in ipairs(key:split("+")) do
									if type(current[key]) == "table" then
										table.insert(current[key], val)
									elseif current[key] and current[key] ~= val then
										current[key] = {current[key], val}
									else
										current[key] = val
									end

								end
							else
								current[key] = val
							end
						end

						key = nil
					else
						key = table.concat(capture, "")
					end

					in_string = false
					no_quotes = false
					table.clear(capture)
				else
					in_string = true
				end
			else
				if in_string then
					table.insert(capture, char)
				elseif char == [[{]] then
					if key then
						if lower_or_modify_keys then
							key = lower_or_modify_keys(key)
						end

						table.insert(stack, current)
						current[key] = {}
						current = current[key]
						key = nil
					else
						return nil, "stack imbalance at char " .. i
					end
				elseif char == [[}]] then
					current = table.remove(stack) or out
				elseif not char:find("%s") then
					in_string = true
					no_quotes = true
					table.insert(capture, char)
				end
			end
		end

		return out
	end

	if RELOAD then
		local str = vfs.Read("/media/caps/Elements/SteamLibrary/steamapps/common/Team Fortress 2/tf/resource/tf_english.txt")
		str = str:replace("\0", "")
		table.print(utility.VDFToTable(str, true))
	end
end