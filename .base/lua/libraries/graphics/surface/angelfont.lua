--[[
font:GetHeight()
font:GetWidth(str)
font:DrawString( str, x, y )
]]
include( "libraries/network/packet.lua" )
local surface = _G.surface or ...
local meta = {}
meta.__index = meta
function meta:ReadHeader()
	local magic = self.buffer:ReadString(4)
	if magic ~= 'BMF\3' then return false end
	return true
end
function meta:ReadInfo()
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
	]]
	for k,v in pairs( info ) do self[k] = v end
	self.fontName = self.buffer:ReadString()
end
function meta:ReadCommon()
	for k,v in pairs( self.buffer:ReadStructure[[unsigned short lineHeight;
	unsigned short base;
	unsigned short scaleW;
	unsigned short scaleH;
	unsigned short pages;
	byte flags;
	byte alphaChnl;
	byte redChnl;
	byte greenChnl;
	byte blueChnl;]] ) do
		self[k] = v
	end
end
function meta:ReadPages()
	local count = self.pages
	
	self.pages = {}
	for i = 1, count do
		local name = self.buffer:ReadString()
		
		self.pages[ i - 1 ] = { name = name, chars = {}, png = Texture( self.path .. name )  }
		
	end
end
function meta:ReadChars(n)
	for i = 1, n do
		local char = self.buffer:ReadStructure[[int id;
		unsigned short x;
		unsigned short y;
		unsigned short width;
		unsigned short height;
		short xoff;
		short yoff;
		short xadvance;
		byte page;
		byte chnl;]]
		char.tex = self.pages[ char.page ].png
		
		self.pages[ char.page ].chars[ char.id ] = char
		self.chars[ char.id ] = char
	end
end
local TYPE_INFO = 1
local TYPE_COMMON = 2
local TYPE_PAGES = 3
local TYPE_CHARS = 4
function meta:ReadBlock()
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
		self.buffer:Advance( size )
	end
	return self.buffer:TheEnd()
end
function meta:ReadBlocks()
	assert(self:ReadHeader())
	while not self:ReadBlock() do end
	return self
end
function meta:DrawString( str, X, Y )
	local curX, curY = X, Y
	local lastTex
	
	for i = 1, utf8.length( str ) do
		local char = utf8.byte( str, i )
		if char == '\n' then
			curX = X
			curY = curY + self.lineHeight
		else
			local ch = self.chars[ char ]
			if ch then
				if lastTex ~= ch.tex then surface.SetTexture( ch.tex ) lastTex = ch.tex end
				local perc = ch.x / lastTex.w
				local w, h = ch.width, ch.height
				
				surface.SetRectUV( ch.x, ch.y, w, h, lastTex.w, lastTex.h )
				surface.DrawRect( curX + ch.xoff, curY + ch.yoff, w, h )
				curX = curX + ch.xadvance
			end
		end
	end
	return curX, curY
end
function meta:GetTextSize( str )
	local curX, curY = 0, 0
	local lastTex
	
	for i = 1, utf8.length( str ) do
		local char = utf8.byte( str, i )
		if char == '\n' then
			curX = X
			curY = curY + self.lineHeight
		else
			local ch = self.chars[ char ]
			if ch then
				curX = curX + ch.xadvance
			end
		end
	end
	return curX, curY
end

angelfont = _G.angelfont or {}

function angelfont.AttemptLoad( path, options, cb )
	local f, rsn = assert(vfs.GetFile(options.path, "rb" ))

	local buffer = Buffer( f )
	return setmetatable( {buffer = buffer, path = options.path, chars = {}}, meta ):ReadBlocks()
end

surface.AddFontLoader( angelfont )

return angelfont