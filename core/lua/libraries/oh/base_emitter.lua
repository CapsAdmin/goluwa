local oh = ... or _G.oh

local table_remove = table.remove
local ipairs = ipairs

local META = {}
META.__index = META

function META:Whitespace(str, force)

	if self.config.preserve_whitespace and not force then return end

	if str == "?" then
		if self:GetPrevCharType() == "letter" or self:GetPrevCharType() == "number" then
			self:Emit(" ")
		end
	elseif str == "\t" then
		self:EmitIndent()
	elseif str == "\t+" then
		self:Indent()
	elseif str == "\t-" then
		self:Outdent()
	else
		self:Emit(str)
	end
end


function META:Emit(str)
	if type(str) ~= "string" then
		table.print(str)
		print(debug.traceback())
	end
	self.out[self.i] = str or ""
	self.i = self.i + 1
end

function META:Indent()
	self.level = self.level + 1
end

function META:Outdent()
	self.level = self.level - 1
end

function META:EmitIndent()
	self:Emit(("\t"):rep(self.level))
end

function META:GetPrevCharType()
	local prev = self.out[self.i - 1]
	return prev and lua.syntax.GetCharacterType(prev:sub(-1))
end

function META:EmitToken(v, translate)
	if v.whitespace then
		for _, data in ipairs(v.whitespace) do
			if data.type ~= "space" or self.config.preserve_whitespace then
				self:Emit(data:get_value())
			end
		end
	end

	if translate then
		if type(translate) == "table" then
			self:Emit(translate[v:get_value()] or v:get_value())
		elseif translate ~= "" then
			self:Emit(translate)
		end
	else
		self:Emit(v:get_value())

		if self.FORCE_INTEGER then
			if v.type == "number" then
				self:Emit("LL")
			end
		end
	end
end

function META:BuildCode(block)
	self.level = 0
	self.out = {}
	self.i = 1

	self:Block(block)

	return table.concat(self.out)
end

function META:Block(block)
	error("NYI")
end

return META