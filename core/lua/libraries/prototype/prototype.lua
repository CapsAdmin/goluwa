local prototype = _G.prototype or {}

prototype.registered = prototype.registered or {}
prototype.prepared_metatables = prototype.prepared_metatables or {}

local template_functions = {
	"GetSet",
	"IsSet",
	"Delegate",
	"GetSetDelegate",
	"DelegateProperties",
	"RemoveField",
	"StartStorable",
	"EndStorable",
	"Register",
	"RegisterComponent",
	"CreateObject",
}

function prototype.CreateTemplate(super_type, sub_type)
	local template = type(super_type) == "table" and super_type or {}

	if type(super_type) == "string" then
		template.Type = super_type
		template.ClassName = sub_type or super_type
	end

	for _, key in ipairs(template_functions) do
		template[key] = prototype[key]
	end

	return template
end

do
	local function checkfield(tbl, key, def)
		tbl[key] = tbl[key] or def

		if not tbl[key] then
			error(string.format("The type field %q was not found!", key), 3)
		end

		return tbl[key]
	end

	local blacklist = {
		prototype_variables = true,
		Events = true,
		Require = true,
		Network = true,
		write_functions = true,
		read_functions = true,
		Args = true,
		type_ids = true,
		storable_variables = true,
		ProtectedFields = true,
	}

	function prototype.Register(meta, super_type, sub_type)
		local super_type = checkfield(meta, "Type", super_type)
		sub_type = sub_type or super_type
		local sub_type = checkfield(meta, "ClassName", sub_type)

		for _, key in ipairs(template_functions) do
			if key ~= "CreateObject" and meta[key] == prototype[key] then
				meta[key] = nil
			end
		end

		prototype.registered[super_type] = prototype.registered[super_type] or {}
		prototype.registered[super_type][sub_type] = meta

		prototype.invalidate_meta = prototype.invalidate_meta or {}
		prototype.invalidate_meta[super_type] = true

		if RELOAD then
			prototype.UpdateObjects(meta)

			for k,v in pairs(meta) do
				if type(v) ~= "function" and not blacklist[k] then
					local found = false
					if meta.prototype_variables then
						for _,v in pairs(meta.prototype_variables) do
							if v.var_name == k then
								found = true
								break
							end
						end
					end
					local t = type(v)
					if t == "number" or t == "string" or t == "function" or t == "boolean" or typex(v) == "null" then
						found = true
					end
					if not found then
						wlog("%s: META.%s = %s is mutable", meta.ClassName, k, tostring(v), 2)
					end
				end
			end
		end

		return super_type, sub_type
	end
end

function prototype.RebuildMetatables(what)
	for super_type, sub_types in pairs(prototype.registered) do
		if what == nil or what == super_type then
			prototype.invalidate_meta[what] = nil

			for sub_type, meta in pairs(sub_types) do

				local copy = {}
				local prototype_variables = {}

				-- first add all the base functions from the base object
				for k, v in pairs(prototype.base_metatable) do
					copy[k] = v
					if k == "prototype_variables" then for k,v in pairs(v) do prototype_variables[k] = v end end
				end

				-- if this metatable has a type base derive from it first
				if meta.TypeBase then
					for k, v in pairs(sub_types[meta.TypeBase]) do
						copy[k] = v
						if k == "prototype_variables" then for k,v in pairs(v) do prototype_variables[k] = v end end
					end
				end

				-- then go through the list of bases and derive from them in reversed order
				local base_list = {}

				if meta.Base then
					table.insert(base_list, meta.Base)

					local base = meta

					for _ = 1, 50 do
						base = sub_types[base.Base]
						if not base or not base.Base then break end
						table.insert(base_list, 1, base.Base)
					end

					for _, v in ipairs(base_list) do
						local base = sub_types[v]

						-- the base might not be registered yet
						-- however this will be run again once it actually is
						if base then
							for k, v in pairs(base) do
								copy[k] = v
								if k == "prototype_variables" then for k,v in pairs(v) do prototype_variables[k] = v end end
							end
						end
					end
				end

				-- finally the actual metatable
				for k, v in pairs(meta) do
					copy[k] = v
					if k == "prototype_variables" then for k,v in pairs(v) do prototype_variables[k] = v end end
				end

				do
					local tbl = {}

					for _, info in pairs(prototype_variables) do
						if info.copy then
							table.insert(tbl, info)
						end
					end

					copy.copy_variables = tbl[1] and tbl
				end

				if copy.__index2 then
					copy.__index = function(s, k) return copy[k] or copy.__index2(s, k) end
				else
					copy.__index = copy
				end

				copy.BaseClass = sub_types[base_list[#base_list] or meta.TypeBase]
				meta.BaseClass = copy.BaseClass

				prototype.prepared_metatables[super_type] = prototype.prepared_metatables[super_type] or {}
				prototype.prepared_metatables[super_type][sub_type] = copy
			end
		end
	end
end

function prototype.GetRegistered(super_type, sub_type)
	sub_type = sub_type or super_type

	if prototype.registered[super_type] and prototype.registered[super_type][sub_type] then
		if prototype.invalidate_meta[super_type] then
			prototype.RebuildMetatables(super_type)
		end
		return prototype.prepared_metatables[super_type][sub_type]
	end
end

function prototype.GetRegisteredSubTypes(super_type)

	return prototype.registered[super_type]
end

function prototype.GetAllRegistered()
	local out = {}

	for _, sub_types in pairs(prototype.registered) do
		for _, meta in pairs(sub_types) do
			table.insert(out, meta)
		end
	end

	return out
end

local function remove_callback(self)
	if (not self.IsValid or self:IsValid()) and self.Remove then
		self:Remove()
	end

	if prototype.created_objects then
		prototype.created_objects[self] = nil
	end
end

function prototype.OverrideCreateObjectTable(obj)
	prototype.override_object = obj
end

do
	local DEBUG = DEBUG or DEBUG_OPENGL
	local setmetatable = setmetatable
	local type = type
	local ipairs = ipairs
	prototype.created_objects = prototype.created_objects or setmetatable({}, {__mode = "kv"})

	function prototype.CreateObject(meta, override, skip_gc_callback)
		override = override or prototype.override_object or {}

		if type(meta) == "string" then
			meta = prototype.GetRegistered(meta)
		end

		-- this has to be done in order to ensure we have the prepared metatable with bases
		meta = prototype.GetRegistered(meta.Type, meta.ClassName) or meta

		if not skip_gc_callback then
			meta.__gc = remove_callback
		end

		local self = setmetatable(override, meta)

		if meta.copy_variables then
			for _, info in ipairs(meta.copy_variables) do
				self[info.var_name] = info.copy()
			end
		end

		prototype.created_objects[self] = self

		if DEBUG then
			self:SetDebugTrace(debug.traceback())
			self:SetCreationTime(system and system.GetElapsedTime and system.GetElapsedTime() or os.clock())
		end

		return self
	end
end

do
	prototype.linked_objects = prototype.linked_objects or {}

	function prototype.AddPropertyLink(...)

		event.AddListener("Update", "update_object_properties", function()
			for i, data in ipairs(prototype.linked_objects) do
				if type(data.args[1]) == "table" and type(data.args[2]) == "table" then
					local obj_a = data.args[1]
					local obj_b = data.args[2]

					local field_a = data.args[3]
					local field_b = data.args[4]

					local key_a = data.args[5]
					local key_b = data.args[6]

					if obj_a:IsValid() and obj_b:IsValid() then
						local info_a = obj_a.prototype_variables[field_a]
						local info_b = obj_b.prototype_variables[field_b]

						if info_a and info_b then
							if key_a and key_b then
								-- local val = a:GeFieldA().key_a
								-- val.key_a = b:GetFieldB().key_b
								-- a:SetFieldA(val)

								local val = obj_a[info_a.get_name](obj_a)
								val[key_a] = obj_b[info_b.get_name](obj_b)[key_b]

								if data.store.last_val ~= val then
									obj_a[info_a.set_name](obj_a, val)
									data.store.last_val = val
								end
							elseif key_a and not key_b then
								-- local val = a:GeFieldA()
								-- val.key_a = b:GetFieldB()
								-- a:SetFieldA(val)

								local val = obj_a[info_a.get_name](obj_a)
								val[key_a] = obj_b[info_b.get_name](obj_b)

								if data.store.last_val ~= val then
									obj_a[info_a.set_name](obj_a, val)
									data.store.last_val = val
								end
							elseif key_b and not key_a then
								-- local val = b:GeFieldB().key_b
								-- a:SetFieldA(val)

								local val = obj_b[info_b.get_name](obj_b)[key_b]
								if data.store.last_val ~= val then
									obj_a[info_a.set_name](obj_a, val)
									data.store.last_val = val
								end
							else
								-- local val = b:GeFieldB()
								-- a:SetFieldA(val)

								local val = obj_b[info_b.get_name](obj_b)
								if data.store.last_val ~= val then
									obj_a[info_a.set_name](obj_a, val)
									data.store.last_val = val
								end
							end
						end

						if not info_b then
							wlog("unable to find property info for %s (%s)", field_b, obj_b)
						end
					else
						table.remove(prototype.linked_objects, i)
						break
					end
				elseif type(data.args[2]) == "function" and type(data.args[3]) == "function" then
					local obj = data.args[1]
					local get_func = data.args[2]
					local set_func = data.args[3]

					if obj:IsValid() then
						local val = get_func()

						if data.store.last_val ~= val then
							set_func(val)
							data.store.last_val = val
						end
					end
				end
			end
		end)

		table.insert(prototype.linked_objects, {store = table.weak(), args = {...}})
	end

	function prototype.RemovePropertyLink(obj_a, obj_b, field_a, field_b, key_a, key_b)
		for i, v in ipairs(prototype.linked_objects) do
			local obj_a_, obj_b_, field_a_, field_b_, key_a_, key_b_ = unpack(v)
			if
				obj_a == obj_a_ and
				obj_b == obj_b_ and
				field_a == field_a_ and
				field_b == field_b_ and
				key_a == key_a_ and
				key_b == key_b_
			then
				table.remove(prototype.linked_objects, i)
				break
			end
		end
	end

	function prototype.RemovePropertyLinks(obj)
		for i in pairs(prototype.linked_objects) do
			if v[1] == obj then
				prototype.linked_objects[i] = nil
			end
		end

		table.fixindices(prototype.linked_objects)
	end

	function prototype.GetPropertyLinks(obj)
		local out = {}

		for _, v in ipairs(prototype.linked_objects) do
			if v[1] == obj then
				table.insert(out, {unpack(v)})
			end
		end

		return out
	end
end

function prototype.CreateDerivedObject(super_type, sub_type, override, skip_gc_callback)
    local meta = prototype.GetRegistered(super_type, sub_type)

    if not meta then
        llog("tried to create unknown %s %q!", super_type or "no type", sub_type or "no class")
        return
    end

	return prototype.CreateObject(meta, override, skip_gc_callback)
end

function prototype.SafeRemove(obj)
	if hasindex(obj) and obj.IsValid and obj.Remove and obj:IsValid() then
		obj:Remove()
	end
end

function prototype.GetCreated(sorted, super_type, sub_type)
	if sorted then
		local out = {}
		for _, v in pairs(prototype.created_objects) do
			if (not super_type or v.Type == super_type) and (not sub_type or v.ClassName == sub_type) then
				table.insert(out, v)
			end
		end
		table.sort(out, function(a, b) return a:GetCreationTime() < b:GetCreationTime() end)
		return out
	end
	return prototype.created_objects or {}
end

function prototype.FindObject(str)
	local name, property = str:match("(.-):(.+)")
	if not name then name = str end

	local objects = prototype.GetCreated()
	local found

	local function try(compare)
		for obj in pairs(objects) do
			if compare(obj) then
				found = obj
				return true
			end
		end
	end

	local function find_property(obj)
		if not property then return true end
		for _, v in pairs(prototype.GetStorableVariables(obj)) do
			if tostring(obj[v.get_name](obj)):compare(property) then
				return true
			end
		end
	end

	if try(function(obj) return obj:GetName() == name and find_property(obj) end) then return found end
	if try(function(obj) return obj:GetName():compare(name) and find_property(obj) end) then return found end

	if try(function(obj) return obj:GetNiceClassName() == name and find_property(obj) end) then return found end
	if try(function(obj) return obj:GetNiceClassName():compare(name) and find_property(obj) end) then return found end
end

function prototype.UpdateObjects(meta)
	if type(meta) == "string" then
		meta = prototype.GetRegistered(meta)
	end

	if not meta then return end

	for _, obj in pairs(prototype.GetCreated()) do
		local tbl

		if obj.Type == meta.Type and obj.ClassName == meta.ClassName then
			tbl = meta
		elseif obj.Type == meta.Type and obj.TypeBase == meta.ClassName then
			tbl = prototype.GetRegistered(obj.Type, obj.ClassName)
		end

		if tbl then
			if RELOAD then
				for k, v in pairs(tbl) do
					if type(v) == "function" then
						--if not k:startswith("On") then
							obj[k] = v
						--end
					elseif obj[k] == nil then
						obj[k] = v
					end
				end
			else
				for k, v in pairs(tbl) do
					if type(v) == "function" then
						obj[k] = v
					end
				end
			end
		end
	end
end

function prototype.RemoveObjects(super_type, sub_type)
	sub_type = sub_type or super_type
	for _, obj in pairs(prototype.GetCreated()) do
		if obj.Type == super_type and obj.ClassName == sub_type then
			if obj:IsValid() then
				obj:Remove()
			end
		end
	end
end

runfile("get_is_set.lua", prototype)
runfile("base_object.lua", prototype)
runfile("null.lua", prototype)

function prototype.DumpObjectCount()
	local found = {}

	for obj in pairs(prototype.GetCreated()) do
		local name = obj.ClassName
		if obj.ClassName ~= obj.Type then
			name = obj.Type .. "_" .. name
		end
		found[name] = (found[name] or 0) + 1
	end

	local sorted = {}
	for k, v in pairs(found) do
		table.insert(sorted, {k = k, v = v})
	end

	table.sort(sorted, function(a, b) return a.v > b.v end)

	for _, v in ipairs(sorted) do
		logn(v.k, " = ", v.v)
	end
end

return prototype
