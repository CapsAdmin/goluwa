do return end

local header = [[
typedef struct {} FT_Library;
typedef struct {} FT_Face;

int FT_Init_Freetype(FT_Library *);

int FT_New_Face(FT_Library, const char *face_name, FT_Face);
int FT_Load_Char(FT_Library, const char *letter, unsigned int flag);
int FT_Load_Char(FT_Library, const char *letter, unsigned int flag);

]] 

ffi.cdef(header)

local freetype = {}
 
local lib = ffi.load("freetype6.dll") 

for line in header:gmatch("(.-)\n") do
	local name = line:match("FT_(.-)%(") 
	
	print(name)
	
	if name then  
		freetype[name] = lib["FT_" .. name]
	end
end  

table.print(freetype)

return freetype 