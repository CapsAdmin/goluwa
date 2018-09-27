local oh = ... or _G.oh

runfile("syntax.lua", oh)

local META = {}
META.__index = META

function META:Error(msg, start, stop, level)
	start = start or self:GetToken() and self:GetToken().start or self.i
	stop = stop or self:GetToken() and self:GetToken().stop or self.i
	offset = offset or 0

	local context_start = self.code:sub(math.max(start - 50, 2), start - 1)
	local context_stop = self.code:sub(stop, stop + 50)

	context_start = context_start:gsub("\t", " ")
	context_stop = context_stop:gsub("\t", " ")

	local content_before = #(context_start:reverse():match("(.-)\n") or context_start)
	local content_after = (context_stop:match("(.-)\n") or "")

	local len = math.abs(stop - start)
	local str = (len > 0 and self.code:sub(start, stop - 1) or "") .. content_after .. "\n"

	str = str .. (" "):rep(content_before) .. ("_"):rep(len) .. "^" .. ("_"):rep(#content_after - 1) .. " " .. msg .. "\n"

	str = "\n" .. context_start .. str .. context_stop:sub(#content_after + 1)

	str =  "\n" .. self.path .. ":" .. self.code:sub(0, start):count("\n") .. "\n" .. str

	error(str, level or 2)
end

function META:GetToken(offset)
	if offset then
		return self.chunks[self.i + offset]
	end

	return self.chunks[self.i]
end

function META:ReadToken()
	local tk = self:GetToken()
	self:NextToken()
	return tk
end

function META:IsValue(str, offset)
	local tk = self:GetToken(offset)
	return tk and tk.value == str and tk
end

function META:ReadIsValue(str, offset)
	local b = self:IsValue(str, offset)
	self:NextToken()
	return b
end

function META:IsType(str, offset)
	local tk = self:GetToken(offset)
	return tk and tk.type == str
end

function META:ReadIsType(str, offset)
	local b = self:IsType(str, offset)
	self:NextToken()
	return b
end

function META:ReadIfType(str, offset)
	local b = self:IsType(str, offset)
	if b then
		self:NextToken()
	end
	return b
end

function META:ReadIfValue(str, offset)
	local b = self:IsValue(str, offset)
	if b then
		self:NextToken()
	end
	return b
end

function META:CheckTokenValue(tk, value, level)
	if tk.value ~= value then
		self:Error("expected " .. value .. " got " .. tk.value, nil,nil,level or 3)
	end
end

function META:CheckTokenType(tk, type)
	if tk.type ~= type then
		self:Error("expected " .. type .. " got " .. tk.type, nil,nil,level or 3)
	end
end

function META:ReadExpectType(type)
	local tk = self:GetToken()
	self:CheckTokenType(tk, type, 4)
	self:NextToken()
	return tk
end

function META:ReadExpectValue(value)
	local tk = self:GetToken()
	self:CheckTokenValue(tk, value, 4)
	self:NextToken()
	return tk
end

function META:GetLength()
	return #self.chunks
end

function META:NextToken()
	self.i = self.i + 1
end

function META:Back()
	self.i = self.i - 1
end

function META:Iterate()
	return function()
		return self:ReadToken()
	end
end

runfile("grammar.lua", META)

function oh.Parser(tokens, code, path)
	local self = {}

	setmetatable(self, META)

	self.chunks = tokens
	self.code = code
	self.path = path or "?"

	self.i = 1

	return self
end

oh.parser_meta = META