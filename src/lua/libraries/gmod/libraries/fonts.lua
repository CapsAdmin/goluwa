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

	function gmod.TranslateFontName(name)
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

function gmod.LoadFonts()
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

			gmod.surface_fonts[font_name:lower()] = surface.CreateFont({
				path = gmod.TranslateFontName(info.name),
				size = info.tall and math.ceil(info.tall) or 11,
			})
		end
	end
end

do
	gmod.translation = {}
	gmod.translation2 = {}

	function gmod.env.language.GetPhrase(key)
		return gmod.translation[key] or key
	end

	function gmod.env.language.Add(key, val)
		gmod.translation[key] = val:trim()
		gmod.translation2["#" .. key] = gmod.translation[key]
	end
end

do
	local surface = gmod.env.surface
	local lib = _G.surface

	function surface.SetTextPos(x, y)
		lib.SetTextPosition(x, y)
	end

	gmod.surface_fonts = gmod.surface_fonts or {}

	function surface.CreateFont(id, tbl)
		local tbl = table.copy(tbl)
		tbl.path = tbl.font

		tbl.path = gmod.TranslateFontName(tbl.path)

		if tbl.size then tbl.size = math.ceil(tbl.size * 0.55) end

		gmod.surface_fonts[id:lower()] = lib.CreateFont(tbl)
	end

	function surface.SetFont(name)
		lib.SetFont(gmod.surface_fonts[name:lower()])
	end

	function surface.GetTextSize(str)
		str = gmod.translation2[str] or str
		return lib.GetTextSize(str)
	end

	function surface.DrawText(str)
		str = gmod.translation2[str] or str
		lib.PushColor(txt_r, txt_g, txt_b, txt_a)
		lib.DrawText(str)
		lib.PopColor()

		local x, y = lib.GetTextPosition()
		local w, h = surface.GetTextSize(str)
		lib.SetTextPosition(x + w, y)
	end
end