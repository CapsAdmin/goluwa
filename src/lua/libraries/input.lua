local input = _G.input or {}

input.PressedThreshold = 0.2

function input.SetupAccessorFunctions(tbl, name, up_id, down_id)
	up_id = up_id or name .. "_up_time"
	down_id = down_id or name .. "_down_time"

	local self
	tbl["Is" .. name .. "Down"] = function(self, ...)
		local args
		if not hasindex(self) then args = {self, ...} self = tbl else args = {...} end
		if not self[down_id] then self[down_id] = {} end

		for _, val in ipairs(args) do
			if not self[down_id][val] then
				return false
			end
		end

		return true
	end

	tbl["Get" .. name .. "UpTime"] = function(self, key)
		if not hasindex(self) then key = self self = tbl end
		if not self[up_id] then self[up_id] = {} end
		return os.clock() - (self[up_id][key] or 0)
	end

	tbl["Was" .. name .. "Pressed"] = function(self, key)
		if not hasindex(self) then key = self self = tbl end
		if not self[down_id] then self[down_id] = {} end
		return os.clock() - (self[down_id][key] or 0) < input.PressedThreshold
	end

	tbl["Get" .. name .. "DownTime"] = function(self, key)
		if not hasindex(self) then key = self self = tbl end
		if not self[down_id] then self[down_id] = {} end
		return os.clock() - (self[down_id][key] or 0)
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
			console.AddCommand(cmd, callback)
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
						console.RunString(data.cmd)
						return false
					end
				end
			end
		end
	end

	event.AddListener("KeyInput", "keybind", input.Call, {on_error = system.OnError, priority = math.huge})

	function input.Command(line, key, ...)
		if key then
			cmd = table.concat({...}, " ")
			input.Bind(key, cmd)
		end
	end

	console.AddCommand("bind", input.Command)
end

return input