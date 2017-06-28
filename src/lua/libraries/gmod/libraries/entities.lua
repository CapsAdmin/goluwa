function gine.LoadEntities(base_folder, global, register, create_table)
	for file_name in vfs.Iterate(base_folder.."/") do
		--logn("gine: registering ",base_folder," ", file_name)
		if file_name:endswith(".lua") then
			local tbl = create_table()
			tbl.Folder = base_folder:sub(0, -5)
			gine.env[global] = tbl
			runfile(base_folder .. "/" .. file_name)
			register(gine.env[global], file_name:match("(.+)%."))
		else
			if SERVER then
				if vfs.IsFile(base_folder .. "/" .. file_name .. "/init.lua") then
					local tbl = create_table()
					tbl.Folder = base_folder .."/" .. file_name:sub(0, -5)
					gine.env[global] = tbl
					gine.env[global].Folder = base_folder:sub(5) .. "/" .. file_name -- weapons/gmod_tool/stools/
					runfile(base_folder.."/" .. file_name .. "/init.lua")
					register(gine.env[global], file_name)
				end
			end

			if CLIENT then
				if vfs.IsFile(base_folder .. "/" .. file_name .. "/cl_init.lua") then
					local tbl = create_table()
					tbl.Folder = base_folder .. "/" .. file_name:sub(0, -5)
					gine.env[global] = tbl
					gine.env[global].Folder = base_folder:sub(5) .. "/" .. file_name
					runfile(base_folder .. "/" .. file_name .. "/cl_init.lua")
					register(gine.env[global], file_name)
				end
			end
		end
	end
	gine.env[global] = nil
end

do
	function gine.env.ents.FindByClass(name)
		local out = {}

		for obj, ent in pairs(gine.objects.Entity) do
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

	function gine.env.ents.FindInSphere(pos)
		return {}
	end
end

do
	function gine.env.ents.Create(class)
		local ent = entities.CreateEntity("visual")

		local self = gine.WrapObject(ent, "Entity")

		self.ClassName = class
		self.BaseClass = gine.env.scripted_ents.Get(class)

		gine.env.ents.created = gine.env.ents.created or {}

		table.insert(gine.env.ents.created, self)

		return self
	end

	function gine.env.ents.CreateClientProp(mdl)
		llog("ents.CreateClientProp: %s", mdl)
		local ent = gine.env.ents.Create("prop_physics")
		ent:SetModel(mdl)
		return ent
	end

	function gine.env.ents.GetAll()
		local out = {}
		local i = 1

		for obj, ent in pairs(gine.objects.Entity) do
			table.insert(out, ent)
		end

		return out
	end

	local META = gine.GetMetaTable("Entity")

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
		if self == gine.env.LocalPlayer() then
			return gine.env.EyePos()
		end
		return gine.env.Vector(self.__obj:GetPosition())
	end

	function META:GetAngles()
		if self == gine.env.LocalPlayer() then
			return gine.env.EyeAngles()
		end
		return gine.env.Angle(self.__obj:GetRotation():GetAngles())
	end

	function META:GetForward()
		return gine.env.Vector(self.__obj:GetRotation():GetForward())
	end

	function META:GetUp()
		return gine.env.Vector(self.__obj:GetRotation():GetUp())
	end

	function META:GetRight()
		return gine.env.Vector(self.__obj:GetRotation():GetRight())
	end

	function META:EyePos()
		if self == gine.env.LocalPlayer() then
			return gine.env.EyePos()
		end
		return gine.env.Vector()
	end

	function META:EyeAngles()
		if self == gine.env.LocalPlayer() then
			return gine.env.EyeAngles()
		end
		return gine.env.Angle()
	end

	function META:InvalidateBoneCache()

	end

	function META:GetBoneCount()
		return 0
	end

	function META:LookupBone(name)
		return 0
	end

	function META:GetBoneName()
		return "none"
	end

	function META:SetupBones()

	end

	function META:GetBonePosition()
		return self:GetPos(), self:GetAngles()
	end

	function META:GetBoneParent()
		return -1
	end

	function META:GetParentAttachment()
		return 0
	end

	function META:GetAttachments()
		return {
			{
				id = 1,
				name = "none",
			},
		}
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

	function META:GetBoneMatrix()

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
	function META:FrameAdvance() end

	function META:GetClass()
		return self.ClassName or self.MetaName
	end

	function META:GetNWFloat(key, def)
		return def or 0
	end

	function META:GetNWInt(key, def)
		return def or 0
	end

	function META:GetNWEntity(key, def)
		return def or _G.NULL
	end

	function META:OnGround()
		return false
	end

	for k, v in pairs(META) do
		if k:startswith("GetNW") then
			META[k:gsub("GetNW", "GetNW2")] = v
		end
	end

	function META:GetVelocity()
		return gine.env.Vector(0, 0, 0)
	end

	function META:IsFlagSet()
		return false
	end

	function META:EnableMatrix()

	end

	function META:SetModel(path)
		llog(path)
	end

	function META:SetLOD()

	end

	function META:SetModelScale(scale)
		self.model_scale = scale
	end

	function META:GetModelScale()
		return self.model_scale
	end

	function META:SetColor(color)
		self.color = color
	end

	function META:GetColor()
		return self.color or gine.env.Color(255, 255, 255, 255)
	end

	function META:GetOwner()
		return NULL
	end

	function META:SetSkin(num)
		self.skin = num
	end

	function META:GetSkin()
		return self.skin or 0
	end

	function META:GetSequenceActivity()
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
		return gine.env.MOVETYPE_NONE
	end

	function META:BoundingRadius()
		return 1
	end

	function META:GetModelScale()
		return 1
	end

	function META:GetNoDraw()
		return false
	end

	function gine.env.ClientsideModel(path)
		llog("ClientsideModel: %s", path)
		local ent = gine.env.ents.Create("prop_physics")
		ent:SetModel(path)
		return ent
	end

	function META:LocalToWorld()
		return gine.env.Vector()
	end

	function META:OBBCenter()
		return gine.env.Vector()
	end
end
