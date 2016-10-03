local ffi = require("ffi")
local surface = ... or _G.surface

local freetype = desire("libfreetype")

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

local function try_find(files, path)
	table.sort(files, function(a, b) return #a < #b end) -- choose shortest name

	local family, rest = path:match("(.-) (.+)")

	local tries = {}

	if not family then
		table.insert(tries, path .. "[%s%p]" .. "regular")
		table.insert(tries, path .. "[%s%p]" .. "medium")
	end

	table.insert(tries, path)
	table.insert(tries, (path:gsub("[%s%p]+", "")))

	for _, try in ipairs(tries) do
		for _, full_path in ipairs(files) do
			local ext = full_path:match(".+%.(%a+)") or "dat"
			if supported[ext] then
				local name = full_path:match(".+/(.+)%.")
				if name:lower():find(try) then
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
		archive = function(archive_path, path)
			local cache_path
			local content

			for ext in pairs(supported) do
				local full_path = try_find(vfs.Find(archive_path .. ext .. "/", true), path)
				if full_path then
					cache_path = "downloads/cache/" .. crypto.CRC32(path) .. "." .. ext
					content = vfs.Read(full_path)
					break
				end
			end

			if not cache_path then
				local full_path = try_find(vfs.Find(archive_path, true), path)
				if full_path then
					local ext = full_path:match(".+%.(%a+)") or "dat"
					cache_path = "downloads/cache/" .. crypto.CRC32(path) .. "." .. ext
					content = vfs.Read(full_path)
				end
			end

			if not cache_path then
				for k,v in ipairs(vfs.Find(archive_path, true)) do
					print(v)
				end
				for ext in pairs(supported) do
					for k,v in ipairs(vfs.Find(archive_path .. ext .. "/", true)) do
						print(v)
					end
				end
				llog("couldn't find anything usable in the zip archive for: ", path)

				return surface.default_font_path
			end

			vfs.Write(cache_path, content)

			return cache_path
		end,
	}
}

local function find_font(path, callback, on_error)

	path = path:lower()
	path = path:gsub("%s+", " ")
	path = path:gsub("%p", "")

	local urls = {}
	local lookup = {}

	for i, info in ipairs(providers) do
		local url = info.url ..
		info.translate(path)
		table.insert(urls, url)
		lookup[url] = info
	end

	sockets.DownloadFirstFound(
		urls,
		function(url, content)
			local info = lookup[url]
			if info.archive then
				vfs.Write("data/temp.zip", content)
				callback(info.archive(R("data/temp.zip") .. "/", path))
			else
				local ext = url:match(".+(%.%a+)") or ".dat"
				local path = "cache/" .. (crc or crypto.CRC32(path)) .. ext
				vfs.Write(path, content)
				callback(path)
			end
		end,
		on_error
	)
end

local META = {}

META.ClassName = "freetype"

function META:Initialize()

	-- zsnes font loader hack..
	if self.Path:endswith(".txt") then
		return false, "not a valid font"
	end

	if not surface.freetype_lib then
		local lib = ffi.new("struct FT_LibraryRec_ * [1]")
		freetype.InitFreeType(lib)
--		freetype.LibrarySetLcdFilter(lib[0], 1)
		surface.freetype_lib = lib
	end

	local function load(path)
		local data = vfs.Read(path)

		local char_buffer = ffi.C.malloc(#data)
		self.char_buffer = char_buffer
		ffi.copy(char_buffer, data, #data)


		local face = ffi.new("struct FT_FaceRec_ * [1]")
		local code = freetype.NewMemoryFace(surface.freetype_lib[0], char_buffer, #data, 0, face)

		if code == 0 then
			self.face_ref = face
			face = face[0]
			self.face = face

			freetype.SetCharSize(face, 0, self.Size * surface.font_dpi, surface.font_dpi, surface.font_dpi)

			self.line_height = face.height / surface.font_dpi
			self.max_height = (face.ascender - face.descender) / surface.font_dpi

			self:CreateTextureAtlas()

			self:OnLoad()
		else
			warning("unable to initialize font ("..path.."): " .. (freetype.ErrorCodeToString(code) or code))
			load(surface.default_font_path)
		end
	end

	local tbl = vfs.Find("cache/" .. crypto.CRC32(self.Path), true)

	if tbl[1] then
		load(tbl[1])
		return
	end

	resource.Download(self.Path, load, function(reason)

		if WINDOWS then
			-- TODO: EnumFontFamiliesEx

			local flags = {
				bold = "b",
				semibold = "sb",
				semilight = "sl",
				regular = "",
				light = "l",
				italic = "i",
				black = "bl",
			}

			local translate = {
				["arial black"] = "ariblk",
				["arial bold"] = "arialbd",
			}

			local name_translate = {
				["lucida console"] = "lucon",
				["trebuchet ms"] = "trebuc",
				["courier new"] = "cour",
			}

			local path
			local font = self.Path:lower()

			if translate[font] then
				path = vfs.ParsePathVariables("%windir%/fonts/" .. translate[font] .. ".ttf")
			else
				-- http://snook.ca/archives/html_and_css/windows-subs-helvetica-arial
				if font == "helvetica" then
					font = "arial"
				end

				font = font:lower()

				for k in pairs(name_translate) do
					if font:startswith(k) then
						font = font:sub(#k+2)
						break
					end
				end

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

				path = vfs.ParsePathVariables("%windir%/fonts/" .. name .. ".ttf")
			end

			if vfs.IsFile(path) then
				resource.Download(path, load)
				return
			end
		end


		if SOCKETS then
			find_font(self.Path, load, function(reason)
				logn("unable to download ", self.Path)
				logn(reason)
				llog("loading default font instead")
				load(surface.default_font_path)
			end)
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
			x_advance = math.round(tonumber(glyph.advance.x) / surface.font_dpi),
			y_advance = math.round(tonumber(glyph.advance.y) / surface.font_dpi),
			bitmap_left = tonumber(glyph.bitmap_left),
			bitmap_top = tonumber(glyph.bitmap_top)
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

surface.RegisterFont(META)