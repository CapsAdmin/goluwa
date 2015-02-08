local surface = ... or _G.surface

local freetype = require("lj-freetype")

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
		freetype.LibrarySetLcdFilter(lib[0], 1)
		surface.freetype_lib = lib
	end
	
	local ok, err = resource.Read(self.Path, function(data, err)
		assert(data, err)
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
			
			resource.RemoveResourceFromMemory(self.Path)
			
			self:OnLoad()
		else
			error("unable to initialize font")
		end
	end, self.LoadSpeed, "font")

	return ok, err
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