lovemu = {}

lovemu.version = "0.9.0"
lovemu.demoname = "" --internal, demo folder name
lovemu.delta = 0 --frametime

include("boot.lua")
include("realboot.lua")

local getn=table.getn
local pairs=pairs
local find=string.find
local tostring=tostring
local insert=table.insert
local concat=table.concat
local gsub=string.gsub

function lovemu.NewObject(name, ...)
	local obj = {__lovemu_type = name, ...}
		
	obj.typeOf = function(_, str)
		return str == name
	end
	
	obj.type = function()
		return name
	end
	
	return obj
end

function lovemu.CheckSupported(demo)
	if not lovemu.supported then
		lovemu.supported = {}
		for _,v in pairs(vfs.Search(e.ABSOLUTE_BASE_FOLDER.."addons/lovemu/", ".lua")) do
			for _,l in pairs(string.explode(vfs.Read(v), "\n")) do
				if find(l,"love.") then
					if string.match(l,"(.-)%b()") then
						local isPARTIAL=false
						if find(l,"--partial") then
							isPARTIAL=true
						end
						local x1,x2=find(l,"love.")
						l=l:sub(x2,#l)
						l=string.match(l,"(.-)%b()")
						if l then
							if isPARTIAL==true then
								lovemu.supported[l]=1
							else
								lovemu.supported[l]=2
							end
						end
					end
				end
			end
		end
	end

	local functions_list={}
	for _,v in pairs(vfs.Search("lovers/"..demo.."/",".lua")) do
		for _,l in pairs(string.explode(vfs.Read(v),"\n")) do
			if string.find(l,"love.") then
				if string.match(l,"(.-)%b()") then
					local x1,x2=string.find(l,"love.")
					l=l:sub(x2,#l)
					l=string.match(l,"(.-)%b()")
					if l then
						if l:sub(1,1)=="." then
							functions_list[l]=true
						end
					end
				end
			end
		end
	end
	for k in pairs(functions_list) do
		if not lovemu.supported[k] then
			print("NOT SUPPORTED: love"..k)
		else
			if lovemu.supported[k]==1 then
				print("PARTIAL:       love"..k)
			else
				--print("SUPPORTED:     love"..k)
			end
		end
	end
end

console.AddCommand("lovemu", function(line)
	local params = line:explode(" ")
	local command = params[1]
	local arg = params[2]
	
	if command == "run" then
	
		if arg then
			local str = ""
			
			for i = 2 ,#params do
				str = str .. params[i]
			end
			
			if str == "" then
				logn("Usage: lovemu run <folder name>")
			else
				lovemu.boot(str)
			end
		else
			logn("Usage: lovemu run <folder name>")
		end
		
	elseif command == "runreal" then
	
		if arg then
			local str=""
			for i=2,#params do
				str=str..params[i]
			end
			if str=="" then
				logn("Usage: lovemu runreal <folder name>")
			else
				lovemu.bootreal(str)
			end
		else
			logn("Usage: lovemu runreal <folder name>")
		end
		
	elseif command=="check" then
	
		if arg then
			lovemu.CheckSupported(arg)
		else
			logn("Usage: lovemu check <folder name>")
		end
		
	elseif command=="version" then
	
		if arg then
			lovemu.version = arg
			logn("Changed internal version to " .. arg)
		else
			logn("Usage: lovemu version <version>")
		end
		
	else
	
		logn("Usage:")
		logn("\tlovemu <command> <params>\n\nCommands:\n")
		logn("\tcheck      <folder name>        //check game compatibility with lovemu")
		logn("\trun        <folder name>        //runs a game  ")
		logn("\trunreal    <folder name>        //runs a game on real love2d ")
		logn("\tversion    <version>            //change internal love version, default: 0.9.0")
		
	end
end)
