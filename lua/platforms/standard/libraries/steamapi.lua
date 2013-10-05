local steamapi = {}

steamapi.httpmethods = {
	GET = function(interface, func_info, data, callback)
		local arguments = ""
		
		for key, val in pairs(data) do
			arguments = arguments .. ("%s=%s&"):format(key, val)
		end
		
		-- remove the last &..
		arguments = arguments:sub(0, -2)
		
		local url = ("http://api.steampowered.com/%s/%s/v%.4d/?%s"):format(interface.name, func_info.name, data.version or 1, arguments)
		
		if steamapi.debug then	
			logf("[steamapi] http post: %s", url)
		end
		
		luasocket.Get(url, function(data)
			callback(json.decode(data.content))
		end)
	end,
}

local type_translate = {
	uint32 = "number",
	uint64 = "stringnumber",
	bool = "boolean",
}

console.CreateVariable("steamapi_key", "")

function steamapi.GetKey()
	return console.GetVariable("steamapi_key", "")
end

function steamapi.Initialize()
	steamapi.key = steamapi.GetKey()
	steamapi.supported = luadata.ReadFile("steamapi/supported.lua")
	
	if key == "" then
		logn("steamapi key is not set (run steamapi_key *key*)")
	end

	if not steamapi.supported.apilist then
		steamapi.UpdateSupported()
	end
	
	steamapi.services = {}

	for key, interface in pairs(steamapi.supported.apilist.interfaces) do
		local functions = {}
		
		for key, info in pairs(interface.methods) do
			local parameters = {}
			
			for key, val in pairs(info.parameters) do
				if val.optional == false then
					parameters[val.name] = val
				end
			end
			
			functions[info.name] = function(data, callback)
				callback = callback or table.print

				if parameters.key and not data.key then
					data.key = steamapi.key
				end
				
				-- check and convert parameters
				for key, info in pairs(parameters) do
					local t = type(data[key])
					local expected = type_translate[info.type] or info.type
					
					if t == "stringnumber" then
						local num = tonumber(data[key])
						if not num then
							errorf("field %q is not a valid type (expected string got %s)", 2, key, type(data[key]))
						end
					end

					if t == "number" then
						local num = tonumber(data[key])
						
						if not num then
							errorf("field %q is not a valid type (expected number got %s)", 2, key, type(data[key]))
						end
						
						data[key] = num 
					end
					
					if t == "boolean" then
						data[key] = data[key] and "1" or "0"
					end
					
					if t == "string" and expected ~= "stringnumber" and key ~= "key" then
						data[key] = base64.encode(data[key])
					end
					
					if t ~= expected and expected ~= "stringnumber" and not info.optional then
						errorf("field %q is not a valid type (expected %s got %s)", 2, key, expected, type(data[key]))
					end
				end
				
				if steamapi.httpmethods[info.httpmethod] then
					steamapi.httpmethods[info.httpmethod](interface, info, data, callback)
				else
					errorf("http method %s is not supported", 2, info.httpmethod)
				end
			end
		end
		
		steamapi.services[interface.name] = functions
	end
end

function steamapi.UpdateSupported()
	logn("[steamapi] fetching supported api..")
	
	luasocket.Get("http://api.steampowered.com/ISteamWebAPIUtil/GetSupportedAPIList/v0001/?key=" .. steamapi.key, function(data)
		local tbl = json.decode(data.content)
		
		luadata.WriteFile("steamapi/supported.lua", tbl)
		
		logn("[steamapi] supported api updated")
	end)
end

function steamapi.GetService(name)
	return steamapi.services[name]
end

return steamapi