local input = _G.input or {}

input.PressedThreshold = 0.2

function input.SetupAccessorFunctions(tbl, name, up_id, down_id, on_self)
	up_id = up_id or name .. "_up_time"
	down_id = down_id or name .. "_down_time"

	input[down_id] = {}
	input[up_id] = {}

	local is_down = function(self, key)
		return self[down_id][key]
	end

	local get_up_time = function(self, key)
		return system.GetElapsedTime() - (self[up_id][key] or 0)
	end

	local was_pressed = function(self, key)
		return system.GetElapsedTime() - (self[down_id][key] or 0) < input.PressedThreshold
	end

	local get_down_time = function(self, key)
		return system.GetElapsedTime() - (self[down_id][key] or 0)
	end

	if on_self then
		tbl["Is" .. name .. "Down"] = is_down
		tbl["Get" .. name .. "UpTime"] = get_up_time
		tbl["Was" .. name .. "Pressed"] = was_pressed
		tbl["Get" .. name .. "DownTime"] = get_down_time
	else
		tbl["Is" .. name .. "Down"] = function(...) return is_down(input, ...) end
		tbl["Get" .. name .. "UpTime"] = function(...) return get_up_time(input, ...) end
		tbl["Was" .. name .. "Pressed"] = function(...) return was_pressed(input, ...) end
		tbl["Get" .. name .. "DownTime"] = function(...) return get_down_time(input, ...) end
	end
end

function input.CallOnTable(tbl, name, key, press, up_id, down_id)
	if not tbl then return end
	if not key then return end

	up_id = up_id or name .. "_up_time"
	down_id = down_id or name .. "_down_time"

	tbl[up_id] = tbl[up_id] or {}
	tbl[down_id] = tbl[down_id] or {}

	if type(key) == "string" and #key == 1 then
		local byte = string.byte(key)

		if byte >= 65 and byte <= 90 then -- Uppercase letters
			key = string.char(byte+32)
		end
	end

	if key then
		if press and not tbl[down_id][key] then

			if input.debug then
				print(name, "key", key, "pressed")
			end

			tbl[up_id][key] = nil
			tbl[down_id][key] = os.clock()
		elseif not press and tbl[down_id][key] and not tbl[up_id][key] then

			if input.debug then
				print(name, "key", key, "released")
			end

			tbl[up_id][key] = os.clock()
			tbl[down_id][key] = nil
		end
	end
end

function input.SetupInputEvent(name)
	local down_id = name .. "_down_time"
	local up_id = name .. "_up_time"

	input[down_id] = {}
	input[up_id] = {}

	input.SetupAccessorFunctions(input, name)

	return function(key, press)
		return input.CallOnTable(input, name, key, press, up_id, down_id)
	end
end

do
	input.binds = {}

	function input.Bind(key, cmd, callback)
		check(key, "string")
		check(cmd, "string", "nil")

		serializer.SetKeyValueInFile("luadata", "%DATA%/input.txt", key, cmd)

		local modifiers = key:explode("+")
		table.remove(modifiers, 1)

		input.binds[key .. cmd] = {
			key = key:sub(1, 1) == "+" and key:sub(2) or key,
			trigger = key:match("^%-(.-)%+") or key:match("^(.-)%+") or key,
			cmd = cmd,
			modifiers = modifiers,
			trigger_on_release = cmd:sub(1, 1) == "-",
		}

		if callback then
			commands.Add(cmd, callback)
		end
	end

	function input.Initialize()
		input.binds = serializer.ReadFile("luadata", "%DATA%/input.txt") or {}
	end

	function input.Call(key, press)
		if input.DisableFocus then return end

		for _, data in pairs(input.binds) do
			if data.trigger == key then
				if (press and not data.trigger_on_release) or (not press and data.trigger_on_release) then
					local ok = true
					for i,v in ipairs(data.modifiers) do
						if not input.IsKeyDown(v) then
							ok = false
							break
						end
					end
					if ok then
						commands.RunString(data.cmd)
						return false
					end
				end
			end
		end
	end

	event.AddListener("KeyInput", "keybind", input.Call, {on_error = system.OnError, priority = math.huge})

	commands.Add("bind", function(line, key, ...)
		if key then
			cmd = table.concat({...}, " ")
			input.Bind(key, cmd)
		end
	end)
end

return input