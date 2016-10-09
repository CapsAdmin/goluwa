// copy this script to gmod
// lua_openscript_cl build_exported.lua
// lua_openscript build_exported.lua
// copy data/cl_exported.lua to this script's directory
// copy data/sv_exported.lua to this script's directory

local exported = {}
exported.functions = {}
exported.meta = {}
exported.enums = {}

-- enums
for key, val in pairs(_G) do
	if isnumber(val) then
		exported.enums[key] = val
	elseif istable(val) then
		local everything_number = true

		for _, val in pairs(val) do
			if not isnumber(val) then
				everything_number = false
				break
			end
		end

		if everything_number then
			exported.enums[key] = val
		end
	end
end

local whitelist = {
	[_G.Material] = true,
	[vgui.Create] = true,
	[FindMetaTable("Player").ConCommand] = true,
	[FindMetaTable("Panel").SetFGColor] = true,
	[FindMetaTable("Panel").SetBGColor] = true,
}

local blacklist = {
	[vgui.CreateX] = false
	[FindMetaTable("Panel").SetFGColorEx] = true,
	[FindMetaTable("Panel").SetBGColorEx] = true,
}

local function is_c_function(func)
	if blacklist[func] then return false end

	if whitelist[func] or debug.getinfo(func).source == "=[C]" then
		return true
	end
end

local blacklist = {
	_M = true,
	_NAME = true,
	_PACKAGE = true,
}

-- functions
exported.functions.globals = {}
for key, val in pairs(_G) do
	if key == "_G" then continue end
	if isfunction(val) then
		exported.functions.globals[key] = is_c_function(val)
	elseif istable(val) then
		for func_name, func in pairs(val) do
			if not blacklist[func_name] then
				if isfunction(func) and is_c_function(func) then
					exported.functions[key] = exported.functions[key] or {}
					exported.functions[key][func_name] = true
				else
					--print("unexpected value in library " .. key .. ": ", func_name, func)
				end
			end
		end
	end
end

local blacklist = {
	__index = true,
	__gc = true,
	MetaID = true,
	MetaName = true,
	MetaBaseClass = true,
}

-- meta
for key, val in pairs(debug.getregistry()) do
	if istable(val) and val.MetaID and val.MetaName then
		exported.meta[val.MetaName] = {}
		for func_name, func in pairs(val) do
			if not blacklist[func_name] then
				if isfunction(func) and is_c_function(func) then
					exported.meta[val.MetaName][func_name] = true
				else
					--print("unexpected value in metatable " .. val.MetaName .. ": ", func_name, func)
				end
			end
		end
	end
end

local output = "return {\n"


output = output .. "\tenums = {\n"
for k, v in pairs(exported.enums) do
	if isnumber(v) then
		output = output .. "\t\t" .. k .. " = " .. v .. ",\n"
	else
		output = output .. "\t\t" .. k .. " = {\n"
		for k, v in pairs(v) do
			output = output .. "\t\t\t" .. k .. " = " .. v .. ",\n"
		end
		output = output .. "\t\t},\n"
	end
end
output = output .. "\t},\n"


output = output .. "\tmeta = {\n"
for meta_name, functions in pairs(exported.meta) do
	output = output .. "\t\t" .. meta_name .. " = {\n"
	for name in pairs(functions) do
		output = output .. "\t\t\t" .. name .. " = true,\n"
	end
	output = output .. "\t\t},\n"
end
output = output .. "\t},\n"


output = output .. "\tfunctions = {\n"
for lib_name, functions in pairs(exported.functions) do
	output = output .. "\t\t" .. lib_name .. " = {\n"
	for name in pairs(functions) do
		output = output .. "\t\t\t" .. name .. " = true,\n"
	end
	output = output .. "\t\t},\n"
end
output = output .. "\t},\n"

output = output .. "}\n"

CompileString(output, "test")

file.Write((SERVER and "sv_" or "cl_") .. "exported.txt", output)