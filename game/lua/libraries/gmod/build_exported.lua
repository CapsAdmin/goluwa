// copy this script to gmod
// lua_openscript_cl build_exported.lua
// lua_openscript build_exported.lua
// copy data/cl_exported.lua to this script's directory
// copy data/sv_exported.lua to this script's directory

local exported = {}
exported.functions = {}
exported.globals = {}
exported.meta = {}
exported.enums = {}

-- enums
for key, val in pairs(_G) do
	if isnumber(val) or isbool(val) then
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
	[FindMetaTable("Player").ConCommand] = true,
}

local blacklist = {}

if CLIENT then
	whitelist[vgui.Create] = true
	whitelist[FindMetaTable("Panel").SetFGColor] = true
	whitelist[FindMetaTable("Panel").SetBGColor] = true

	blacklist[vgui.CreateX] = true
	blacklist[FindMetaTable("Panel").SetFGColorEx] = true
	blacklist[FindMetaTable("Panel").SetBGColorEx] = true
end

local function get_func_type(func)
	if blacklist[func] then return end

	if whitelist[func] or debug.getinfo(func).source == "=[C]" then
		return "C"
	end

	return "L"
end

local blacklist = {
	_M = true,
	_NAME = true,
	_PACKAGE = true,
	SpawniconGenFunctions = true,
}

-- functions
for key, val in pairs(_G) do
	if key == "_G" then continue end
	if isfunction(val) then
		exported.globals[key] = get_func_type(val)
	elseif istable(val) and not blacklist[key] then
		for func_name, func in pairs(val) do
			if not blacklist[func_name] then
				if isfunction(func) then
					local func_type = get_func_type(func)
					if func then
						exported.functions[key] = exported.functions[key] or {}
						exported.functions[key][func_name] = func_type
					end
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
				if isfunction(func) then
					local func_type = get_func_type(func)
					if func then
						exported.meta[val.MetaName][func_name] = func_type
					end
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
	if isnumber(v) or isbool(v) then
		output = output .. "\t\t" .. k .. " = " .. tostring(v) .. ",\n"
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
	for name, type in pairs(functions) do
		output = output .. "\t\t\t" .. name .. " = \"" .. type .. "\",\n"
	end
	output = output .. "\t\t},\n"
end
output = output .. "\t},\n"


output = output .. "\tfunctions = {\n"
for lib_name, functions in pairs(exported.functions) do
	output = output .. "\t\t" .. lib_name .. " = {\n"
	for name, type in pairs(functions) do
		output = output .. "\t\t\t" .. name .. " = \"" .. type .. "\",\n"
	end
	output = output .. "\t\t},\n"
end
output = output .. "\t},\n"

output = output .. "\tglobals = {\n"
for name, type in pairs(exported.globals) do
	output = output .. "\t\t\t" .. name .. " = \"" .. type .. "\",\n"
end
output = output .. "\t},\n"

output = output .. "}\n"

CompileString(output, "test")

file.Write((SERVER and "sv_" or "cl_") .. "exported.txt", output)