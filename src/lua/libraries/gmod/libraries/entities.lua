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

		local meta = gine.env.scripted_ents.Get(class)

		if meta then
			self.BaseClass = meta

			for k,v in pairs(self.BaseClass) do
				self[k] = v
			end
		else
			llog("creating non lua registered entity: %s", class)
		end

		gine.env.ents.created = gine.env.ents.created or {}

		table.insert(gine.env.ents.created, self)

		return self
	end

	do
		local META = gine.GetMetaTable("Player")

		function META:Give(class_name)
			llog("give %s", class_name)
		end
	end

	function gine.env.ents.CreateClientProp(mdl)
		llog("ents.CreateClientProp: %s", mdl)
		local ent = gine.env.ents.Create("class C_PhysPropClientside")
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
		if self.__obj.SetPosition then
			self.__obj:SetPosition(vec.v)
		end

		self.__obj.gine_pos = vec
	end

	function META:GetPos()
		if self == gine.env.LocalPlayer() then
			return gine.env.EyePos()
		end

		if self.__obj.GetPosition then
			return gine.env.Vector(self.__obj:GetPosition())
		end

		return (self.__obj.gine_pos and (self.__obj.gine_pos * 1)) or gine.env.Vector(0,0,0)
	end

	function META:SetAngles(ang)

		self.__obj.gine_ang = ang
	end

	function META:GetAngles()
		if self == gine.env.LocalPlayer() then
			return gine.env.EyeAngles()
		end

		if self.__obj.GetRotation then
			return gine.env.Angle(self.__obj:GetRotation():GetAngles())
		end

		return (self.__obj.gine_ang and (self.__obj.gine_ang * 1)) or gine.env.Angle(0,0,0)
	end

	function META:GetForward()
		if self.__obj.GetRotation then
			return gine.env.Vector(self.__obj:GetRotation():GetForward())
		end

		return gine.env.Vector(0,0,0)
	end

	function META:GetUp()
		if self.__obj.GetRotation then
			return gine.env.Vector(self.__obj:GetRotation():GetUp())
		end

		return gine.env.Vector(0,0,0)
	end

	function META:GetRight()
		if self.__obj.GetRotation then
			return gine.env.Vector(self.__obj:GetRotation():GetRight())
		end

		return gine.env.Vector(0,0,0)
	end

	function META:EyePos()
		if self == gine.env.LocalPlayer() then
			return gine.env.EyePos()
		end

		return self:GetPos()
	end

	function META:EyeAngles()
		if self == gine.env.LocalPlayer() then
			return gine.env.EyeAngles()
		end

		return self:GetAngles()
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

	function META:GetNumBodyGroups() return 1 end
	function META:GetBodygroupCount() return 1 end
	function META:SkinCount() return 1 end
	function META:LookupSequence() return -1 end
	function META:DrawModel() end
	function META:FrameAdvance() end

	function META:GetClass()
		return self.ClassName or self.MetaName
	end

	function META:OnGround()
		return false
	end

	gine.GetSet(META, "Material", "")
	gine.GetSet(META, "Velocity", function() return gine.env.Vector(0,0,0) end)
	gine.GetSet(META, "Model")
	gine.GetSet(META, "ModelScale")
	gine.GetSet(META, "LOD", 0)
	gine.GetSet(META, "Skin", 0)
	gine.GetSet(META, "Owner", NULL)
	gine.GetSet(META, "Color", function() return gine.env.Color(255, 255, 255, 255) end)
	gine.GetSet(META, "MoveType", function() return gine.env.MOVETYPE_NONE end)
	gine.GetSet(META, "MoveType", function() return gine.env.MOVETYPE_NONE end)
	gine.GetSet(META, "NoDraw", false)
	gine.GetSet(META, "MaxHealth", 100)
	gine.GetSet(META, "Health", 100)

	META.Health = META.GetHealth

	function META:IsFlagSet()
		return false
	end

	function META:EnableMatrix()

	end

	function META:GetSequenceActivity()
		return 0
	end

	function META:IsDormant()
		return true
	end

	function META:IsInWorld()
		return true
	end

	function META:GetSpawnEffect()
		return false
	end

	function META:BoundingRadius()
		return 1
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

	function META:OBBMins()
		return gine.env.Vector()
	end

	function META:OBBMaxs()
		return gine.env.Vector()
	end

	function META:WorldSpaceCenter()
		return gine.env.Vector()
	end

	function META:NearestPoint()
		return gine.env.Vector()
	end

	function META:SetKeyValue(key, val)
		self.__obj.keyvalues = self.__obj.keyvalues or {}
		self.__obj.keyvalues[key] = val
	end

	function META:GetKeyValues()
		self.__obj.keyvalues = self.__obj.keyvalues or {}
		return table.copy(self.__obj.keyvalues)
	end

	function META:DeleteOnRemove()

	end

	function META:Spawn()
		self:InstallDataTable()
		if self.SetupDataTables then
			self:SetupDataTables()
		end
		if self.Initialize then
			self:Initialize()
		end
	end

	function META:Activate()

	end

	function META:SetParent()

	end

	function META:GetParent()
		return NULL
	end

	function META:AddEffects()

	end

	function META:SetShouldServerRagdoll()

	end

	function META:SetNotSolid(b)

	end

	function META:DrawShadow(b)

	end

	function META:SetTransmitWithParent()

	end

	function META:SetBodygroup()

	end
end
