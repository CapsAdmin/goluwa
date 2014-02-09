local steamapi = {}

steamapi.httpmethods = {
	GET = function(interface, func_info, data, url, callback)
		local arguments = ""
		
		for key, val in pairs(data) do
			arguments = arguments .. ("%s=%s&"):format(key, val)
		end
		
		-- remove the last &..
		arguments = arguments:sub(0, -2)
		
		url = url .. arguments
	
		luasocket.Get(url, function(data)
			if data.content then
				callback(json.decode(data.content))
			end
		end, nil, "Steam 1291812 / iPhone")
	end,
	POST = function(interface, func_info, data, url, callback)
		luasocket.Post(url, data, function(data)
			callback(json.decode(data.content))
		end, nil, "Steam 1291812 / iPhone")
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
	steamapi.supported = steamapi.supported or luadata.ReadFile("steamapi_supported.lua")
	
	if key == "" then
		logn("steamapi key is not set (run steamapi_key *key*)")
	end

	steamapi.services = {}
	
	if steamapi.supported.apilist then	
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
					if not steamapi.httpmethods[info.httpmethod] then
						errorf("http method %s is not supported", 2, info.httpmethod)
					end
				
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
									
					local url = ("http://api.steampowered.com/%s/%s/v%.4d/?"):format(interface.name, info.name, data.version or 1)
					
					if steamapi.debug then	
						logf("[steamapi] http url: %s", url)
					end				
					
					steamapi.httpmethods[info.httpmethod](interface, info, data, url, callback)
				end
			end
			
			steamapi.services[interface.name] = functions
		end
	else
		steamapi.UpdateSupported(steamapi.Initialize)
	end
end

function steamapi.UpdateSupported(callback)
	logn("[steamapi] fetching supported api..")
	
	luasocket.Get("http://api.steampowered.com/ISteamWebAPIUtil/GetSupportedAPIList/v0001/?key=" .. steamapi.key, function(data)
		if data.content then
			local tbl = json.decode(data.content)
			
			luadata.WriteFile("steamapi_supported.lua", tbl)
			steamapi.supported = tbl
			
			logn("[steamapi] supported api updated")		
			
			callback()
		else
			logn("[steamapi] could not fetch api, no content!")
		end
	end)
end

function steamapi.GetService(name)
	return steamapi.services[name]
end

return steamapi