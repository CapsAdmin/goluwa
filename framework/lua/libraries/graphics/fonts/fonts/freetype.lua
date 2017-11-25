local ffi = require("ffi")
local fonts = ... or _G.fonts

local freetype = desire("freetype")

if not freetype then return end


local supported = {
	ttf = true,
	ttc = true,
	cff = true,
	woff = true,
	otf = true,
	cff = true,
	otc = true,
	pfa = true,
	pfb = true,
	cid = true,
	sfnt = true,
	pcf = true,
	fnt = true,
	bdf = true,
	pfr = true,
}

local function try_find(files, name)
	table.sort(files, function(a, b) return #a < #b end) -- choose shortest name

	local family, rest = name:match("(.-) (.+)")

	local tries = {}

	if not family then
		table.insert(tries, name .. "[%s%p]" .. "regular")
		table.insert(tries, name .. "[%s%p]" .. "medium")
	end

	table.insert(tries, name)
	table.insert(tries, (name:gsub("[%s%p]+", "")))

	for _, try in ipairs(tries) do
		for _, full_path in ipairs(files) do
			local ext = full_path:match(".+%.(%a+)") or "dat"
			if supported[ext] then
				local name = full_path:match(".+/(.+)%.")
				if name:lower():find(try) then
					llog("%s: %s", name, full_path)
					return full_path
				end
			end
		end
	end
end

local function google(path)
	local family, rest = path:match("(.-) (.+)")

	if family then
		return family .. "/" .. family:upperchar(1) .. "-" .. rest:upperchar(1) .. ".ttf"
	end

	return path .. "/" .. path:upperchar(1) .. ".ttf"
end

local function translate_windows_font(font_name)
	-- TODO: EnumFontFamiliesEx

	local name_translate = {
		["lucidaconsole"] = "lucon",
		["trebuchetms"] = "trebuc",
		["couriernew"] = "cour",
	}

	local font = font_name:lower()

	-- http://snook.ca/archives/html_and_css/windows-subs-helvetica-arial
	if font == "helvetica" then
		font = "arial"
	end

	font = font:lower()

	local parts = font:lower():split(" ")
	local name = parts[1]

	for i = 2, #parts do
		local flag = parts[i]

		if flag == "bold" then
			flag = "b"
		elseif flag == "semibold" then
			flag = "sb"
		elseif flag == "semibold" then

		end

		name = name .. flag
	end

	for k,v in pairs(name_translate) do
		name = name:gsub(k, v)
	end

	return name .. ".ttf"
end

local providers = {
	{
		url = "https://github.com/google/fonts/raw/master/apache/", -- roboto/Roboto-Bolditallic.ttf
		translate = google,
	},
	{
		url = "https://github.com/google/fonts/raw/master/ofl/", -- roboto/Roboto-Bolditallic.ttf
		translate = google,
	},
	{
		url = "https://github.com/caarlos0/msfonts/raw/master/fonts/",
		translate = translate_windows_font,
	},
	{
		url = "http://dl.dafont.com/dl/?f=", -- roboto | Roboto-BoldItalic.ttf
		translate = function(path)
			path = path:gsub(" ", "_")

			return path
		end,
		archive = function(archive_path, path)
			return try_find(vfs.Find(archive_path, true), path)
		end,
	},
	{
		url = "http://dl.1001fonts.com/", -- roboto.zip | Roboto-BoldItalic.ttf
		translate = function(path)
			path = path:gsub(" ", "-")

			return path .. ".zip"
		end,
		archive = function(archive_path, name)
			for ext in pairs(supported) do
				local full_path = try_find(vfs.Find(archive_path .. ext .. "/", true), name)

				if full_path then
					return full_path
				end
			end

			local full_path = try_find(vfs.Find(archive_path, true), name)

			if full_path then
				return full_path
			end

			for k,v in ipairs(vfs.Find(archive_path, true)) do
				print(v)
			end

			for ext in pairs(supported) do
				for k,v in ipairs(vfs.Find(archive_path .. ext .. "/", true)) do
					print(v)
				end
			end

			llog("couldn't find anything usable in the zip archive for: ", name)
		end,
	}
}

local function find_font(name, callback, on_error)

	local real_name = name

	name = name:lower()
	name = name:gsub("%s+", " ")
	name = name:gsub("%p", "")

	local urls = {}
	local lookup = {}

	for i, info in ipairs(providers) do
		local url = info.url .. info.translate(name)
		table.insert(urls, url)
		lookup[url] = info
	end

	sockets.DownloadFirstFound(
		urls,
		function(url, content)
			llog("%s downloading url: %s", name, url)

			local info = lookup[url]
			local ext
			local full_path

			if info.archive then
				vfs.Write("data/temp.zip", content)
				full_path = info.archive(R("data/temp.zip") .. "/", name)
				if full_path then
					content = vfs.Read(full_path)
					ext = full_path:match(".+(%.%a+)")
				else
					resource.Download(fonts.default_font_path, callback)
					return
				end
			end

			if content then
				ext = ext or url:match(".+(%.%a+)") or ".dat"
				local path = "cache/" .. crypto.CRC32(real_name) .. ext

				llog("%s cache: %s", name, path)
				vfs.Write(path, content)

				callback(path)
			else
				llog("%s is empty", full_path)
				resource.Download(fonts.default_font_path, callback)
			end
		end,
		on_error
	)
end

local META = prototype.CreateTemplate("freetype")

function META:Initialize()

	-- zsnes font loader hack..
	if self.Path:endswith(".txt") then
		return false, "not a valid font"
	end

	if not fonts.freetype_lib then
		local lib = ffi.new("struct FT_LibraryRec_ * [1]")
		freetype.InitFreeType(lib)
--		freetype.LibrarySetLcdFilter(lib[0], 1)
		fonts.freetype_lib = lib
	end

	local function load(path)
		local data = vfs.Read(path)

		local char_buffer = ffi.C.malloc(#data)
		self.char_buffer = char_buffer
		ffi.copy(char_buffer, data, #data)

		local face = ffi.new("struct FT_FaceRec_ * [1]")
		local code = freetype.NewMemoryFace(fonts.freetype_lib[0], char_buffer, #data, 0, face)

		if code == 0 then
			self.face_ref = face
			face = face[0]
			self.face = face

			freetype.SetCharSize(face, 0, self.Size * fonts.font_dpi, fonts.font_dpi, fonts.font_dpi)

			self.line_height = face.height / fonts.font_dpi
			self.max_height = (face.ascender - face.descender) / fonts.font_dpi

			self:CreateTextureAtlas()

			self:OnLoad()
		else
			wlog("unable to initialize font ("..path.."): " .. (freetype.ErrorCodeToString(code) or code))
			--load(fonts.default_font_path)
			resource.Download(fonts.default_font_path, load)
		end
	end

	local tbl = vfs.Find("cache/" .. crypto.CRC32(self.Path), true)

	if tbl[1] then
		load(tbl[1])
		return
	end

	resource.Download(self.Path, load, function(reason)
		if WINDOWS then
			local path = vfs.ParsePathVariables("%windir%/fonts/" .. translate_windows_font(self.Path))

			if vfs.IsFile(path) then
				resource.Download(path, load)
				return
			end
		end

		if SOCKETS then
			if self.Path:find("/", nil, true) then
				logn("unable to download ", self.Path)
				llog("loading default font instead")
				resource.Download(fonts.default_font_path, load)
			else
				find_font(self.Path, load, function(reason)
					logn("unable to download ", self.Path)
					logn(reason)
					llog("loading default font instead")
					resource.Download(fonts.default_font_path, load)
				end)
			end
		end
	end)
end

local flags = {
	default = 0x0,
	no_scale = bit.lshift(1, 0),
	no_hinting = bit.lshift(1, 1),
	render = bit.lshift(1, 2),
	no_bitmap = bit.lshift(1, 3),
	vertical_layout = bit.lshift(1, 4),
	force_autohint = bit.lshift(1, 5),
	crop_bitmap = bit.lshift(1, 6),
	pedantic = bit.lshift(1, 7),
	ignore_global_advance_width = bit.lshift(1, 9),
	no_recurse = bit.lshift(1, 10),
	ignore_transform = bit.lshift(1, 11),
	monochrome = bit.lshift(1, 12),
	linear_design = bit.lshift(1, 13),
	no_autohint = bit.lshift(1, 15),
	color = bit.lshift(1, 20),
}

function META:GetGlyphData(code)
	if not self.Ready then return end -- ????????
	if freetype.LoadChar(self.face, utf8.byte(code), bit.bor(flags.color, flags.force_autohint)) == 0 then
		freetype.RenderGlyph(self.face.glyph, 1)

		local glyph = self.face.glyph
		local bitmap = glyph.bitmap

		if bitmap.width == 0 and bitmap.rows == 0 and utf8.byte(code) > 128 then
			return
		end

		local char = {
			char = code,
			w = tonumber(bitmap.width),
			h = tonumber(bitmap.rows),

 			x_advance = tonumber(glyph.advance.x) / fonts.font_dpi,
			y_advance = tonumber(glyph.advance.y) / fonts.font_dpi,
			bitmap_left = tonumber(glyph.bitmap_left),
			bitmap_top = tonumber(glyph.bitmap_top)+1,
		}

		local copy = ffi.typeof("unsigned char[$][$][$]", char.w, char.h, 4)()

		local i = 0
		for x = 0, char.w - 1 do
			for y = 0, char.h - 1 do
				copy[x][y][0] = 255
				copy[x][y][1] = 255
				copy[x][y][2] = 255
				copy[x][y][3] = bitmap.buffer[i+0]
				i = i + 1
			end
		end

		return copy, char
	end
end

function META:OnRemove()
	freetype.DoneFace(self.face)
end

fonts.RegisterFont(META)
