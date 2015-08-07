local surface = ... or _G.surface

local freetype = desire("graphics.ffi.freetype")

if not freetype then return end

local META = {}

META.ClassName = "freetype"

function META:Initialize()

	-- zsnes font loader hack..
	if self.Path:endswith(".txt") then
		return false, "not a valid font"
	end

	if not surface.freetype_lib then
		local lib = ffi.new("FT_Library[1]")
		freetype.InitFreeType(lib)
--		freetype.LibrarySetLcdFilter(lib[0], 1)
		surface.freetype_lib = lib
	end
	
	local function load(path)
		local data = vfs.Read(path)
		
		self.binary_font_data = data

		local face = ffi.new("FT_Face[1]")
		
		if freetype.NewMemoryFace(surface.freetype_lib[0], data, #data, 0, face) == 0 then
			self.face_ref = face
			face = face[0]
			self.face = face
			
			freetype.SetCharSize(face, 0, self.Size * surface.font_dpi, surface.font_dpi, surface.font_dpi)
			
			self.line_height = face.height / surface.font_dpi
			self.max_height = (face.ascender - face.descender) / surface.font_dpi
			
			self:CreateTextureAtlas()
			
			self:OnLoad()
		else
			error("unable to initialize font")
		end
	end
	
	local tbl = vfs.Find("cache/" .. crypto.CRC32(self.Path), nil, true)
	
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
				path = vfs.ParseVariables("%windir%/fonts/" .. translate[font] .. ".ttf")
			else				
				-- http://snook.ca/archives/html_and_css/windows-subs-helvetica-arial
				if font == "helvetica" then
					font = "arial"
				end
				
				font = font:lower()
				
				for k,v in pairs(name_translate) do
					if font:startswith(k) then
						font = font:sub(#k+2)
						break
					end
				end
				
				local parts = font:lower():explode(" ")
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
				
				path = vfs.ParseVariables("%windir%/fonts/" .. name .. ".ttf")
			end
			
			if vfs.IsFile(path) then
				resource.Download(path, load)
				return
			end
		end
	
		sockets.Download("http://fonts.googleapis.com/css?family=" .. self.Path:gsub("%s", "+"), function(data)
			local url = data:match("url%((.-)%)")
			if url then
				local format = data:match("format%('(.-)'%)")
				resource.Download(url, load, nil, crypto.CRC32(self.Path))
			end
		end, function()
			llog("unable to find url for %s from google web fonts", self.Path)
			
			sockets.Download("http://dl.dafont.com/dl/?f=" .. self.Path:lower():gsub(" ", "_"), function(zip_content)
				vfs.Write("data/temp_dafont.zip", zip_content)
				local base = R("data/temp_dafont.zip") -- FIX ME
				for i,v in pairs(vfs.Find(base .. "/")) do
					if v:find(".ttf") then
						local ext = v:match(".+(%.%a+)") or ".dat"
						vfs.Write("downloads/cache/" .. crypto.CRC32(self.Path) .. ext, vfs.Read(base .."/".. v))
					end
				end
			end)		
		end)
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
		
		local copy = ffi.new("unsigned char["..char.w.."]["..char.h.."][4]")
		
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