local margin = 4
local padding = 1

local downprog = {}

downprog.downloads = {}

function downprog.Start(url)
	local pnl = gui.CreatePanel("base")
	pnl:SetSize(Vec2(300, 80))
	pnl:SetMargin(Rect() + margin)
	pnl:SetStyle("frame")
	pnl:SetupLayout("right", "bottom")
	pnl:SetCollisionGroup("download_progress")

	local title = pnl:CreatePanel("text")
	title:SetText(url:match(".+/(.+)"))
	title:SetupLayout("top")
	title:SetPadding(Rect() + padding)

	local timeleft = pnl:CreatePanel("text")
	timeleft:SetupLayout("left", "right", "top")
	timeleft:SetPadding(Rect() + padding)

	local progress = pnl:CreatePanel("progress_bar")
	progress:SetHeight(15)
	progress:SetupLayout("top", "fill_x")

	progress:SetFraction(0)

	local details = pnl:CreatePanel("text")
	details:SetText("???")
	details:SetupLayout("top")
	details:SetPadding(Rect() + padding)

	pnl:SizeToChildrenHeight()

	downprog.downloads[url] = {
		pnl = pnl,
		details = details,
		max_size = -1,
		bytes_received = 0,
		last_received = system.GetTime(),
		progress = progress,
		timeleft = timeleft,

		time = 0,
		average_bytes = 0,
		total_average = 0,
		total_average_i = 0,
	}
end

function downprog.MaxBytes(url, max_size)
	local data = downprog.downloads[url]
	if data then
		data.max_size = max_size
	end
end

function downprog.BytesReceived(url, bytes)
	local data = downprog.downloads[url]

	if not data then return end

	data.bytes_received = data.bytes_received + bytes

	local current = utility.FormatFileSize(data.bytes_received)

	local max = "???"
	if data.max_size ~= -1 then
		max = utility.FormatFileSize(data.max_size)
	end

	data.details:SetText(("%s / %s - %s"):format(current, max, data.rate_str or "???"))

	local f = data.max_size == -1 and 0 or data.bytes_received / data.max_size

	data.progress:SetFraction(math.min(f, 1))

	local time = system.GetTime() - data.last_received

	data.average_bytes = data.average_bytes + bytes
	data.time = data.time + time

	if data.time >= 1 then
		local bytes = data.average_bytes
		data.rate_str = ("%s/Sec"):format(utility.FormatFileSize(bytes))
		data.average_bytes = 0

		local total_time = data.max_size / bytes
		local time = total_time * f

		data.timeleft:SetText(os.prettydate(math.max(total_time - time, 0), true))
		data.pnl:Layout()

		data.time = 0

		data.total_average = data.total_average + bytes
		data.total_average_i = data.total_average_i + 1
	end

	data.last_received = system.GetTime()
end

function downprog.Stop(url)
	local data = downprog.downloads[url]

	if not data then return end

	local current = utility.FormatFileSize(data.bytes_received)

	local max = "???"
	if data.max_size ~= -1 then
		max = utility.FormatFileSize(data.max_size)
	end

	data.timeleft:SetText("finished")
	data.details:SetText(("%s / %s - %s"):format(current, max, utility.FormatFileSize(data.total_average / data.total_average_i)))
	data.progress:SetFraction(1)


	event.Delay(1, function()
		data.pnl:Remove()
	end)

	downprog.downloads[url] = nil
end

event.AddListener("DownloadStart", "downprog", function(url)
	-- this can be problematic to call the same frame because of gui
	event.Delay(0, function() downprog.Start(url) end)
end)

event.AddListener("DownloadHeaderReceived", "downprog", function(url, header)
	if header["content-length"] then
		downprog.MaxBytes(url, header["content-length"])
	end
end)

event.AddListener("DownloadChunkReceived", "downprog", function(url, data)
	downprog.BytesReceived(url, #data)
end)

event.AddListener("DownloadStop", "downprog", function(url, data)
	downprog.Stop(url)
end)

if RELOAD then
	local url = "https://www.download.com/" .. string.random() .. ".zip"
	local total = math.random(1000000, 3000000)
	local speed = math.random(20000, 50000)
	local current = 0

	downprog.Start(url, 50)
	downprog.MaxBytes(url, total)

	event.Timer(url, 0.1, 0, function()
		local bytes = (math.random()^0.25) * speed
		downprog.BytesReceived(url, bytes)
		current = current + bytes

		if current >= total then
			downprog.Stop(url)
			event.RemoveTimer(url)
		end
	end)
end

return downprog