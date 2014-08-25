local surface = _G.surface or ...

local META = {}

META.Name = "angelfont"

function META.LoadFont(name, options, callback)
	local self = META:New({
		buffer = Buffer(assert(vfs.GetFile(options.path .. "/" .. (options.path:match(".+/(.+)") or options.path) .. ".fnt", "rb"))), 
		dir = options.path .. "/", 
		chars = {},
		options = options,
	})
	
	self:ReadBlocks()
	
	self.state = "loaded"
	
	callback(self)
	
	return self
end

function META:ReadHeader()
	local magic = self.buffer:ReadString(4)
	assert(magic == "BMF\3")
end

function META:ReadInfo()
	local info = self.buffer:ReadStructure[[
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
end

function META:ReadCommon()
	local info = self.buffer:ReadStructure[[unsigned short lineHeight;
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
end

function META:ReadPages()
	local count = self.pages
	
	self.pages = {}
	for i = 1, count do
		local name = self.buffer:ReadString()		
		self.pages[i - 1] = {name = name, chars = {}, png = Texture(self.dir .. name)}		
	end
end

function META:ReadChars(n)
	for i = 1, n do
		local char = self.buffer:ReadStructure[[
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
		
		self.pages[char.page].chars[char.id] = char
		self.chars[char.id] = char
	end
end

local TYPE_INFO = 1
local TYPE_COMMON = 2
local TYPE_PAGES = 3
local TYPE_CHARS = 4

function META:ReadBlock()
	local type = self.buffer:ReadByte()
	local size = self.buffer:ReadInt()
	
	if type == TYPE_INFO then
		self:ReadInfo()		
	elseif type == TYPE_COMMON then
		self:ReadCommon()
	elseif type == TYPE_PAGES then
		self:ReadPages()
	elseif type == TYPE_CHARS then
		self:ReadChars(size/20)
	else
		self.buffer:Advance(size)
	end
	
	return self.buffer:TheEnd()
end

function META:ReadBlocks()
	self:ReadHeader()
	while not self:ReadBlock() do end
end

function META:DrawString(str, X, Y)
	local curX, curY = X, Y
	
	for i, char in ipairs(utf8.totable(str)) do
		if char == "\n" then
			curX = X
			curY = curY + self.lineHeight
		else
			local ch = self.chars[utf8.byte(char)] or self.chars[63]
			if ch then
				surface.SetTexture(ch.tex)
				local perc = ch.x / ch.tex.w
				local w, h = ch.width, ch.height
				
				surface.SetRectUV(ch.x, ch.y, w, h, ch.tex.w, ch.tex.h)
				surface.DrawRect(curX + ch.xoff, curY + ch.yoff, w, h)
				curX = curX + ch.xadvance
			end
		end
	end
	
	return curX, curY
end

function META:GetTextSize(str)
	local curX, curY = 0, 0
	local lastTex
	
	for i, char in ipairs(utf8.totable(str)) do
		if char == '\n' then
			curX = X
			curY = curY + self.lineHeight
		else
			local ch = self.chars[utf8.byte(char)] or self.chars[63]
			if ch then
				curX = curX + ch.xadvance
			end
		end
	end
	return curX, curY
end

surface.RegisterFontLoader(META)