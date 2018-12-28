local last_report = 0
local last_downloaded = 0

event.AddListener("DownloadChunkReceived", "downprog", function(url, data, current_length, header)
	if not header["content-length"] then return end

	if current_length == header["content-length"] then return end

	if last_report < system.GetElapsedTime() then
		system.SetConsoleTitle(
			url ..
			" progress: " .. math.round((current_length / header["content-length"]) * 100, 3) .. "%" ..
			" speed: " .. utility.FormatFileSize(current_length - last_downloaded),
			url
		)
		last_downloaded = current_length
		last_report = system.GetElapsedTime() + 4
	end
end)

event.AddListener("DownloadStop", "downprog", function(url, data, msg)
	system.SetConsoleTitle(nil, url)
end)