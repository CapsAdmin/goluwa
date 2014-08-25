do return end
local ft = require'lj-freetype'
local meta = {}
meta.__index=meta
function meta:InitFont()
	
end
freetype = {}
function freetype.load( path, cb )
	if not vfs.ReadAsync(path, function(data)
		ft.fonts[name].loading = false
		
		local face = ffi.new("FT_Face[1]")
		if freetype.NewMemoryFace(ft.ptr, data, #data, 0, face) == 0 then
			face = face[0]	
	
			 -- not doing this will make freetype crash because the data gets garbage collected
			ft.fonts[name].face = face
			ft.fonts[name].font_data = data
			
		else
			error()
		end
	end, info.read_speed, "font") then
		error("could not load font " .. path .. " : could not find anything with the path field", 2)
	end
end