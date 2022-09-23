local util = {}

function util.GetFilesRecursively(dir, ext)
	ext = ext or ".lua"
	local f = assert(io.popen("find " .. dir))
	local lines = f:read("*all")
	local paths = {}

	for line in lines:gmatch("(.-)\n") do
		if line:sub(-#ext) == ext then table.insert(paths, line) end
	end

	return paths
end

function util.FetchCode(path--[[#: string]], url--[[#: string]]) --: type util.FetchCode = function(string, string): string
	local f = io.open(path, "rb")

	if not f then
		os.execute("wget --force-directories -O " .. path .. " " .. url)
		f = io.open(path, "rb")

		if not f then
			os.execute("curl  " .. url .. " --create-dirs --output " .. path)
		end

		if not io.open(path, "rb") then error("unable to download file?") end
	end

	f = assert(io.open(path, "rb"))
	local code = f:read("*all")
	f:close()
	return code
end

do
	local indent = 0

	local function dump(tbl, blacklist, done)
		for k, v in pairs(tbl) do
			if (not blacklist or blacklist[k] ~= type(v)) and type(v) ~= "table" then
				io.write(("\t"):rep(indent))
				local v = v

				if type(v) == "string" then v = "\"" .. v .. "\"" end

				io.write(tostring(k), " = ", tostring(v), "\n")
			end
		end

		for k, v in pairs(tbl) do
			if (not blacklist or blacklist[k] ~= type(v)) and type(v) == "table" then
				if done[v] then
					io.write(("\t"):rep(indent))
					io.write(tostring(k), ": CIRCULAR\n")
				else
					io.write(("\t"):rep(indent))
					io.write(tostring(k), ":\n")
					indent = indent + 1
					done[v] = true
					dump(v, blacklist, done)
					indent = indent - 1
				end
			end
		end
	end

	function util.TablePrint(tbl--[[#: {[any] = any}]], blacklist--[[#: {[string] = string}]])
		dump(tbl, blacklist, {})
	end
end

function util.CountFields(tbl, what, cb, max)
	max = max or 10
	local score = {}

	for _, v in ipairs(tbl) do
		local key = cb(v)
		score[key] = (score[key] or 0) + 1
	end

	local temp = {}

	for k, v in pairs(score) do
		table.insert(temp, {name = k, score = v})
	end

	table.sort(temp, function(a, b)
		return a.score > b.score
	end)

	io.write("top " .. max .. " ", what, ":\n")

	for i = 1, max do
		local data = temp[i]

		if not data then break end

		if i < max then io.write(" ") end

		io.write(i, ": `", data.name, "´ occured ", data.score, " times\n")
	end
end

function util.Measure(what, cb) -- type util.Measure = function(string, function): any
	if jit then jit.flush() end

	io.write("> ", what)
	local time = os.clock()
	io.flush()
	local res = {pcall(cb)}

	if res[1] then
		if msg_callback then
			msg_callback(os.clock() - time)
		else
			io.write((" "):rep(40 - #what), " - OK ", (os.clock() - time) .. " seconds\n")
		end

		return (table.unpack or unpack)(res, 2)
	else
		io.write(" - FAIL: ", res[2])
		error(res[2], 2)
	end
end

function util.MeasureFunction(cb)
	local start = os.clock()
	cb()
	return os.clock() - start
end

function util.LoadGithub(url, path)
	os.execute("mkdir -p examples/benchmarks/temp/")
	local full_path = "examples/benchmarks/temp/" .. path .. ".lua"
	local code = assert(util.FetchCode(full_path, "https://raw.githubusercontent.com/" .. url))
	package.loaded[path] = assert(load(code, "@" .. full_path))()
	return package.loaded[path]
end

return util
