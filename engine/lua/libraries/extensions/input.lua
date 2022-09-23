input.binds = {}

function input.Bind(key, cmd, callback, important)
	serializer.StoreInFile("luadata", "data/input.txt", key, cmd)
	local modifiers = key:split("+")
	list.remove(modifiers, 1)
	input.binds[key .. cmd] = {
		key = key:sub(1, 1) == "+" and key:sub(2) or key,
		trigger = key:match("^%-(.-)%+") or key:match("^(.-)%+") or key,
		cmd = cmd,
		modifiers = modifiers,
		trigger_on_release = cmd:sub(1, 1) == "-",
		important = important,
	}

	if callback then commands.Add(cmd .. "=nil", callback) end
end

function input.Unbind(key)
	for k, v in pairs(input.binds) do
		if k:starts_with(key) then
			input.binds[k] = nil
			commands.Remove(v.cmd)

			break
		end
	end
end

function input.Initialize()
	input.binds = serializer.ReadFile("luadata", "data/input.txt") or {}
end

input.disable_focus = 0

do
	local last_focus_frame = 0

	function input.PushDisableFocus()
		local frame = system.GetFrameNumber()

		if last_focus_frame ~= frame then
			input.disable_focus = input.disable_focus + 1
			last_focus_frame = frame
		end
	end

	local last_unfocus_frame = 0

	function input.PopDisableFocus()
		local frame = system.GetFrameNumber()

		if last_unfocus_frame ~= frame then
			input.disable_focus = math.max(input.disable_focus - 1, 0)
			last_unfocus_frame = frame
		end
	end
end

function input.Call(key, press)
	for _, data in pairs(input.binds) do
		if data.important or input.disable_focus == 0 then
			if data.trigger == key then
				if (press and not data.trigger_on_release) or (not press and data.trigger_on_release) then
					local ok = true

					for _, v in ipairs(data.modifiers) do
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
end

event.AddListener(
	"KeyInput",
	"keybind",
	input.Call,
	{on_error = system.OnError, priority = math.huge}
)

commands.Add("bind=string,string_rest", function(key, str)
	input.Bind(key, str)
end)