local utility = _G.utility or ...
local bms_opened_files = {}
local last_written

function utility.QuickBMSGetFiles(archive_path, script)
	local quickbms_location = R("bin/")
	local exists = vfs.Find(quickbms_location .. "quickbms")[1] ~= nil

	if not exists then return nil, "quickbms not found in " .. quickbms_location end

	local temp_script = R("bin/temp_script.bms")

	if last_written ~= script then
		vfs.Write(temp_script, script)
		last_written = script
	end

	fs.PushWorkingDirectory(quickbms_location)
	local list = io.popen(("quickbms -R -l temp_script.bms %q"):format(archive_path), "r")
	fs.PopWorkingDirectory()
	local files = {}

	for size, path in list:read("*all"):gmatch("%S+%s+(%S+)%s+(%S+)") do
		--offset = tonumber("0x" .. offset)
		size = tonumber(size)
		table.insert(files, {size = size, path = path})
	end

	return files
end

function utility.QuickBMSOpenFile(archive_path, file_path, script)
	local quickbms_location = R("bin/")
	local exists = vfs.Find(quickbms_location .. "quickbms")[1] ~= nil

	if not exists then return nil, "quickbms not found in " .. quickbms_location end

	local temp_dir = R("data/") .. "bms/"
	local temp_script = R("bin/temp_script.bms")

	if last_written ~= script then
		vfs.Write(temp_script, script)
		last_written = script
	end

	vfs.CreateDirectory("os:" .. temp_dir)
	fs.PushWorkingDirectory(quickbms_location)
	os.execute(
		(
			"quickbms -R -f %q temp_script.bms %q %q"
		):format(file_path, archive_path, temp_dir)
	)
	fs.PopWorkingDirectory()
	local file, err = vfs.Open(temp_dir .. file_path)

	if not file then return file, err end

	bms_opened_files[file_path] = (bms_opened_files[file_path] or 0) + 1
	file.OnRemove = function()
		bms_opened_files[file_path] = bms_opened_files[file_path] - 1

		if bms_opened_files[file_path] == 0 then
			os.remove(temp_dir .. file_path)
		-- this requires permissions and stuff
		--[[local all_gone = true
			for k,v in pairs(bms_opened_files) do
				if v ~= 0 then
					all_gone = false
					break
				end
			end

			if all_gone then
				os.execute("rmdir " .. temp_dir)
			end]] end
	end
	return file
end