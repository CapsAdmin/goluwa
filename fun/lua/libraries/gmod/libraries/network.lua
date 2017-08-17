do
	local fake = {}
	local counter = 0
	function gine.env.util.AddNetworkString(str)
		counter = counter + 1
		fake[str] = counter
		return counter
		--return network.AddString(str)
	end

	function gine.env.util.NetworkStringToID(str)
		--return network.StringToID(str)
		return fake[str] or tonumber(crypto.CRC32(str))
	end

	function gine.env.util.NetworkIDToString(id)
		--return network.IDToString(id) or ""
		for k,v in pairs(fake) do
			if v == id then
				return k
			end
		end
	end

	function gine.env.net.Start()

	end

	function gine.env.net.SendToServer()

	end

	function gine.env.net.BytesWritten()
		return 0
	end

	function gine.env.net.Send()

	end

	function gine.env.net.Broadcast()

	end
end

if SERVER then
	function gine.env.umsg.PoolString()

	end
end

do
	local META = gine.GetMetaTable("Player")
	function META:GetInfoNum(key, def)
		return def or 0
	end

	function META:GetInfo()

	end

end

do
	local META = gine.GetMetaTable("Entity")

	do
		local types = {
			Vector = {"Vector", function() return gine.env.Vector() end},
			Angle = {"Angle", function() return gine.env.Angle() end},
			Bool = {"boolean", false},
			Float = {"number", 0},
			Int = {"number", 0},
			String = {"string", ""},
			Entity = {"Entity", NULL},
		}

		-- Set/GetNW/NW2/NetworkedVar*
		for name, info in pairs(types) do
			META["SetNW" .. name] = function(self, key, val)
				self.__vars.nwvars = self.__vars.nwvars or {}

				if
					(name == "Entity" and gine.env.IsEntity(val)) or
					(name ~= "Entity" and gine.env.type(val) ~= info[1])
				then
					if type(info[2]) == "function" then
						val = info[2]()
					else
						val = info[2]
					end
				end

				self.__vars.nwvars[key] = val
			end

			META["GetNW" .. name] = function(self, key, def)
				self.__vars.nwvars = self.__vars.nwvars or {}

				if self.__vars.nwvars[key] == nil then
					if def ~= nil then
						return def
					end

					if type(info[2]) == "function" then
						return info[2]()
					else
						return info[2]
					end
				end

				return self.__vars.nwvars[key]
			end

			META["GetNW2" .. name] = META["GetNW" .. name]
			META["SetNW2" .. name] = META["SetNW" .. name]

			META["GetNetworked" .. name] = META["GetNW" .. name]
			META["SetNetworked" .. name] = META["SetNW" .. name]
		end

		-- Set/Get/DT*
		for name, info in pairs(types) do
			META["SetDT" .. name] = function(self, i, val)
				self.__vars.dtvars = self.__vars.dtvars or {}
				self.__vars.dtvars[name] = self.__vars.dtvars[name] or {}

				if
					(name == "Entity" and gine.env.IsEntity(val)) or
					(name ~= "Entity" and gine.env.type(val) ~= info[1])
				then
					if type(info[2]) == "function" then
						val = info[2]()
					else
						val = info[2]
					end
				end

				self.__vars.dtvars[name][i] = val
			end

			META["GetDT" .. name] = function(self, i)
				self.__vars.dtvars = self.__vars.dtvars or {}
				self.__vars.dtvars[name] = self.__vars.dtvars[name] or {}

				if self.__vars.dtvars[name][i] == nil then
					if type(info[2]) == "function" then
						return info[2]()
					else
						return info[2]
					end
				end

				return self.__vars.dtvars[name][i]
			end
		end
	end
end
-- setupdt

for k,v in pairs(gine.env.net) do
	if k:startswith("Write") or k:startswith("Start") then
		gine.env.net[k] = function() end
	end
end

function gine.env.GetHostName()
	return network.GetHostname() or "no hostname!"
end

do
	gine.nw_globals = {}

	local function ADD(name)
		gine.env["SetGlobal" .. name] = function(key, val) gine.nw_globals[key] = val end
		gine.env["GetGlobal" .. name] = function(key) return gine.nw_globals[key] end
	end

	ADD("String")
	ADD("Int")
	ADD("Float")
	ADD("Vector")
	ADD("Angle")
	ADD("Entity")
	ADD("Bool")
end

function gine.env.game.MaxPlayers()
	return 32
end

function gine.env.game.SinglePlayer()
	return false
end
