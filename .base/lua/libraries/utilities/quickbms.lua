local utility = _G.utility or ...

local temp_dir = R"data/" .. "bms_temp/"
local temp_script = R"bin/"..jit.os.."/" .. "temp_script.bms"
local quickbms_location = R("bin/"..jit.os.."/")
local exists = vfs.Find(quickbms_location .. "quickbms")[1] ~= nil

local bms_opened_files = {}

function utility.QuickBMSGetFiles(archive_path, script)
	if not exists then return nil, "quickbms not found in " .. quickbms_location end
	
	vfs.Write(temp_script, script)

	local lfs = require("lfs")
	
	local old_dir = lfs.currentdir()
	lfs.chdir(quickbms_location)
	local list = io.popen(("quickbms -l temp_script.bms %q"):format(archive_path), "r")
	lfs.chdir(old_dir)

	local files = {}

	for offset, size, path in list:read("*all"):gmatch("(%S+)%s+(%S+)%s+(%S+)") do
		--offset = tonumber("0x" .. offset)
		size = tonumber(size)
		table.insert(files, {size = size, path = path})
	end
	
	return files
end

function utility.QuickBMSOpenFile(archive_path, file_path, script)
	if not exists then return nil, "quickbms not found in " .. quickbms_location end

	vfs.Write(temp_script, script)

	lfs.mkdir(temp_dir)
	
	local old_dir = lfs.currentdir()
	lfs.chdir(quickbms_location)
	os.execute(("quickbms -f %q temp_script.bms %q %q"):format(file_path, archive_path, temp_dir))
	lfs.chdir(old_dir)
	
	local file, err = vfs.Open(temp_dir .. file_path)
	
	if not file then return file, err end
	
	bms_opened_files[file_path] = (bms_opened_files[file_path] or 0) + 1
	
	file.OnRemove = function() 
		bms_opened_files[file_path] = bms_opened_files[file_path] - 1
		if bms_opened_files[file_path] == 0 then
			os.remove(temp_dir .. file_path)
			print("removed ", file_path)
			
			local all_gone = true
			for k,v in pairs(bms_opened_files) do
				if v ~= 0 then
					all_gone = false
					break
				end
			end
			
			if all_gone then
				print(os.remove(temp_dir))
				print("removed bms_temp")
			end
		end
	end
	
	
	return file
end
