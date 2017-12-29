local margin = 8
local padding = 1

function download_progress(url)

	local pnl = gui.CreatePanel("base", nil, "lol")
	pnl:SetSize(Vec2(500, 80))
	pnl:SetMargin(Rect() + margin)
	pnl:SetStyle("frame")

	local title = pnl:CreatePanel("text")
	title:SetText(url)
	title:SetupLayout("top")
	title:SetPadding(Rect() + padding)

	local progress = pnl:CreatePanel("progress_bar")
	progress:SetHeight(15)
	progress:SetupLayout("top", "fill_x")

	progress:SetFraction(0.5)

	local timeleft = pnl:CreatePanel("text")
	timeleft:SetText("Estimated time left: 1 sec (0.99 MB of 1.11 MB copied)")
	timeleft:SetupLayout("top")
	timeleft:SetPadding(Rect() + padding)

	local rate = pnl:CreatePanel("text")
	rate:SetText("Transfer rate: 471 KB/Sec")
	rate:SetupLayout("top")
	rate:SetPadding(Rect() + padding)

	pnl:SizeToChildrenHeight()
end

download_progress("https://github.com/CapsAdmin/goluwa/releases/download/linux-binaries/x64.tar.gz")