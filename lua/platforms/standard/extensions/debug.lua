function debug.trace()	
    logn("Trace: " )
	
	for level = 1, math.huge do
		local info = debug.getinfo(level, "Sln")
		
		if info then
			logf("\t%i: Line %d\t\"%s\"\t%s", level, info.currentline, info.name or "unknown", info.short_src or "")
		else
			break
		end
    end
end

function debug.getparams(func)
    local params = {}
	
	for i = 1, math.huge do
		local key = debug.getlocal(func, i)
		if key then
			table.insert(params, key)
		else
			break
		end
	end

    return params
end

function debug.getparamsx(func)
    local params = {}
	
	for i = 1, math.huge do
		local key, val = debug.getlocal(func, i)
		if key then
			table.insert(params, {key = key, val = val})
		else
			break
		end
	end

    return params
end

function debug.dumpcall(clr_print)
	local info = debug.getinfo(4)
	local path = info.source:sub(2)
	local script = vfs.Read(path)
	
	logn(path)
	
	if script then
		local lines = script:explode("\n")
		
		for i = -10, 10 do
			local line = lines[info.currentline + i]
			
			if line then
				if i == 0 then
					line = (">"):rep(string.len(info.currentline)) .. ":\t" ..  line
				else
					line = (info.currentline + i) .. ": " .. line
				end
			
				if clr_print then
					console.ColorPrint(line .. "\n")
				end
			end
		end
	else
		logn(path)
	end
	
	logn("")
	logn("LOCALS: ")
	for _, data in pairs(debug.getparamsx(4)) do
		if not data.key:find("(",nil,true) then
			local val = luadata.ToString(data.val) or "nil"
			if val:find("\n") then 
				if type(data.val) == "table" then
					val = tostring(data.val)
				else
					val = val:match("(.-)\n") .. "...."
				end
			end
			logf("%s = %s", data.key, val)
		end
	end
end

function debug.logcalls(b)
	if not b then
		debug.sethook()
		return
	end
	
	local hook

	hook = function() 
		debug.sethook()
		
		setlogfile("lua_calls")
			debug.dumpcall()
		setlogfile()
		
		debug.sethook(hook, "l")
	end
	
	debug.sethook(hook, "l")
end

function debug.stepin()
	if not curses then return end
	
	local first_time = true

	local step
	
	step = function()
		system.SetWindowTitle("DEBUG SETHOOK |space = exit | enter = return | down = line | pagedown = call|")
		console.ClearWindow()
		
		debug.dumpcall(true)
		
		while true do
			if first_time then
				first_time = false
				break
			end
			
			local key = console.GetActiveKey()
			
			if key == "KEY_ENTER" then
				debug.sethook(step, "r")
				break
			elseif key == "KEY_DOWN" then
				debug.sethook(step, "l")
				break
			elseif key == "KEY_NPAGE" then
				debug.sethook(step, "c")
				break
			elseif key == "KEY_SPACE" then
				debug.sethook()
				break
			end
		end
	end
	
	debug.sethook(step, "l")
end