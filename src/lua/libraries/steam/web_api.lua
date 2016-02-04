if not SOCKETS then return end

local steam = ... or _G.steam

local patch = {
	{
		https = true,
		name = "ISteamUserOAuth",
		methods = {
			{
				httpmethod = "GET",
				name = "GetFriendList",
				version = 1,
				parameters = {
					{
						type = "string",
						optional = false,
						name = "access_token",
						description = "OAuth2 token for which to return details",
					},
					{
						type = "string",
						optional = true,
						name = "steamid",
						description = "steam id",
					},
				},
			},
		},
	},
	{
		https = true,
		name = "ISteamOAuth2",
		methods = {
			{
				httpmethod = "POST",
				name = "GetTokenWithCredentials",
				version = 1,
				parameters = {
					{
						type = "string",
						optional = false,
						description = "oauth client id",
						name = "client_id",
						default = "DE45CD61",
					},
					{
						type = "string",
						optional = false,
						description = "grant type",
						name = "grant_type",
						default = "password",
					},
					{
						type = "string",
						optional = false,
						description = "username",
						name = "username",
					},
					{
						type = "string",
						optional = false,
						description = "password",
						name = "password",
					},
					{
						type = "string",
						optional = true,
						description = "steam guard code",
						name = "x_emailauthcode",
						default = "",
					},
					{
						type = "string",
						optional = false,
						description = "scope",
						name = "scope",
						default = "read_profile write_profile read_client write_client",
					},
				}
			}
		},
	},
	{
		https = true,
		name = "ISteamWebUserPresenceOAuth",
		methods = {
			{
				httpmethod = "GET",
				name = "Logon",
				version = 1,
				parameters = {
					{
						type = "string",
						optional = false,
						description = "access token",
						name = "acess_token",
					},
				}
			},
			{
				httpmethod = "GET",
				name = "Message",
				version = 1,
				parameters = {
					{
						type = "string",
						optional = false,
						description = "access token",
						name = "acess_token",
					},
					{
						type = "string",
						optional = false,
						description = "no idea",
						name = "umqid",
					},
					{
						type = "string",
						optional = false,
						description = "like \"saytext\"",
						name = "type",
						default = "saytext",
					},
					{
						type = "string",
						optional = false,
						description = "what you want to say",
						name = "text",
					},
					{
						type = "string",
						optional = false,
						description = "targets steam id",
						name = "steamid_dst",
					},
				}
			},
		},
	}
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

function steam.InitializeWebAPI(force)
	if force then
		steam.supported = nil
	end

	if not steam.supported then
		steam.supported = serializer.ReadFile("luadata", "steam_webapi_supported.lua") or {}

		if steam.supported.apilist then
			for patch_key, patched_interface in pairs(patch) do
				for _, interface in pairs(steam.supported.apilist.interfaces) do
					if patched_interface.name == interface.name then
						table.add(interface.methods, patched_interface.methods)
						patch[patch_key] = nil
					end
				end
			end
			table.print(patch)
			table.add(steam.supported.apilist.interfaces, patch)
		end
	end

	if key == "" then
		logn("steam key is not set (run steam_webapi_key *key*)")
	end

	steam.services = {}

	if steam.supported.apilist then
		for key, interface in pairs(steam.supported.apilist.interfaces) do
			local functions = {}

			for key, info in pairs(interface.methods) do
				local parameters = {}

				for i, val in pairs(info.parameters) do
					if val.optional == false then
						val.i = i
						parameters[val.name] = val
					end
				end

				functions[info.name] = function(data, callback)
					if not data then
						callback = data
						data = {}
					end

					--[[if type(data) ~= "table" and type(callback) ~= "function" and (select("#", ...) == 0 or type(select(select("#", ...), ...)) == "function") then
						local args = {data, callback, ...}
						if type(args[#args]) == "function" then
							callback = table.remove(args)
						end
						data = {}
						for name, info in pairs(parameters) do
							data[name] = args[info.i]
						end
					end]]

					callback = callback or table.print

					data.key = steam.GetWebAPIKey()

					-- check and convert parameters
					for key, info in pairs(parameters) do
						if data[key] == nil and info.default then data[key] = info.default end

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

						if t ~= expected and not info.optional and (expected ~= "stringnumber" or t ~= "string") then
							errorf("field %q (%s) is not a valid type (expected %s got %s)", 2, key, info.description, expected, type(data[key]))
						end
					end

					local url = ("%s://api.steampowered.com/%s/%s/v%.4d/?"):format(interface.https and "https" or "http", interface.name, info.name, data.version or 1)

					if steam.debug then
						llog("http url: %s", url)
					end

					local arguments = ""

					if info.httpmethod == "GET" then
						arguments = "?"
					end

					for key, val in pairs(data) do
						arguments = arguments .. ("%s=%s&"):format(key, val)
					end

					arguments = arguments:sub(0, -2)

					sockets.Request({
						method = info.httpmethod,
						host = "api.steampowered.com",
						ssl_parameters = interface.https and "https",
						location = ("%s/%s/v%.4d%s"):format(interface.name, info.name, data.version or 1, info.httpmethod == "GET" and arguments or ""),
						post_data = info.httpmethod == "POST" and arguments,
						header = {
							["Content-type"] = "/application/x-www-form-urlencoded",
							["User-Agent"] = "Steam 1291812 / iPhone",
							["Accept-Language"] = "en-us",
							["Accept-Encoding"] = "gzip, deflate",
							["Accept"] = "*/*",
						},
						callback = function(data)
							local tbl, err = serializer.Decode("json", data.content)

							if not tbl then
								llog("failed to decode data from %s::%s", interface.name, info.name)
								logn("\turl = ", url)
								logn("\thtml = ", data.content:gsub("%b<>", "\n"):gsub("%s+", " "):trim())
								return
							end

							callback(tbl.result)
						end,
					})
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

	sockets.Get("https://api.steampowered.com/ISteamWebAPIUtil/GetSupportedAPIList/v0001/?key=" .. steam.GetWebAPIKey(), function(data)
		if data.content then
			local tbl = serializer.Decode("json", data.content)

			if not tbl.apilist then
				logn("[steam] could not fetch api, no apilist")
				print(data.content)
				return
			end

			serializer.WriteFile("luadata", "steam_webapi_supported.lua", tbl)
			steam.supported = tbl

			logn("[steam] supported api updated")

			if callback then callback() end
		else
			logn("[steam] could not fetch api, no content!")
		end
	end)
end

function steam.GetWebAPIService(name)
	return steam.services[name]
end

if RELOAD then
	steam.InitializeWebAPI(true)
end
