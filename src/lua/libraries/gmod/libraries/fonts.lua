do
	local easy = {
		["roboto bk"] = "resource/fonts/Roboto-Black.ttf",
		["roboto"] = "resource/fonts/Roboto-Regular.ttf",
		["helvetica"] = "resource/fonts/coolvetica.ttf",
		["times new roman"] = "resource/fonts/coolvetica.ttf",
		["courier new"] = "resource/fonts/coolvetica.ttf",
		["courier"] = "resource/fonts/coolvetica.ttf",
		["arial"] = "resource/fonts/coolvetica.ttf",
		["arial black"] = "resource/fonts/coolvetica.ttf",
		["verdana"] = "resource/fonts/coolvetica.ttf",
		["trebuchet ms"] = "resource/fonts/coolvetica.ttf",
	}

	function gine.TranslateFontName(name)
		if not name then
			return easy.helvetica
		end
		local name = name:lower()

		if easy[name] then
			return easy[name]
		end

		if vfs.IsFile("resource/" .. name .. ".ttf") then
			return "resource/" .. name .. ".ttf"
		end

		if vfs.IsFile("resource/fonts/" .. name .. ".ttf") then
			return "resource/fonts/" .. name .. ".ttf"
		end

		return easy.helvetica
	end
end

function gine.LoadFonts()
	local screen_res = window.GetSize()

	local fonts = {}
	--table.merge(fonts, steam.VDFToTable(vfs.Read("resource/SourceScheme.res"), true).scheme.fonts)
	--table.merge(fonts, steam.VDFToTable(vfs.Read("resource/ChatScheme.res"), true).scheme.fonts)
	table.merge(fonts, steam.VDFToTable(vfs.Read("resource/ClientScheme.res"), true).scheme.fonts)

	for font_name, sub_fonts in pairs(fonts) do
		local candidates = {}

		for i, info in pairs(sub_fonts) do
			if info.yres then
				local x,y = unpack(info.yres:split(" "))
				table.insert(candidates, {info = info, dist = Vec2(tonumber(x), tonumber(y)):Distance(screen_res)})
			end
		end

		table.sort(candidates, function(a, b) return a.dist < b.dist end)
		local info = (candidates[1] and candidates[1].info) or select(2, next(sub_fonts))

		if info then
			if type(info.tall) == "table" then
				info.tall = info.tall[1]-- what
			end

			gine.render2d_fonts[font_name:lower()] = fonts.CreateFont({
				path = gine.TranslateFontName(info.name),
				size = info.tall and math.ceil(info.tall) or 11,
			})
		end
	end
end

do
	gine.translation = {}
	gine.translation2 = {}

	function gine.env.language.GetPhrase(key)
		return gine.translation[key] or key
	end

	function gine.env.language.Add(key, val)
		gine.translation[key] = val:trim()
		gine.translation2["#" .. key] = gine.translation[key]
	end
end

do
	local render2d = gine.env.render2d
	local lib = _G.fonts

	function render2d.SetTextPos(x, y)
		gfx.SetTextPosition(x, y)
	end

	gine.render2d_fonts = gine.render2d_fonts or {}

	function render2d.CreateFont(id, tbl)
		local tbl = table.copy(tbl)
		tbl.path = tbl.font

		tbl.path = gine.TranslateFontName(tbl.path)

		if tbl.size then tbl.size = math.ceil(tbl.size * 0.55) end

		gine.render2d_fonts[id:lower()] = fonts.CreateFont(tbl)
	end

	function gfx.SetFont(name)
		gfx.SetFont(gine.render2d_fonts[name:lower()])
	end

	function render2d.GetTextSize(str)
		str = gine.translation2[str] or str
		return gfx.GetTextSize(str)
	end

	local txt_r, txt_g, txt_b, txt_a = 0,0,0,0

	function render2d.SetTextColor(r,g,b,a)
		if type(r) == "table" then
			r,g,b,a = r.r, r.g, r.b, r.a
		end
		txt_r = r/255
		txt_g = g/255
		txt_b = b/255
		txt_a = (a or 0) / 255
	end

	function render2d.DrawText(str)
		str = gine.translation2[str] or str
		lib.PushColor(txt_r, txt_g, txt_b, txt_a)
		gfx.DrawText(str)
		lib.PopColor()

		local x, y = gfx.GetTextPosition()
		local w, h = gfx.GetTextSize(str)
		gfx.SetTextPosition(x + w, y)
	end
end
