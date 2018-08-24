local oh = ... or _G.oh

runfile("syntax.lua", oh)

local META = {}
META.__index = META

local token_meta = {__tostring = function(s)
	return "token['" .. s.value .. "'][" .. s.i .. "]"
end}

function META:Error(msg, start, stop, level)
	start = start or self:GetToken().start
	stop = stop or self:GetToken().stop
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

	error(str, level or 2)
end

function META:Dump()
	local start = 0
	for _,v in ipairs(self.chunks) do
		log(
			self.code:sub(start+1, v.start-1),
			"⸢", self.code:sub(v.start, v.stop), "⸥"
		)
		start = v.stop
	end
	log("⸢", self.code:sub(start+1), "⸥")
end

function META:GetToken(offset)
	local i = self.i + (offset or 0)
	local info = self.chunks[i]
	if not info then return end
	info.value = info.value or self.code:sub(info.start, info.stop)
	info.i = i
	setmetatable(info, token_meta)
	return info
end

function META:ReadToken()
	local tk = self:GetToken()
	self:NextToken()
	return tk
end

function META:IsValue(str, offset)
	local tk = self:GetToken(offset)
	return tk and tk.value == str
end

function META:IsType(str, offset)
	local tk = self:GetToken(offset)
	return tk and tk.type == str
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


runfile("grammar.lua", META)
runfile("tokenizer.lua", META)

function oh.Tokenize(code)
	local self = {}

	setmetatable(self, META)

	self.code = code
	self.code_length = #code

	self.chunks = {}
	self.chunks_i = 1
	self.i = 1

	self:Tokenize()

	return self
end

oh.parser_meta = META

if RELOAD then
	oh.Test()
end