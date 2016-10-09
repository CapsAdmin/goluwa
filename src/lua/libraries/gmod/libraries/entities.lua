function gmod.LoadEntities(base_folder, global, register, create_table)
	for file_name in vfs.Iterate(base_folder.."/") do
		--logn("gmod: registering ",base_folder," ", file_name)
		if file_name:endswith(".lua") then
			gmod.env[global] = create_table()
			include(base_folder.."/" .. file_name)
			register(gmod.env[global], file_name:match("(.+)%."))
		else
			if SERVER then
				if vfs.IsFile(base_folder.."/" .. file_name .. "/init.lua") then
					gmod.env[global] = create_table()
					gmod.env[global].Folder = base_folder:sub(5) .. "/" .. file_name -- weapons/gmod_tool/stools/
					include(base_folder.."/" .. file_name .. "/init.lua")
					register(gmod.env[global], file_name)
				end
			end

			if CLIENT then
				if vfs.IsFile(base_folder.."/" .. file_name .. "/cl_init.lua") then
					gmod.env[global] = create_table()
					gmod.env[global].Folder = base_folder:sub(5) .. "/" .. file_name
					include(base_folder.."/" .. file_name .. "/cl_init.lua")
					register(gmod.env[global], file_name)
				end
			end
		end
	end
	gmod.env[global] = nil
end

do
	function gmod.env.ents.FindByClass(name)
		local out = {}

		for obj, ent in pairs(gmod.objects.Entity) do
			if not ent.ClassName then
				print(ent)
				table.print(ent)
			else
				if ent.ClassName:find(name) then
					table.insert(out, ent)
				end
			end
		end

		return out
	end
end

do
	function gmod.env.ents.Create(class)
		local ent = entities.CreateEntity("visual")

		local self = gmod.WrapObject(ent, "Entity")

		self.ClassName = class
		self.BaseClass = gmod.env.scripted_ents.Get(class)

		table.insert(gmod.env.ents.created, self)

		return self
	end

	function gmod.env.ents.CreateClientProp(mdl)
		local ent = gmod.env.ents.Create("prop_physics")
		ent:SetModel(mdl)
		return ent
	end

	function gmod.env.ents.GetAll()
		local out = {}
		local i = 1

		for obj, ent in pairs(gmod.objects.Entity) do
			table.insert(out, ent)
		end

		return out
	end

	local META = gmod.GetMetaTable("Entity")

	function META:__newindex(k,v)
		if not rawget(self, "__storable_table") then rawset(self, "__storable_table", {}) end
		self.__storable_table[k] = v
	end

	function META:GetTable()
		if not rawget(self, "__storable_table") then rawset(self, "__storable_table", {}) end
		return self.__storable_table
	end

	function META:SetPos(vec)
		self.__obj:SetPosition(vec.v)
	end

	function META:GetPos()
		if self == gmod.env.LocalPlayer() then
			return gmod.env.EyePos()
		end
		return gmod.env.Vector(self.__obj:GetPosition())
	end

	function META:GetForward()
		return gmod.env.Vector(self.__obj:GetRotation():GetForward())
	end

	function META:GetUp()
		return gmod.env.Vector(self.__obj:GetRotation():GetUp())
	end

	function META:GetRight()
		return gmod.env.Vector(self.__obj:GetRotation():GetRight())
	end

	function META:EyePos()
		if self == gmod.env.LocalPlayer() then
			return gmod.env.EyePos()
		end
		return gmod.env.Vector()
	end

	function META:EyeAngles()
		if self == gmod.env.LocalPlayer() then
			return gmod.env.EyeAngles()
		end
		return gmod.env.Angle()
	end

	function META:GetBoneCount()
		return 0
	end

	function META:EntIndex()
		return -1
	end

	function META:Health()
		return 100
	end

	function META:GetMaxHealth()
		return 100
	end

	function META:GetName()
		if self.MetaName == "Player" then
			return self:Nick()
		end

		return ""
	end

	function META:GetNetworkedString(what)
		if what == "UserGroup" then
			return "Player"
		end
	end

	function META:SetNoDraw() end
	function META:SetAngles() end
	function META:GetNumBodyGroups() return 1 end
	function META:GetBodygroupCount() return 1 end
	function META:SkinCount() return 1 end
	function META:LookupSequence() return -1 end
	function META:DrawModel() end

	function META:GetClass()
		return self.ClassName or self.MetaName
	end

	function META:GetNWFloat(key, def)
		return def or 0
	end

	function META:GetNWEntity(key, def)
		return def or _G.NULL
	end

	function META:GetVelocity()
		return gmod.env.Vector(0, 0, 0)
	end

	function META:IsFlagSet()
		return false
	end

	function META:GetOwner()
		return NULL
	end

	function META:GetSkin()
		return 0
	end

	function META:GetModel()
		return ""
	end

	function META:IsDormant()
		return true
	end

	function META:GetSpawnEffect()
		return false
	end

	function META:GetNWBool()
		return false
	end

	function META:GetMoveType()
		return gmod.env.MOVETYPE_NONE
	end

	function gmod.env.ClientsideModel(path)
		local ent = entities.CreateEntity("visual")
		ent:SetModelPath(path)
		return gmod.WrapObject(ent, "Entity")
	end

	function META:LocalToWorld()
		return gmod.env.Vector()
	end

	function META:OBBCenter()
		return gmod.env.Vector()
	end
end