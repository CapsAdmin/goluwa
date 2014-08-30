steam.webapi_httpmethods = {
	GET = function(interface, func_info, data, url, callback)
		local arguments = ""
		
		for key, val in pairs(data) do
			arguments = arguments .. ("%s=%s&"):format(key, val)
		end
		
		-- remove the last &..
		arguments = arguments:sub(0, -2)
		
		url = url .. arguments
	
		sockets.Get(url, function(data)
			if data.content then
				callback(serializer.Decode("json", data.content))
			end
		end, nil, "Steam 1291812 / iPhone")
	end,
	POST = function(interface, func_info, data, url, callback)
		sockets.Post(url, data, function(data)
			callback(serializer.Decode("json", data.content))
		end, nil, "Steam 1291812 / iPhone")
	end,
}

local type_translate = {
	uint32 = "number",
	uint64 = "stringnumber",
	bool = "boolean",
}

console.CreateVariable("steam_webapi_key", "")

function steam.GetWebAPIKey()
	return console.GetVariable("steam_webapi_key", "")
end

function steam.InitializeWebAPI()
	steam.key = steam.GetWebAPIKey()
	steam.supported = steam.supported or serializer.ReadFile("luadata", "steam_webapi_supported.lua")
	
	if key == "" then
		logn("steam key is not set (run steam_webapi_key *key*)")
	end

	steam.services = {}
	
	if steam.supported.apilist then	
		for key, interface in pairs(steam.supported.apilist.interfaces) do
			local functions = {}
			
			for key, info in pairs(interface.methods) do
				local parameters = {}
				
				for key, val in pairs(info.parameters) do
					if val.optional == false then
						parameters[val.name] = val
					end
				end
				
				functions[info.name] = function(data, callback)
					if not steam.webapi_httpmethods[info.httpmethod] then
						errorf("http method %s is not supported", 2, info.httpmethod)
					end
				
					callback = callback or table.print

					if parameters.key and not data.key then
						data.key = steam.key
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
							data[key] = crypto.Base64Encode(data[key])
						end
						
						if t ~= expected and expected ~= "stringnumber" and not info.optional then
							errorf("field %q is not a valid type (expected %s got %s)", 2, key, expected, type(data[key]))
						end
					end
									
					local url = ("http://api.steampowered.com/%s/%s/v%.4d/?"):format(interface.name, info.name, data.version or 1)
					
					if steam.debug then	
						logf("[steam] http url: %s\n", url)
					end				
					
					steam.webapi_httpmethods[info.httpmethod](interface, info, data, url, callback)
				end
			end
			
			steam.services[interface.name] = functions
		end
	else
		steam.UpdateSupportedWebAPI(steam.InitializeWebAPI)
	end
end

function steam.UpdateSupportedWebAPI(callback)
	logn("[steam] fetching supported api..")
	
	sockets.Get("http://api.steampowered.com/ISteamWebAPIUtil/GetSupportedAPIList/v0001/?key=" .. steam.key, function(data)
		if data.content then
			local tbl = serializer.Decode("json", data.content)
			
			serializer.WriteFile("luadata", "steam_webapi_supported.lua", tbl)
			steam.supported = tbl
			
			logn("[steam] supported api updated")		
			
			callback()
		else
			logn("[steam] could not fetch api, no content!")
		end
	end)
end

function steam.GetWebAPIService(name)
	return steam.services[name]
end

return steam