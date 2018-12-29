local base_url = "http://www.hdrlabs.com/sibl/archive/downloads/"

resource.Download(base_url):Then(function(html_path)
	local content = assert(vfs.Read(html_path))
	for file_name in content:gmatch("_f%('(.-)'") do
		resource.CreateVirtualFile("textures/skybox/hdr/" .. file_name:lower():gsub("%.zip", ".hdr"), function(on_success, on_fail)
			resource.Download(base_url .. file_name):Then(function(path)
				local found = {}

				for _, dir in ipairs(vfs.Find(path .. "/", true)) do
					for _, path in ipairs(vfs.Find(dir .. "/", true)) do
						if path:endswith(".hdr") or path:endswith(".exr") then
							table.insert(found, {size = vfs.GetSize(path), path = path})
						end
					end
				end

				if found[1] then
					table.sort(found, function(a, b)
						return a.size > b.size
					end)

					path = found[1].path

					on_success(path)
				else
					on_fail("unable to find any hdr files in archive " .. path .. "!")
					for _, dir in ipairs(vfs.Find(path .. "/", true)) do
						for _, path in ipairs(vfs.Find(dir .. "/", true)) do
							print(path)
						end
					end
				end
			end):Catch(on_fail)
		end)
	end
end)