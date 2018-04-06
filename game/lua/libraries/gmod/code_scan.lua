local gine = ... or _G.gine

local suspicious = {
	CompileString = true,
	RunString = true,
	http = true,
	getfenv = true,
	package = {loaded = true},
	debug = {
		setmetatable = true,
		getmetatable = true,
		getfenv = true,
		gethook = true,
		sethook = true,
		setlocal = true,
		upvaluejoin = true,
		setupvalue = true,
		getregistry = true,
	},
	HTTP = true,
	concommand = {
		Run = true,
	},
	RunConsoleCommand = true,
}

local index = {
	ENT = true,
	TOOL = true,
	SWEP = true,
}

--[[

local s = ""
local done = {[package.loaded] = true, [matproxy and matproxy.ActiveList or {}] = true, [SpawniconGenFunctions or {}] = true}

local function scan(env, t)
	if tonumber(env) then env = "[" .. env .. "]" end
	s = s .. env .. "={\n"
	for k,v in pairs(t) do
		if type(v) == "table" then
			if not done[v] then
				done[v] = true
				scan(k, v)
			end
		else
			if tonumber(k) then k = "[" .. k .. "]" end
			s = s .. k .. "=1,\n"
		end
	end
	s = s .. "},\n"
end

scan("_G", _G)

s = s:gsub("^_G=", "return "):sub(0, -3)
print(RunString(s))
file.Write((CLIENT and "cl" or "sv") .. "_index.txt", s)
]]

local function search(func, found, ignore_globals, name, lines)
	local vmdef = require("jit.vmdef")
	local info = jit.util.funcinfo(func)

	local function bytecode(func, i)
		local ins, m = jit.util.funcbc(func, i)
		if not ins then return end

		local oidx = 6*bit.band(ins, 0xff)
		local op = string.sub(vmdef.bcnames, oidx+1, oidx+6):trim()

		local ma, mb, mc = bit.band(m, 7), bit.band(m, 15*8), bit.band(m, 15*128)
		local d = bit.rshift(ins, 16)

		if mb ~= 0 then
			d = bit.band(d, 0xff)
		end

		if mc == 10*128 then -- BCMstr
			return op, jit.util.funck(func, -d-1)
		end

		return op
	end

	for i = 0, math.huge do
		local op, str = bytecode(func, i)
		if not op then break end

		if op == "GGET" then
			local check_suspicious_bytecode = false

			if str == "_G" then
				check_suspicious_bytecode = true
			elseif suspicious[str] == true then
				table.insert(found, {
					msg = "suspicious global lookup " .. str,
					start_line = info.currentline,
					stop_line = info.lastlinedefined,
					type = "important",
				})
			elseif not index[str] then
				if not ignore_globals or not ignore_globals[str] then
					table.insert(found, {
						msg = "unknown global lookup " .. str,
						start_line = info.currentline,
						stop_line = info.lastlinedefined,
						key = str,
					})
					if ignore_globals then
						ignore_globals[str] = true
					end
				end
			else
				check_suspicious_bytecode = true
			end

			if check_suspicious_bytecode then
				local op2, str2 = bytecode(func, i + 1)

				if op2 == "TGETS" then
					if suspicious[str2] == true or (type(suspicious[str]) == "table" and suspicious[str][str2]) then
						table.insert(found, {
							msg = "suspicious lookup " .. str .. "." .. str2,
							start_line = info.currentline,
							stop_line = info.lastlinedefined,
							type = "important",
						})
					elseif type(index[str]) == "table" and not index[str][str2] then
						table.insert(found, {
							msg = "unknown " .. (str == "_G" and "global" or "function") .. " " .. str .. "." .. str2,
							start_line = info.currentline,
							stop_line = info.lastlinedefined,
						})
					end
				elseif op2 == "TGETV" and index[str] ~= 1 then
					if str2 then str2 = (" %q"):format(str2) else str2 = "" end
					table.insert(found, {
						msg = "suspicious bytecode " .. op2 .. str2 .. " after " .. op .. " " .. str,
						start_line = info.currentline,
						stop_line = info.lastlinedefined,
						type = "important",
					})
				end
			end
		end
	end
end

local loaded = false

function gine.CheckCode(source, ignore_globals)
	if not loaded then
		table.merge(index, runfile("lua/libraries/gmod/cl_index.lua"))
		table.merge(index, runfile("lua/libraries/gmod/sv_index.lua"))
		loaded = true
	end

	local func = loadstring(source, "")
	local info = jit.util.funcinfo(func)

	local found = {}

	if info.children then
		for i = -1, -1000000000, -1 do
			local v = jit.util.funck(func, i)
			if not v then break end

			if type(v) == "proto" then
				search(v, found, ignore_globals)
			end
		end
	end

	search(func, found, ignore_globals)

	-- jit.dumpbytecode(func)

	return found
end

function gine.CheckDirectory(root, name, no_linenumbers, suspicious_only)
	vfs.GetFilesRecursive(root, {"lua"}, function(path)
		local ignore_globals = {}
		local code, err = vfs.Read(path)
		if code then
			code =  gine.PreprocessLua(code)
			local ok, err = loadstring(code)
			local lines = code:split("\n")

			local found = {}

			if ok then
				vfs.Write("data/gluacheck/" .. name .. "/" .. path, code)

				found = gine.CheckCode(code, ignore_globals)
			else
				print(path)
				print(err)
			end

			if found[1] then
				logn("\t", (path:match(".+/(lua.+)") or path) .. ":")

				local function parse_info(info)
					logn("\t\t", path:match(".+/(lua.+)"), ":", info.start_line, " - ", info.stop_line)
					logn("\t\t", info.msg .. ":")
					if not no_linenumbers then
						local max = 20
						local c = 0
						for i = info.start_line, info.stop_line do
							local line = lines[i]
							if line then
								logn("\t\t\t", i .. ":" .. line)
							end
							c = c + 1

							if c > 20 then break logn("...") end
						end
						logn("\n")
					end
				end

				if not suspicious_only then
					for i, info in ipairs(found) do
						if info.type ~= "important" then
							parse_info(info)
						end
					end
				end

				for i, info in ipairs(found) do
					if info.type == "important" then
						parse_info(info)
					end
				end
			end

		else
			if not err then
				logn(path, ": empty file")
			else
				logn(path, ": ", err)
			end
		end
	end)
end

function gine.CheckWorkshopAddon(id, no_linenumbers, suspicious_only)
	logn("downloading ", id)
	steam.DownloadWorkshop(id, function(path, info)
		logn("finished downloading ", id)
		logn("==============================================================================================================")
		logn("checking ", info.publishedfiledetails[1].title)
		logn("http://steamcommunity.com/workshop/filedetails/?id=" .. info.publishedfiledetails[1].publishedfileid)

		local name = vfs.ReplaceIllegalPathSymbols(info.publishedfiledetails[1].title, true)

		gine.CheckDirectory(path .. "/lua/", name, no_linenumbers, suspicious_only)
		gine.CheckDirectory(path .. "/gamemodes/", name, no_linenumbers, suspicious_only)

		if not vfs.IsDirectory(path .. "/lua") and not vfs.IsDirectory(path .. "/gamemodes") then
			table.print(vfs.Find(path .. "/"))
			logn("no lua or gamemode folder")
		end
	end)
end