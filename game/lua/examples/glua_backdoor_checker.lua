steam.DownloadWorkshopCollection("427843415", function(ids)
	local max = #ids
	local buffer = ""

	local doneget = {}
	local doneset = {}

	local globals = {
		ENT = true,
		TOOL = true,
		NULL = true,
		vector_origin = true,
		CLIENT = true,
		SERVER = true,
		SWEP = true,
	}

	local suspicious = {
		_G = true,
		CompileString = true,
		RunString = true,
	}

	local clenv = runfile("lua/libraries/gmod/cl_exported.lua")
	table.merge(globals, clenv.enums)
	table.merge(globals, clenv.globals)
	table.merge(globals, clenv.functions)

	local svenv = runfile("lua/libraries/gmod/sv_exported.lua")
	table.merge(globals, svenv.enums)
	table.merge(globals, svenv.globals)
	table.merge(globals, svenv.functions)

	for _, id in ipairs(ids) do
		steam.DownloadWorkshop(id, function(info, path)
			max = max - 1

			vfs.Search(path .. "/lua/", {"lua"}, function(path)
				local code =  gine.PreprocessLua(vfs.Read(path))
				buffer = buffer .. "--" .. path .. "\n(function()\n" .. code .. "\nend)()\n"

				local f = io.tmpfile()
				require("jit.bc").dump(loadstring(code, path), f, true)
				f:seek("set", 0)
				local lines = f:read("*a"):split("\n")

				for i, line in ipairs(lines) do
					if line:find("GSET") then
						local what = line:match("GSET.-; \"(.-)\"")
						print("set _G." .. what .. " = ?")
					end

					if line:find("GGET") then
						local what = line:match("GGET.-; \"(.-)\"")
						if what == "_G" then
							what = lines[i+1]:match("TGETS.-; \"(.-)\"") or lines[i+1]:match("GGET.-; \"(.-)\"")
							if what == "_G" then
								what = lines[i+2]:match("TGETS.-; \"(.-)\"") or lines[i+2]:match("GGET.-; \"(.-)\"")
							end

							what = what or "_G"
						end

						if globals[what] == nil and not doneget[what] then
							doneget[what] = true
							print("get _G." .. what)
						end

						if suspicious[what] then
							local start, stop
							for offset = 1, 100 do
								if lines[i - offset] and lines[i - offset]:find("BYTECODE") then
									start, stop = unpack(lines[i - offset]:match("%-%- BYTECODE %-%- .-:(.+)"):split("-"))
									break
								end
							end
							print("===============================")
							print("suspicious global lookup >>" .. what .. "<< in ".. info.response.publishedfiledetails[1].title .."' at " .. path:match(".+%.gma/(.+)") ..":" .. start .. "-" .. stop)
							local lines = code:split("\n")
							for i = start + 1, stop + 1 do
								print(i .. ":" .. (lines[i] or ""))

							end
							print("http://steamcommunity.com/workshop/filedetails/?id=" .. info.response.publishedfiledetails[1].publishedfileid)
							print("===============================")
						end

					end
				end
			end)

			if max == 0 then
				vfs.Write("output.lua", buffer)
			end
		end)
	end
end)