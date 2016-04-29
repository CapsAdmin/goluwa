local surface = ... or _G.surface

local META = {}

META.ClassName = "angel"

function META:Initialize()
	local TYPE_INFO = 1
	local TYPE_COMMON = 2
	local TYPE_PAGES = 3
	local TYPE_CHARS = 4

	local buffer, err = vfs.Open(self.Path .. "/" .. (self.Path:match(".+/(.+)") or self.Path) .. ".fnt")

	if not buffer then
		return false, err
	end

	local magic = buffer:ReadString(4)
	assert(magic == "BMF\3")

	self.char_data = {}

	repeat
		local type = buffer:ReadByte()
		local size = buffer:ReadInt()

		if type == TYPE_INFO then
			local info = buffer:ReadStructure[[
				short size;
				byte flags;
				byte charSet;
				unsigned short stretchH;
				boolean aa;
				byte paddingUp;
				byte paddingRight;
				byte paddingDown;
				byte paddingLeft;
				byte spacingHoriz;
				byte spacingVert;
				byte outline;
				string fontName;
			]]

			table.merge(self, info)
		elseif type == TYPE_COMMON then
			local info = buffer:ReadStructure[[unsigned short lineHeight;
				unsigned short base;
				unsigned short scaleW;
				unsigned short scaleH;
				unsigned short pages;
				byte flags;
				byte alphaChnl;
				byte redChnl;
				byte greenChnl;
				byte blueChnl;
			]]

			table.merge(self, info)
		elseif type == TYPE_PAGES then
			local count = self.pages

			self.pages = {}
			for i = 1, count do
				local name = buffer:ReadString()
				self.pages[i - 1] = {name = name, chars = {}, png = render.CreateTextureFromPath(self.Path .. "/" .. name)}
			end
		elseif type == TYPE_CHARS then
			for _ = 1, size / 20 do
				local char = buffer:ReadStructure[[
					int id;
					unsigned short x;
					unsigned short y;
					unsigned short width;
					unsigned short height;
					short xoff;
					short yoff;
					short xadvance;
					byte page;
					byte chnl;
				]]

				char.tex = self.pages[char.page].png

				self.pages[char.page].chars[utf8.byte(char.id)] = char
				self.char_data[utf8.byte(char.id)] = char
			end
		else
			buffer:Advance(size)
		end

	until buffer:TheEnd()
end

function META:GetGlyphData(code)
	local info = self.char_data[code]

	if info then
		--local buffer, len = info.tex:Download()
		error("texture:Download needs x y w h region arguments!!!")
	end
end

surface.RegisterFont(META)