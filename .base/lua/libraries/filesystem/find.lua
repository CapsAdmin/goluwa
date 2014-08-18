local vfs2 = (...) or _G.vfs2

function vfs2.Find(path, invert, full_path, start, plain, info)
	
	local path_, pattern = path:match("(.+)/(.*)")
	if pattern then path = path_ end
		
	local path_info = vfs2.GetPathInfo(path, true)

	local out = {}
	local done = {}
	
	for i, data in ipairs(vfs2.TranslatePath(path, true)) do
		local ok, found = pcall(data.context.GetFiles, data.context, data.path_info)
		
		if vfs2.debug and not ok then
			vfs2.DebugPrint("%s: error getting files: %s", data.context.Name, found)
		end
		
		if ok then	
			for i, v in pairs(found) do
				if not done[v] then
					done[v] = true
					if (not pattern or pattern == "" or v:find(pattern, start, plain)) then
						if full_path then
							v = --[[data.context.Name .. ":" ..]] data.path_info.full_path .. v
						end
						
						if info then
							table.insert(out, {
								name = v, 
								filesystem = data.context.Name,
								full_path = data.context.Name .. ":" .. data.path_info.full_path .. v,
							})
						else
							table.insert(out, v)
						end
					end
				end				
			end
		end
	end
	
	if invert then
		table.sort(out, function(a, b) if info then return a.full_path > b.full_path end return a > b end)
	else
		table.sort(out, function(a, b) if info then return a.full_path < b.full_path end return a < b end)
	end
	
	return out
end


function vfs2.Iterate(path, ...)
	check(path, "string")
	
	local dir = path:match("(.+/)") or ""
	local tbl = vfs2.Find(path, ...)
	local i = 1
	
	return function()
		local val = tbl[i]
		
		i = i + 1
		
		if val then 
			return val, dir .. val
		end
	end
end

function vfs2.Traverse(path, callback, level)
	level = level or 1

	local attributes = vfs2.GetAttributes(path)

	if attributes then
		callback(path, attributes, level)

		if attributes.mode == "directory" then
			for child in vfs2.Iterate(path) do
				if child ~= "." and child ~= ".." then
					vfs2.Traverse(path .. "/" .. child, callback, level + 1)
				end
			end
		end
	end
end

do 
	local out
	local function search(path, ext, callback)		
		for _,v in pairs(vfs2.Find(path)) do
			if not ext or v:endswith(ext) then
				if callback and callback(path .. v) ~= nil then
					return
				end
				
				table.insert(out, path .. v)
			end
			
			if vfs2.GetAttributes(path .. v).mode == "directory" then
				search(path .. v .. "/", ext, callback)
			end
		end
	end

	function vfs2.Search(path, ext, callback)
		out = {}
		search(path, ext, callback)
		return out
	end
end