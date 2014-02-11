-- finish caret movement port from text input

local META = {}
META.__index = META

function _G.Markup(a, ...)
	local self = {w = 0, h = 0, chunks = {}}
	setmetatable(self, META)

	if a then
		self:SetTable({a, ...})
	end

	return self
end

class.GetSet(META, "Table", {})
class.GetSet(META, "MaxWidth", 500)
class.GetSet(META, "EditMode", false)
 
function META:SetEditMode(b)
	self.EditMode = b
	self.need_layout = true
end

function META:SetMaxWidth(w)
	self.MaxWidth = w
	self.need_layout = true
end

-- these are used by EXT.SetColor, EXT.SetFont etc
local FONT = "markup"
local R, G, B, A = 255, 255, 255, 255
local X, Y = 0, 0

local EXT = {
	Rand = math.randomf,
	FormatPrint = logf,
	GetFrameTime = timer.GetFrameTime,
	GetTime = timer.GetTime,
	LoadString = loadstring,
	CreateConVar = console.CreateVariable,
	GetConVarFloat = function(c) return c:Get() end,

	HSVToColor = function(h,s,v) return HSVToColor(h,s,v):Unpack() end,

	SetMaterial = surface.SetTexture,
	SetColor = function(r,g,b,a)
		R=r G=g B=b A=a or 1

		if R>1 then R=R/255 end
		if G>1 then G=G/255 end
		if B>1 then B=B/255 end
		if A>1 then A=A/255 end

		surface.Color(R,G,B,A)
	end,
	DrawRect = surface.DrawRect,
	DrawText = surface.DrawText,
	SetTextPos = function(x, y) X=x Y=y surface.SetTextPos(x,y) end,
	SetFont = function(str)
		FONT = str
		surface.SetFont(str)
	end,
	GetTextSize = surface.GetTextSize,
	SetAlphaMultiplier = surface.SetAlphaMultiplier,
	GetScreenHeight = function() return select(2, surface.GetScreenSize()) end,
	GetScreenWidth = function() return (surface.GetScreenSize()) end,

	SetCullClockWise = function(b) end,
	FindMaterial = Image,
	CreateMatrix = Matrix44,

	TranslateMatrix = function(m, x, y) m:Translate(x or 0, y or 0, 0) end,
	ScaleMatrix = function(m, x, y) m:Scale(x or 0, y or 0, 1) end,
	RotateMatrix = function(m, a) m:Rotate(a, 0, 0, 1) end,

	PushMatrix = render.PushWorldMatrixEx,
	PopMatrix = render.PopWorldMatrix,
}

-- config start

META.fonts = {
	default = {
		name = "markup_default",
		data = {
			font = "DejaVu Sans",
			size = 14,
			antialias = true,
			outline = false,
			weight = 580,
		} ,
	},

	chatprint = {
		name = "markup_chatprint",
		color = Color(201, 255, 41, 255),
		data = {
			font = "Verdana",
			size = 16,
			weight = 600,
			antialias = true,
			shadow = true,
		},
	},
}

do -- tags
	META.tags = {}

	do -- base

		META.tags.hsv =
		{
			arguments = {0, 1, 1},

			draw = function(markup, self, x,y, h, s, v)
				local r,g,b = EXT.HSVToColor(h, s, v)
				EXT.SetColor(r, g, b, 255)
			end,
		}

		META.tags.color =
		{
			arguments = {255, 255, 255, 255},

			draw = function(markup, self, x,y, r,g,b,a)
				EXT.SetColor(r, g, b, a)
			end,
		}

		META.tags.physics =
		{
			arguments = {1, 0, 0, 0, 0.99, 0.1},

			pre = function(markup, self, gx, gy, vx, vy, drag, rand_mult)
				local part = {}

				part =
				{
					pos = {x = 0, y = 0},
					vel = {x = vx, y = vy},
					siz = 10,
					rand_mult = rand_mult,
					drag = drag,
				}

				self.part = part
			end,

			draw = function(markup, self, x,y, gravity_y, gravity_x, vx, vy, drag, rand_mult)
				local delta = EXT.GetFrameTime() * 5

				local part = self.part

				local cx = x
				local cy = y - 10

				local W, H = markup.MaxWidth/2, EXT.GetScreenHeight()

				W = W - cx
				H = H - cy

				-- random velocity for some variation
				part.vel.y = part.vel.y + gravity_y + (EXT.Rand(-1,1) * rand_mult)
				part.vel.x = part.vel.x + gravity_x + (EXT.Rand(-1,1) * rand_mult)

				-- velocity
				part.pos.x = part.pos.x + (part.vel.x * delta)
				part.pos.y = part.pos.y + (part.vel.y * delta)

				-- friction
				part.vel.x = part.vel.x * part.drag
				part.vel.y = part.vel.y * part.drag

				-- collision
				if part.pos.x - part.siz < -cx then
					part.pos.x = -cx + part.siz
					part.vel.x = part.vel.x * -part.drag
				end

				if part.pos.x + part.siz > W then
					part.pos.x = W - part.siz
					part.vel.x = part.vel.x * -part.drag
				end

				if part.pos.y - part.siz < -cy then
					part.pos.y = -cy + part.siz
					part.vel.y = part.vel.y * -part.drag
				end

				if part.pos.y + part.siz > H then
					part.pos.y = H - part.siz
					part.vel.y = part.vel.y * -part.drag
				end

				local mat = EXT.CreateMatrix()

				EXT.TranslateMatrix(mat, part.pos.x, part.pos.y)

				EXT.PushMatrix(mat)
			end,

			post = function()
				EXT.PopMatrix()
			end,
		}

		META.tags.font =
		{
			arguments = {"markup_default"},

			draw = function(markup, self, x,y, font)
				EXT.SetFont(font)
			end,

			pre = function(markup, self, font)
				EXT.SetFont(font)
			end,
		}

		META.tags.texture =
		{
			arguments = {"error", {default = 1, min = 1, max = 4}},

			pre = function(markup, self, path)
				self.mat = EXT.FindMaterial(path)
			end,

			get_size = function(markup, self, path, size_mult)
				return 8 * size_mult, 8 * size_mult
			end,

			draw = function(markup, self, x,y,a, path)
				EXT.SetMaterial(self.mat)
				EXT.DrawRect(x, y, self.w, self.h)
			end,
		}

	end

	do -- matrix by !cake
		local function detM2x2 (m11, m12, m21, m22)
			return m11 * m22 - m12 * m21
		end

		local function mulM2x2V2 (m11, m12, m21, m22, v1, v2)
			return v1 * m11 + v2 * m12, v1 * m21 + v2 * m22
		end

		local function normalizeV2(x, y)
			local length = math.sqrt(x * x + y * y)
			return x / length, y / length
		end

		local function scaleV2(v1, v2, k)
			return v1 * k, v2 * k
		end

		local function eigenvector2(l, a, d)
			-- (a - ?) u1 + d u2 = 0
			if a - l == 0 then return 1, 0 end
			if     d == 0 then return 0, 1 end

			return normalizeV2(-d / (a - l), 1)
		end

		local function orthonormalM2x2ToVMatrix(m11, m12, m21, m22, mat)
			local det = detM2x2(m11, m12, m21, m22)

			if det < 0 then
				EXT.ScaleMatrix(mat, 1, -1)
			end

			local angle = math.atan2 (m21, m11)
			EXT.RotateMatrix(mat, math.deg(angle))

			return mat
		end

		META.tags.translate =
		{
			arguments = {0, 0},

			draw = function(markup, self, x, y, dx, dy)
				local mat = EXT.CreateMatrix()
				EXT.TranslateMatrix(mat, dx, dy)

				EXT.PushMatrix(mat)
			end,

			post = function()
				EXT.PopMatrix()
			end,
		}

		META.tags.scale =
		{
			arguments = {1, nil},

			draw = function(markup, self, x, y, scaleX, scaleY)
				local mat = EXT.CreateMatrix()

				scaleY = scaleY or scaleX
				self.matrixDeterminant = scaleX * scaleY

				if math.abs (self.matrixDeterminant) > 10 then
					scaleX, scaleY = normalizeV2(scaleX, scaleY)
					scaleX, scaleY = scaleV2(scaleX, scaleY, 10)
				end

				local centerY = y - self.message_height / 2

				EXT.TranslateMatrix(mat, x, centerY)
					EXT.ScaleMatrix(mat, scaleX, scaleY)

					if scaleX < 0 then
						EXT.TranslateMatrix(mat, -self.message_width, 0)
					end
				EXT.TranslateMatrix(mat, -x, -centerY)

				EXT.PushMatrix(mat)

				EXT.SetCullClockWise(self.matrixDeterminant < 0)
			end,

			post = function(markup, self)
				if self.matrixDeterminant < 0 then
					EXT.SetCullClockWise(false)
				end

				EXT.PopMatrix()
			end,
		}

		META.tags.rotate =
		{
			arguments = {0},

			draw = function(markup, self, x, y, angleInDegrees)
				local mat = EXT.CreateMatrix()

				local centerX = x + self.message_width / 2
				local centerY = y - self.message_height / 2

				EXT.TranslateMatrix(mat, centerX, centerY)
					EXT.RotateMatrix(mat, angleInDegrees)
				EXT.TranslateMatrix(mat, -centerX, -centerY)

				EXT.PushMatrix(mat)
			end,

			post = function()
				EXT.PopMatrix()
			end,
		}

		META.tags.matrixez =
		{
			arguments = {0,0,1,1,0},

			draw = function(markup, self, x, y, X, Y, scaleX, scaleY, angleInDegrees)
				local mat = EXT.CreateMatrix()

				self.matrixDeterminant = scaleX * scaleY

				if math.abs (self.matrixDeterminant) > 10 then
					scaleX, scaleY = normalizeV2(scaleX, scaleY)
					scaleX, scaleY = scaleV2(scaleX, scaleY, 10)
				end

				local centerX = self.message_width / 2
				local centerY = y - self.message_height / 2

				EXT.TranslateMatrix(mat, x, centerY)
					EXT.TranslateMatrix(mat, X,Y)
					EXT.ScaleMatrix(mat, scaleX, scaleY)
					if scaleX < 0 then
						EXT.TranslateMatrix(mat, -self.message_width, 0)
					end
					if angleInDegrees ~= 0 then
						EXT.TranslateMatrix(mat, centerX)
							EXT.RotateMatrix(mat, angleInDegrees)
						EXT.TranslateMatrix(mat, -centerX)
					end
				EXT.TranslateMatrix(mat, x, -centerY)

				EXT.PushMatrix(mat)

				EXT.SetCullClockWise(self.matrixDeterminant < 0)
			end,

			post = function(markup, self)
				if self.matrixDeterminant < 0 then
					EXT.SetCullClockWise(false)
				end

				EXT.PopMatrix()
			end,
		}

		META.tags.matrix =
		{
			arguments = {1, 0, 0, 1, 0, 0},

			draw = function(markup, self, x, y, a11, a12, a21, a22, dx, dy)
				-- Ph'nglui mglw'nafh Cthulhu R'lyeh wgah'nagl fhtagn

				-- A = Q1 ? Q2

				-- B = transpose (A) * A
				local b11 = a11 * a11 + a21 * a21
				local b12 = a11 * a12 + a21 * a22
				local b21 = a12 * a11 + a22 * a21
				local b22 = a12 * a12 + a22 * a22
				local trB  = b11 + b22
				local detB = detM2x2(b11, b12, b21, b22)

				-- Finding eigenvalues of B...
				-- det (B - ?I) = 0
				-- | a - ?        b | = 0
				-- |     c    d - ? |
				--
				-- (a - ?) (d - ?) - bc = 0
				-- ?² + (-a - d) ? + ad - bc = 0
				--
				--     a + d ± sqrt ((a + d)² - 4 (ad - bc))
				-- ? = -------------------------------------
				--                      2

				-- This is never negative
				local sqrtInside = trB * trB - 4 * detB
				local eigenvalue1 = 0.5 * (trB + math.sqrt(sqrtInside))
				local eigenvalue2 = 0.5 * (trB - math.sqrt(sqrtInside))

				-- (B - ?I) u = 0
				--
				-- [ a - ?        b ] [ u1 ] = [ 0 ]
				-- [     c    d - ? ] [ u2 ]   [ 0 ]
				--
				-- (a - ?) u1 +      b  u2 = 0
				local q211, q221 = eigenvector2(eigenvalue1, b11, b12)
				local q212, q222 = eigenvector2(eigenvalue2, b11, b12)

				if eigenvalue1 == eigenvalue2 then
					-- Make up an eigenvector
					q212, q222 = q221, -q211
				end

				-- Those will never be negative as well #yolo
				local scaleX = math.sqrt (eigenvalue1)
				local scaleY = math.sqrt (eigenvalue2)

				local detQ2 = q211 * q222 - q212 * q221
				local q111, q121 = mulM2x2V2(a11, a12, a21, a22, q211, q221)
				local q112, q122 = mulM2x2V2(a11, a12, a21, a22, q212, q222)
				q111, q121 = scaleV2(q111, q121, (scaleX ~= 0) and (1 / scaleX) or 0)

				if scaleY == 0 then
					q112, q122 = q121, -q111
				else
					-- DOES THIS WORK LOL
					q112, q122 = scaleV2(q112, q122, (scaleY ~= 0) and (1 / scaleY) or 0)
				end

				-- transpose Q2
				q212, q221 = q221, q212

				-- End of Cthulhu summoning

				self.matrixDeterminant = detM2x2(a11, a12, a21, a22)

				local mat = EXT.CreateMatrix()

				local center = Vector(x, y)
				EXT.TranslateMatrix(mat, x, y)
					EXT.TranslateMatrix(mat, dx, dy)

					orthonormalM2x2ToVMatrix(q211, q212, q221, q222, mat)
					EXT.ScaleMatrix(mat, scaleX, scaleY)
					orthonormalM2x2ToVMatrix(q111, q112, q121, q122, mat)
				EXT.TranslateMatrix(mat, -x, -y)

				EXT.PushMatrix(mat)

				EXT.SetCullClockWise(self.matrixDeterminant < 0)
			end,

			post = function(markup, self)
				if self.matrixDeterminant < 0 then
					EXT.SetCullClockWise(false)
				end

				EXT.PopMatrix()
			end,
		}
	end
end

-- internal

-- normalize everything into a consistent markup table
-- strings are also parsed
-- go through every argument
-- markup:SetTable({Color(1,1,1), "asdasd", {"asdasd"}, ...})

function META:Clear()
	self.chunks = {}
	self.need_layout = true
end

function META:SetTable(tbl)
	self.Table = tbl
	
	self:Clear()
	
	for i, var in ipairs(tbl) do
		self:Add(var)
	end
end

function META:AddColor(color)
	table.insert(self.chunks, {type = "color", val = color})
	self.need_layout = true
end

function META:AddString(str)
	str = tostring(str)
	
	if self.EditMode then
		table.insert(self.chunks, {type = "string", val = str})
	else
		for _, chunk in pairs(self:StringTagsToTable(str)) do
			table.insert(self.chunks, chunk)
		end
	end
	self.need_layout = true
end

function META:AddFont(font)
	table.insert(self.chunks, {type = "font", val = font})
	self.need_layout = true
end

function META:Add(var)
	local chunks = self.chunks
	local t = typex(var)

	if t == "color" then
		self:AddColor(var)
	elseif t == "string" or t == "number" then
		self:AddString(var)
	elseif t == "table" and val.type and val.cal then
		table.insert(temp, val)
	elseif t ~= "cdata" then
		logf("tried to parse unknown type %q", t)
	end
end

local time_speed = 1
local time_offset = 0
local panic = false

local function call_tag_func(self, chunk, name, ...)
	if not chunk.val.tag then return end

	if chunk.type == "custom" then

		local func = chunk.val.tag and chunk.val.tag[name]

		if func then
			local sigh = {self, chunk, ...}
			for k,v in pairs(chunk.val.args) do
				if type(v) == "function" then
					local ok, val = pcall(v, chunk.exp_env)
					if ok and val then
						v = val
					else
						v = chunk.val.tag.arguments[k]
						if type(v) == "table" then
							v = v.default
						end
					end
				end
				table.insert(sigh, v)
			end

			local args = {pcall(func, unpack(sigh))}

			if not args[1] then
				logf("tag error %s", args[2])
			else
				return select(2, unpack(args))
			end
		end
	end
end

-- tag parsing
do 
	local function parse_tag_arguments(self, str)
		str = str .. ","
		local out =  {}
		local expressions = {}

		str = str:gsub("(%[.-%]),", function(expression)
			local id =  "__" .. expression .. "__"
			expressions[id] = expression:sub(2, -2)
			return id .. ","
		end)

		for arg in str:gmatch("(.-),") do
			if expressions[arg]	 then
				local ok, func = expression.Compile(expressions[arg])
				if func then
					table.insert(out, func)
				else
					logf("markup expression error: %s", func)
					table.insert(out, 0)
				end
			else
				table.insert(out, arg)
			end
		end

		return out
	end

	function META:StringTagsToTable(str)
		local chunks = {}
		local found = false

		local in_tag = false
		local current_string = {}
		local current_tag = {}

		for i, char in pairs(utf8.totable(str)) do
			if char == "<" then

				-- if we've been parsing a string add it
				if current_string then
					table.insert(chunks, {type = "string", val = table.concat(current_string, "")})
				end

				-- stat a new tag
				current_tag = {}
				in_tag = true
			elseif char == ">" and in_tag then
				-- maybe the string was "sdasd :> sdsadasd <color123>..."
				if current_tag then
					local tag_str = table.concat(current_tag, "") .. ">"
					local tag, args = tag_str:match("<(.-)[?=](.+)>")

					local info = self.tags[tag]

					if info then
						local args = parse_tag_arguments(self, args or "")

						for i = 1, #info.arguments do
							local arg = args[i]
							local default = info.arguments[i]
							local t = type(default)

							if t == "number" then
								local num = tonumber(arg)

								if not num and type(arg) == "function" then
									num = arg
								end

								args[i] = num or default
							elseif t == "string" then
								if not arg or arg == "" then
									arg = default
								end

								args[i] = arg
							elseif t == "table" then
								if default.min or default.max or default.default then
									local num = tonumber(arg)

									if num then
										if default.min and default.max then
											args[i] = math.min(math.max(num, default.min), default.max)
										elseif default.min then
											args[i] = math.min(num, default.min)
										elseif default.max then
											args[i] = math.max(num, default.max)
										end
									else
										if type(arg) == "function" then
											if default.min and default.max then
												args[i] = function(...) return math.min(math.max(arg(...) or default.default, default.min), default.max) end
											elseif default.min then
												args[i] = function(...) return math.min(arg(...) or default.default, default.min) end
											elseif default.max then
												args[i] = function(...) return math.max(arg(...) or default.default, default.max) end
											end
										else
											args[i] = default.default
										end
									end
								end
							end
						end

						found = true
				
						-- if this is a string tag just put color and font as if they were var args for better performance
						if type == "font" then
							table.insert(chunks, {type = "font", val = args[1]})							
						elseif type == "color" then
							table.insert(chunks, {type = "color", val = Color(unpack(args))})
						else
							table.insert(chunks, {type = "custom", val = {tag = info, type = tag, args = args}})
						end

					end
				end

				current_string = {}
				in_tag = false
			end

			if in_tag then
				table.insert(current_tag, char)
			elseif char ~= ">" then
				table.insert(current_string, char)
			end
		end

		if found then
			table.insert(chunks, {type = "string", val = table.concat(current_string, "")})
		else
			chunks = {{type = "string", val = str}}
		end

		return chunks
	end
end

function META:Invalidate()	
	EXT.SetFont(self.fonts.default.name)
	
	-- this is needed when invalidating the chunks table again
	-- anything that need to add more chunks need to store the 
	-- old chunk as old_chunk key
	
	local temp = {}
	local old_chunks = {}
	
	local skipped = 0
	
	for i, chunk in ipairs(self.chunks) do
		local old = chunk.old_chunk
		
		
		if old then
			old.old_chunk = nil -- ??
			
			if not old_chunks[old] then
				table.insert(temp, old)
				old_chunks[old] = true 
			end
		else 
			table.insert(temp, chunk)
		end
	end

	
	
	--[[
	-- uncomment this if chunk leaks occur
		
	local types = {}
	
	for i, chunk in ipairs(self.chunks) do
		types[chunk.type] = (types[chunk.type] or 0) + 1
	end
	
	table.print(types)
	
	logn("")
	logn("==")
	logf("chunk count      = %i", #self.chunks)
	logf("old chunks count = %i", table.count(old_chunks))
	logn("")
	
	]]
	
	
	
	
	-- solve white space and punctation
	
	local temp2 = {}
	for i, chunk in ipairs(temp) do
		if chunk.type == "string" and chunk.val:find("%s") then
			local str = ""
			
			for i, char in ipairs(utf8.totable(chunk.val)) do
				if char:find("%s") then
					if str ~= "" then
						table.insert(temp2, {type = "string", val = str, old_chunk = chunk})
						str = ""
					end
					
					if char == "\n" then
						table.insert(temp2, {type = "newline", old_chunk = chunk})
					else
						table.insert(temp2, {type = "string", val = char, whitespace = true, old_chunk = chunk})
					end
				else
					str = str .. char
				end
			end

			if str ~= "" then
				table.insert(temp2, {type = "string", val = str, old_chunk = chunk})
			end			
		else
			table.insert(temp2, chunk)
		end
	end
 


	
	-- get the size of each object
	for i, chunk in ipairs(temp2) do
		if chunk.type == "font" then
			-- set the font so GetTextSize will be correct
			EXT.SetFont(chunk.val)
		elseif chunk.type == "string" then
			local w, h = EXT.GetTextSize(chunk.val)
			
			chunk.w = w
			chunk.h = h
		elseif chunk.type == "custom" then
			local w, h = call_tag_func(self, chunk, "get_size")

			chunk.w = w
			chunk.h = h

			call_tag_func(self, chunk, "pre")
		end
 
		-- for consistency everything should have x y w h
		chunk.x = chunk.x or 0
		chunk.y = chunk.y or 0
		chunk.w = chunk.w or 0
		chunk.h = chunk.h or 0
	end
	
 
 

	-- solve max width
	local current_x = 0
	local current_y = 0

	local chunk_height = 0 -- the height to advance y in

	for i, chunk in ipairs(temp2) do				
		-- is the previous line a newline?
		local newline = temp2[i - 1] and temp2[i - 1].type == "newline"

		-- figure out the tallest chunk before going to a new line
		if chunk.h > chunk_height then
			chunk_height = chunk.h
		end

		-- is this a new line or are we going to exceed the maximum width?
		if newline or current_x + chunk.w >= self.MaxWidth then		
		
			-- if this is whitespace just get rid of it and pretend it wasn't there
			-- this causes issues with newlines
			--[[if chunk.whitespace then
				current_x = current_x - chunk.w
				goto continue
			end]]
		
			-- reset the width
			current_x = 0
			
			-- advance y with the height of the tallest chunk
			current_y = current_y + chunk_height
		end
		
		chunk.x = current_x
		chunk.y = current_y

		current_x = current_x + chunk.w
		
		--::continue::
	end	
	
	
	
	
	-- solve max width once more but for every letter
	-- note: slow and useless?
	local temp = {}
	
	for i, chunk in ipairs(temp2) do
		local split = false
		
		if chunk.type == "font" then
			-- set the font so GetTextSize will be correct
			EXT.SetFont(chunk.val)
		elseif chunk.type == "string" then 
			-- if x+w exceeds maxwidth split!
			if chunk.x + chunk.w >= self.MaxWidth then

				-- start from the chunk's y
				local current_x = chunk.x 
				local current_y = chunk.y
				local chunk_height = 0 -- the height to advance y in
				
				local str = ""

				for i, char in ipairs(utf8.totable(chunk.val)) do		
					local w, h = surface.GetTextSize(char)
					
					if h > chunk_height then
						chunk_height = h
					end
					
					str = str .. char
					current_x = current_x + w  
					
					if current_x + w > self.MaxWidth then
						table.insert(temp, {type = "string", val = str, x = 0, y = current_y, w = current_x, h = chunk_height, old_chunk = chunk})
						current_y = current_y + chunk_height
						
						current_x = 0
						chunk_height = 0 
						split = true	
						str = ""
					end
					
					
				end

				if split then
					table.insert(temp, {type = "string", val = str, x = 0, y = current_y, w = current_x, h = chunk_height, old_chunk = chunk})
				end
			end

		end

		if not split then	
			-- i don't know why i need this
			-- if i don't have this the chunk table will 
			-- continue to grow when invalidating itself	
			chunk.old_chunk = chunk			
			
			table.insert(temp, chunk)
		end
	end
	
	
	
	
	-- one extra step..
	-- this should be in a while loop
	-- but i choose not for performance reasons

	local current_x = 0
	local current_y = 0

	local chunk_height = 0 -- the height to advance y in

	for i, chunk in ipairs(temp) do	
				
		-- is the previous line a newline?
		local newline = temp[i - 1] and temp[i - 1].type == "newline"
		
		if newline and chunk.type == "string" and not chunk.whitespace then

			-- figure out the tallest chunk before going to a new line
			if chunk.h > chunk_height then
				chunk_height = chunk.h
			end

			-- is this a new line or are we going to exceed the maximum width?
			if newline or current_x + chunk.w >= self.MaxWidth then		
				-- reset the width
				current_x = 0
				
				-- advance y with the height of the tallest chunk
				current_y = current_y + chunk_height
				current_y = chunk.y
			end

			chunk.x = current_x
			chunk.y = current_y

			current_x = current_x + chunk.w

		end
	end
	
	
	
	
	
	local chunks = temp

	-- this is for expressions to be use d like line.i+time()
	for i, chunk in ipairs(chunks) do
		chunk.exp_env = {
			i = i,
			w = chunk.w,
			h = chunk.h,
			x = chunk.x,
			y = chunk.y,
			rand = math.random()
		}
	end
	 
	do -- store some extra info
		local line = 0
		local width = 0
		local height = 0
		local last_y 
		
		local font = "default"
		local color = Color(1,1,1,1)
		
		local function build_chars(chunk)
			if not chunk.chars then
				EXT.SetFont(chunk.font)
				chunk.chars = {}
				local width = 0
				for i, char in ipairs(utf8.totable(chunk.val)) do
					local char_width, char_height = surface.GetTextSize(char)
					local x = chunk.x + width
					local y = chunk.y
					
					chunk.chars[i] = {
						x = x, 
						y = chunk.y, 
						w = char_width,  
						h = char_height,
						right = x + char_width,
						top = y + char_height,
						char = char,
						i  = i,
						chunk = chunk,
					}
					width = width + char_width
				end
			end
		end
		
		for i, chunk in ipairs(chunks) do
			
			if chunk.type == "font" then
				font = chunk.val
			elseif chunk.type == "color" then
				color = chunk.val
			elseif chunk.type == "string" then
				chunk.font = font
				chunk.color = color
			end
		
			local w = chunk.x + chunk.w
			if w > width then
				width = w
			end
			
			local h = chunk.y + chunk.h
			if w > height then
				height = h
			end
			
			if chunk.y ~= last_y then
				line =  line + 1
				last_y = chunk.y
			end
			
			chunk.line = line
			chunk.build_chars = build_chars
			chunk.i = i
		end
		
		self.lines = line
		self.width = width
		self.height = height
	end
	
	
	
	
	

	do -- align the y axis properly
		local h = 0
		
		for _, chunk in ipairs(chunks) do
			if chunk.line == 1 then
				if chunk.h > h then
					h = chunk.h
				end
			else
				break
			end
		end
				
		for _, chunk in ipairs(chunks) do
			chunk.y = chunk.y - chunk.h + h
			
			-- mouse testing
			chunk.right = chunk.x + chunk.w
			chunk.top = chunk.y + chunk.h			
		end
	end
	
	 
	
	
	
	-- SLOOOOOOW
	if false then
	timer.Measure("linked list")
	-- build linked list (mainly for matrices)
	local prev = nil	
	for _, chunk in ipairs(chunks) do
		if prev then
			prev.next = chunk
		end
		prev = chunk
	end

	for i, chunk in ipairs(chunks) do
		local w = 0
		local h = 0
		local node = chunk.next
		while node do
			w = w + node.w
			h = math.max (h, node.h)
			node = node.next
		end

		chunk.message_width = w
		chunk.message_height = h
	end
	timer.Measure("linked list")
	end
	
	
	
	
	
	self.chars = nil	
	
	if self.EditMode then		
		--timer.Measure("chars build")
		self.chars = {}
		self.lines = {}
		
		local line = 1
		local line_pos = 1
		local line_str = {}
		
		for i, chunk in ipairs(chunks) do
			chunk.chars = nil
		
			if chunk.type == "string" then
				chunk:build_chars()
				
				for i2, char in pairs(chunk.chars) do
					table.insert(self.chars, {
						chunk = chunk, 
						i = i, 
						str = char.char, 
						data = char, 
						y = line, 
						x = line_pos,
					})
					
					line_pos = line_pos + 1
					
					table.insert(line_str, char.char)
				end
												
			elseif chunk.type == "newline" then
				local data = {}

				local w, h = surface.GetTextSize("|")
				data.w = w
				data.h = h 
				data.x = chunk.x
				data.y = chunk.y - data.h
				data.right = chunk.right
				data.top = chunk.top
				
				table.insert(self.chars, {chunk = chunk, i = i, str = "\n", data = data, y = line, x = line_pos})
				line = line + 1
				line_pos = 0 
				
				table.insert(self.lines, table.concat(line_str, ""))
				line_str = {}
			end
		end
		
		-- add the last line since there's probably not a newline at the very end
		table.insert(self.lines, table.concat(line_str, ""))
		
		self.text = table.concat(self.lines, "\n")
		--timer.Measure("chars build")
	end

	self.chunks = chunks
	
	-- preserve caret positions
	if self.caret_pos and self.EditMode then
		self.caret_pos = self:CaretFromPos(self.caret_pos.char.x, self.caret_pos.char.y)
	else
		self.caret_pos = nil
	end	
	
	if self.select_start then
		self.select_start = self:CaretFromPos(self.select_start.char.x, self.select_start.char.y)
	end
	
	if self.select_end then
		self.select_end = self:CaretFromPos(self.select_end.char.x, self.select_end.char.y)
	end
end

function META:GetSelectedString(skip_tags)

	local out = {}

	local START = self.select_start
	local END = self.select_end

	if START and END then
		if self.EditMode then
			for i = START.i, END.i do
				local char = self.chars[i]
				local data = char.data
				table.insert(out, char.str) 
			end
		else		
			local last_font  
			local last_color
				
			for i, chunk in ipairs(self.chunks) do
				if i >= START.i and i <= END.i then
					if chunk.type == "string" then
						-- this will ensure a clean output
						-- but maybe this should be cleaned in the invalidate function instead?
						if last_font ~= chunk.font then
							table.insert(out, ("<font=%s>"):format(chunk.font))
							last_font = chunk.font
						end
						
						if last_color ~= chunk.color then
							table.insert(out, ("<color=%s,%s,%s,%s>"):format(math.round(chunk.color.r, 2), math.round(chunk.color.g, 2), math.round(chunk.color.b, 2), math.round(chunk.color.a, 2)))
							last_color = chunk.color
						end
					
						if START.char and END.char and START.i == END.i then
							for i, char in ipairs(START.char.chunk.chars) do
								if i >= START.char.i and i <= END.char.i then
									table.insert(out, char.char)
								end
							end
							break
						else		
							if i == START.i then
								if START.char then
									for i, char in ipairs(START.char.chunk.chars) do
										if i >= START.char.i then
											table.insert(out, char.char)
										end
									end
								end
							elseif i == END.i then	
								if END.char then
									for i, char in ipairs(END.char.chunk.chars) do
										if i < END.char.i then
											table.insert(out, char.char)
										end
									end
								end
							elseif i > START.i and i < END.i and START.i ~= END.i then
								table.insert(out, chunk.val)
							end
						end
					elseif chunk.type == "newline" then
						table.insert(out, "\n")
					elseif chunk.type == "custom" then
						if chunk.val.type == "texture" then
							table.insert(out, ("<texture=%s>"):format(chunk.val.args[1]))
						end
					end
				end
			end
		end
	end
	
	return table.concat(out, "")
end

function META:CaretFromPos(x, y)
	if self.EditMode then
		x = x or 1
		y = y or 1
		
		if self.lines[y] and self.lines[y]:sub(-1) == "\n" then x = x - 1 end
		
		y = math.clamp(y, 1, #self.lines)
		x = math.clamp(x, 0, self.lines[y] and self.lines[y]:ulength() or 0)		
	
		for i, char in ipairs(self.chars) do
			
			if char.x == x and char.y == y then
				local data = char.data
				
				return {
					x = data.x,
					y = data.y,
					h = data.h,
					w = data.w,
					i = i,
					char = char,
				}
			end
		end		
		
	else	
		local chunk = self.chunks[#self.chunks]
		
		for i, chunk in ipairs(self.chunks) do		
			if chunk.type == "string" then
			
				chunk:build_chars()
				
				for _, char in ipairs(chunk.chars) do
					if char.x == x and char.y == y then
						return {
							x = char.x,
							y = char.y,
							h = char.h,
							w = char.w,
							i = i,
							char = char,
						}
					end
				end
			else				
				if i == x and y == chunk.line then
					return {
						x = chunk.x,
						y = chunk.y,
						h = chunk.h,
						w = chunk.w,
						i = i
					}
				end
			end
		end
	end
end
  
function META:CaretFromPixels(x, y)
	-- todo: 
	-- select closest to middle of char 
		
	local w, h = surface.GetScreenSize()
	
	if self.EditMode then
				
		for i, char in ipairs(self.chars) do
			local data = char.data
			
			if 
				x > data.x and y > data.y and
				x < data.right and y < data.top
			then
				return {
					x = data.x,
					y = data.y,
					w = data.w,
					h = data.h,
					i = i,
					char = char,
				}
			end
		end
						
		-- if nothing was found we need to check things differnetly
		local line = {}
		
		for i, char in ipairs(self.chars) do
			local data = char.data
			if y > data.y and y < data.top then
				table.insert(line, {i, char})
			end
		end 
		
		if #line > 0 and x > line[#line][2].data.right then 
			local i, char = unpack(line[#line])
			local data = char.data
						 
			return {
				x = data.x,
				y = data.y,
				w = data.w,
				h = data.h,
				i = i,
				char = char,
			}
		end
		
		for i, v in ipairs(line) do
			local i, char = unpack(v)
		
			local data = char.data
			
			if x < data.right then
			
				i = i - 1
				char = self.chars[i]
				
				return {
					x = data.x,
					y = data.y,
					w = data.w,
					h = data.h,
					i = i,
					char = char,
				}
			end
		end
		
	else
	
		local chunk = self.chunks[#self.chunks]
		
		for i, chunk in ipairs(self.chunks) do	
			if chunk.x > w then break end
			if chunk.y > h then break end
		
			if 
				x > chunk.x and y > chunk.y and
				x < chunk.right and y < chunk.top
			then			
				if chunk.type == "string" then
					
					chunk:build_chars()
					
					for _, char in ipairs(chunk.chars) do
						if 
							x > char.x and y > char.y and
							x < char.right and y < char.top
						then
							return {
								x = char.x,
								y = char.y,
								w = char.w,
								h = char.h,
								i = i,
								char = char,
							}
						end
					end
				else
					return {
						x = chunk.x,
						y = chunk.y,
						w = chunk.w,
						h = chunk.h,
						i = i
					}
				end
			end
		end	
	end
end

do -- caret movement
	local is_caret_move = {
		up = true,
		down = true,
		left = true,
		right = true,
		
		home = true,
		["end"] = true,
	} 
	
	function META:OnTextChanged(str)
		
	end
	  
	function META:InvalidateEditedText()		
		if self.text ~= self.last_text then
			self:OnTextChanged(self.text)
			self.last_text = self.text 
		end		
	end
	
	function META:DeleteSelectionX()
		if self.select_start and self.select_end then
		
			local modified = {}
			
			for i = self.select_start.i, self.select_end.i do
				local char = self.chars[i]
				local chunk = char.chunk
								
				if not modified[chunk] then
					modified[chunk] = {sub_start = char.data.i, chunk = chunk}
				end
				
				modified[chunk].sub_end = char.data.i				
			end
			 
			for k,v in pairs(modified) do
				if v.type == "string" then
					v.chunk.val = v.chunk.val:usub(1, v.sub_start - 1) .. v.chunk.val:usub(v.sub_end + 1) 
					if v.chunk.val == "" then
						self.chunks[v.chunk.i] = nil
					end
				else
					self.chunks[v.chunk.i] = nil
				end
			end
			
			table.fixindices(self.chunks)
			
			self:Invalidate()

			return true
		end

		return false
	end
 
	function META:GetSubPosFromPos(x, y)

		if x == math.huge and y == math.huge then
			return #self.chars
		end

		if x == 0 and y == 0 then
			return 0
		end

		for sub_pos, char in pairs(self.chars) do
			if char.x == x and char.y == y then
				return sub_pos
			end
		end

		return 0
	end
	 
	function META:DeleteSelection(skip_move)
		if self.select_start and self.select_end then
			local start_pos = self:GetSubPosFromPos(self.select_start.char.x, self.select_start.char.y)
			local end_pos = self:GetSubPosFromPos(self.select_end.char.x, self.select_end.char.y)
			
			if start_pos > end_pos then
				local temp = end_pos
				end_pos = start_pos
				start_pos = temp
				
				if not skip_move then
					self.caret_pos = self:CaretFromPos(self.select_end.char.x, self.select_end.char.y)
				end
			elseif not skip_move then
				self.caret_pos = self:CaretFromPos(self.select_start.char.x, self.select_start.char.y)
			end
			
			-- preserve the newline if it's at the end of the line
			if self.text:usub(end_pos,end_pos) == "\n" then
				end_pos = end_pos - 1
			end
			  
			self.text = self.text:usub(1, start_pos - 1) .. self.text:usub(end_pos + 1)

			self.select_start = nil
			self.select_end = nil
						
			self:InvalidateEditedText()
 
			return true
		end

		return false
	end
	
	function META:Unselect()
		self.select_start = nil
		self.select_end = nil
		self.caret_shift_pos = nil
	end

	function META:InsertString(str, skip_move) 
		local sub_pos = self:GetSubPosFromPos(self.caret_pos.char.x, self.caret_pos.char.y)

		self:DeleteSelection()

		if #self.text == 0 then
			self.text = self.text .. str
		elseif sub_pos == #self.text then
			self.text = self.text .. str
		else 
			self.text = self.text:usub(1, sub_pos - 1) .. str .. self.text:usub(sub_pos)
		end

		self:InvalidateEditedText()

		if not skip_move then
			local x = self.caret_pos.char.x + str:ulength()
			local y = self.caret_pos.char.y + str:count("\n")
			
			self.real_x = x
			
			self.caret_pos = self:CaretFromPos(x, y)
		end		
	end
	
	function META:FindNearestFromCaret(where)
		local line = self.lines[self.caret_pos.char.y]
		local pos = self.caret_pos.char.x
		local x
		
		if where == "right" then					
			-- if the next character is punctation, try to find punctation until the the last non punctation
			-- otherwise invert
			if line:sub(pos + 1, pos + 1):find("[^_%a%d]") then
				x = (select(2, line:find("[^_%a%d%s]+[_%a%d%s]", pos + 1)) or #line+1) - 1
			else
				x = (select(2, line:find("[_%a%d]-[^_%a%d]", pos + 1)) or #line+1) - 1
			end
			
			if line:sub(x+1, x+1):find("%s") then
				x = (select(2, line:sub(0, x+1):find("%s+", x)) or 1)
			end
				
			if x == pos then
				x = math.huge -- go to the next line
			end
		elseif where == "left" then		
			if line:sub(pos, pos) == "" then 
				x = 0 
			else
				if line:sub(pos, pos):find("[^_%a%d]") then
					x = (select(2, line:sub(0, pos - 1):find(".*[%a%d_]")) or 0)
				else
					x = (select(2, line:sub(0, pos - 1):find(".*[^%a%d_]")) or 0)
				end
			end
		end

		return x
	end
	
	function META:SetCaretPos(x, y)		
		self.caret_pos = self:CaretFromPos(x, y)
	end
	 
	 
	function META:OnMouseInput(button, press, x, y)	
		
		if button == "button_1" then
			if press then
				self.caret_pos = self.EditMode and self:CaretFromPixels(x, y) or nil 
				self.real_x = self.caret_pos and self.caret_pos.char.x or 0
				self.select_start = self:CaretFromPixels(x, y)
				self.select_end = nil
				self.mouse_selecting = true
			else
				if not self.EditMode and self.select_end then
					system.SetClipboard(self:GetSelectedString())
					self.select_end = nil
				end
				self.mouse_selecting = false
			end
		end
	end
	
	function META:OnKeyInput(key, press)  
	
		if not self.caret_pos then return end
		
		if key == "left_shift" then
			self.shift_select = press
		end
		
		if not press then return end
			
		local line = self.lines[self.caret_pos.char.y]
		local sub_pos = self:GetSubPosFromPos(self.caret_pos.char.x, self.caret_pos.char.y)
		
		local ctrl_down = input.IsKeyDown("left_control") or input.IsKeyDown("right_control")
				
		do -- special characters
			if key == "tab" then
				if self.select_start and self.select_end and self.select_start.char.y ~= self.select_end.char.y then
				
					-- first select everything
					self.select_start = self:CaretFromPos(0, self.select_start.char.y)
					self.select_end = self:CaretFromPos(math.huge, self.select_end.char.y)
					
					-- and move the caret to bottom
					self.caret_pos = self:CaretFromPos(self.select_end.char.x, self.select_end.char.y)
					
					local start_pos = self:GetSubPosFromPos(self.select_start.char.x, self.select_start.char.y)
					local end_pos = self:GetSubPosFromPos(self.select_end.char.x, self.select_end.char.y)
					 
					local text = self.text:usub(start_pos, end_pos)
					
					if input.IsKeyDown("left_shift") then 
						if text:sub(1, 1) == "\t" then
							text = text:sub(2)
						end
						text = text:gsub("\n\t", "\n")
					else
						text = "\t" .. text
						text = text:gsub("\n", "\n\t")
						
						-- ehhh, don't add \t at the next line.. 
						if text:sub(-1) == "\t" then
							text = text:sub(0, -2) 
						end
					end
					 
					self.text = self.text:usub(1, start_pos - 1) .. text .. self.text:usub(end_pos + 1)
				else
					
					-- TODO 
					if input.IsKeyDown("left_shift") and self.text:sub(sub_pos-1, sub_pos-1) == "\t" then
						local sub_pos = sub_pos - 1
						self.text = self.text:usub(1, sub_pos - 1) .. self.text:usub(sub_pos + 1)
						self:SetCaretPos(self.caret_pos.char.x - 1, self.caret_pos.char.y)
					else
						self:InsertString("\t")
					end
				end
			elseif key == "enter" then
			
				self:DeleteSelection(true)  
				
				local x = 0
				local y = self.caret_pos.char.y + 1
				
				-- if the next line already contains space in the beginning
				-- we replce the currents line space with it 
				local next_line = self.lines[y]				
				
				if next_line then				
					local cur_space = self.text:usub(sub_pos):match("^(%s+)")  
					local next_space = next_line:match("^(%s+)") 
					
					if next_space then   
					
						local space = next_space
					
						-- but if this lines indention is higher than the previous line
						-- we need to use its starting space instead
						
						local prev_line = self.lines[y - 1]
						if prev_line then
							local prev_space = prev_line:match("^(%s+)") 
							if prev_space and #prev_space > #space then
								space = prev_space
							end
						end
					
						if cur_space then 
							-- relace current space with next's space 
							-- "\t\tfoo| bar" -> "\t\tbar" 
							
							if  self.caret_pos.char.str == "\n" then
								self.text = self.text:usub(1, sub_pos) .. space .. cur_space .. self.text:usub(sub_pos + #cur_space)   
							else
								self.text = self.text:usub(1, sub_pos) .. "\n" .. space .. self.text:usub(sub_pos + #cur_space)
							end
							x = x + #space 

						else
							x = x + #space
							self.text = self.text:usub(1, sub_pos - #next_space) .. "\n" .. space .. self.text:usub(sub_pos - #next_space + 1) 
						end
					else
						self.text = self.text:usub(1, sub_pos - 1) .. "\n" .. self.text:usub(sub_pos)  
					end
				end
				
				self.real_x = x
				
				self:SetCaretPos(x, y)
			end
		end

		do -- clipboard
			if key == "c" and ctrl_down then 
				system.SetClipboard(self:GetSelectedString())
			elseif key == "x" and ctrl_down then
				system.SetClipboard(self:GetSelectedString())
				self:DeleteSelection()
			elseif key == "v" and ctrl_down then
				local str = system.GetClipboard()

				--str = str:gsub("\r", "\n")
				--str = str:gsub("\n\n", "\n")

				if #str > 0 then
					self:InsertString(str)
					
					self:InvalidateEditedText() 
					self:Invalidate()
					
					-- kinda hacky but move it back up again
					self:SetCaretPos(math.huge, self.caret_pos.char.y - 1)
				end
			end
		end
		
		do -- deletion
			if key == "backspace" then 
				local prev_line = self.lines[self.caret_pos.char.y - 1]
 
				if not self:DeleteSelection() then
					if ctrl_down then
						self.select_start = self:CaretFromPos(self.caret_pos.char.x - 1, self.caret_pos.char.y)
						self.select_end = self:CaretFromPos(self:FindNearestFromCaret("left"), self.caret_pos.char.y)
						self:DeleteSelection()
						
						if self.caret_pos.char.x <= 0 then
							local sub_pos = self:GetSubPosFromPos(math.huge, self.caret_pos.char.y - 1) 
							self.text = self.text:usub(1, sub_pos - 1) .. self.text:usub(sub_pos - 1) 
						end
						
						self.real_x = self.caret_pos.char.x - 1 
					else  
						self.text = self.text:usub(1, sub_pos - 2) .. self.text:usub(sub_pos) 
					
						if self.caret_pos.char.x <= 0 then
							self:SetCaretPos(math.huge, self.caret_pos.char.y - 1)
						else
							self:SetCaretPos(self.caret_pos.char.x - 1, self.caret_pos.char.y)
						end
						
						self.real_x = self.caret_pos.char.x   
					end					
				end

				self:InvalidateEditedText()
			elseif key == "delete" then

				if not self:DeleteSelection() then				
					if ctrl_down then 
						self.select_start = self:CaretFromPos(self.caret_pos.char.x, self.caret_pos.char.y)
						self.select_end = self:CaretFromPos(self:FindNearestFromCaret("right") - 1, self.caret_pos.char.y)
						self:DeleteSelection()
												
						if self.caret_pos.char.x >= #line then 
							local start_pos, end_pos = self.text:usub(sub_pos):find("%s*")
							
							if end_pos then
								self.text = self.text:usub(1, sub_pos - end_pos) .. self.text:usub(sub_pos + end_pos)  
							end
							
						end
					else
						self.text = self.text:usub(1, sub_pos - 1) .. self.text:usub(sub_pos + 1)  
					end
				end

				self:InvalidateEditedText()
			end 
		end
		
		do -- caret movement
			local x, y = self.caret_pos.char.x, self.caret_pos.char.y
			
			if key == "right" then
				if ctrl_down then
					x = self:FindNearestFromCaret("right")
				else
					x = x + 1
				end

				self.real_x = x
			elseif key == "left" then
				if ctrl_down then
					x = self:FindNearestFromCaret("left")
					
					if x <= 0 then
						y = y - 1
						local line = self.lines[y] or ""
						x = #line
					end
				else
					x = x - 1
				end

				self.real_x = x
			end

			if key == "up" then
				y = y - 1
				x = self.real_x
			elseif key == "down" then
				y = y + 1
				x = self.real_x
			end

			if key == "home" then
				local pos = (select(2, line:find("^%s+(.)")) or 1) - 1

				if x == pos then
					pos = 0
				end

				x = pos
				self.real_x = x
			elseif key == "end" then
				x = #line
				self.real_x = x
			end
			
			if key == "right" and x > #line then
				x = 0
				y = y + 1	
				
				if ctrl_down then
					local line = self.lines[self.caret_pos.char.y + 1] or ""
					
					x = (select(2, line:find("%s-%S", 0)) or 1) - 1
				end
			elseif key == "left" and x < 0 and y > 0 then
				x = #self.lines[self.caret_pos.char.y - 1]
				y = y - 1
			end

			self:SetCaretPos(x, y)
		end
				
		
		if is_caret_move[key] then
			if not input.IsKeyDown("left_shift") then
				self:Unselect()
			end
		end
		
		do -- other shortcuts
			if ctrl_down then
				if key == "a" then
					self.caret_pos = self:CaretFromPos(0, 1)
					self.select_start = self:CaretFromPos(0, 1)
					self.select_end = self:CaretFromPos(math.huge, math.huge)
					print(self.caret_pos, self.select_start, self.select_end)
				end
			end
		end
		
		self:InvalidateEditedText()
		
		if self.shift_select then
			if not self.caret_shift_pos then
				self.caret_shift_pos = self:CaretFromPos(self.caret_pos.char.x, self.caret_pos.char.y)
			end
			
			self.select_start = self:CaretFromPos(self.caret_shift_pos.char.x, self.caret_shift_pos.char.y)
			self.select_end = self:CaretFromPos(self.caret_pos.char.x, self.caret_pos.char.y)  
		else	
			self.caret_shift_pos = nil
		end
		
	end
end

function META:OnCharInput(char)
	self:InsertString(char)
end 

do -- drawing

	function META:Draw()
		if self.need_layout then
			self:Invalidate()
			self.need_layout = false
		end

		-- reset font and color for every line
		EXT.SetFont(self.fonts.default.name)
		EXT.SetColor(255, 255, 255, 255)
		EXT.SetColor(255, 255, 255, 255)

		local w, h = surface.GetScreenSize()
			
		for i, chunk in ipairs(self.chunks) do

			if chunk.x > w then break end
			if chunk.y > h then break end
			
			if chunk.type == "font" then
				EXT.SetFont(chunk.val)
			elseif chunk.type == "string" then
				EXT.SetTextPos(chunk.x, chunk.y)
				EXT.DrawText(chunk.val)			
			elseif chunk.type == "color" then
				local c = chunk.val
				
				EXT.SetColor(c.r, c.g, c.b, c.a)
			elseif chunk.type == "custom" and not chunk.stop then
				chunk.started = true
				call_tag_func(self, chunk, "draw", chunk.x, chunk.y)
			end
		end

		for _, chunk in ipairs(self.chunks) do
			if chunk.x > w then break end
			if chunk.y > h then break end
			
			if chunk.type == "custom" then
				if not chunk.stop and chunk.started and chunk.val.tag and chunk.val.tag.post then
					chunk.started = false
					call_tag_func(self, chunk, "post")
				end
			end
		end
		
		self:DrawSelection()
	end

	function META:DrawSelection() 

		if self.mouse_selecting then
			local caret = self:CaretFromPixels(window.GetMousePos():Unpack())
			if caret then
				self.select_end = caret
			end
		end
					
		local START = self.select_start
		local END = self.select_end
			
		if START and END then
		
			local START = START
			local END = END
			
			if START.i > END.i then
				START = self.select_end
				END = self.select_start
			end
					
			if START.i == END.i and not self.mouse_selecting and not self.shift_select then 
				self.select_end = nil 
			return end
			
			surface.SetWhiteTexture()
			surface.Color(1, 1, 1, 0.5)
			
			if self.EditMode then	
				for i = START.i, END.i do
					local char = self.chars[i]
					local data = char.data
					surface.DrawRect(data.x, data.y, data.w, data.h) 
				end
			else			
				for i, chunk in ipairs(self.chunks) do
					if START.char and END.char and START.i == END.i then
						for i, char in ipairs(START.char.chunk.chars) do
							if i >= START.char.i and i <= END.char.i then
								surface.DrawRect(char.x, char.y, char.w, char.h)
							end
						end
						break
					else		
						if i == START.i then
							if START.char then
								for i, char in ipairs(START.char.chunk.chars) do
									if i >= START.char.i then
										surface.DrawRect(char.x, char.y, char.w, char.h)
									end
								end
							else
								surface.DrawRect(chunk.x, chunk.y, chunk.w, chunk.h)
							end
						elseif i == END.i then	
							if END.char then
								for i, char in ipairs(END.char.chunk.chars) do
									if i < END.char.i then
										surface.DrawRect(char.x, char.y, char.w, char.h)
									end
								end
							else
								surface.DrawRect(chunk.x, chunk.y, chunk.w, chunk.h)
							end
						elseif i > START.i and i <= END.i and START.i ~= END.i then
							surface.DrawRect(chunk.x, chunk.y, chunk.w, chunk.h)
						end
					end
				end
			end
		else	
			if self.caret_pos then
				surface.Color(1,1,1,timer.GetTime()%0.5 > 0.25 and 1 or 0)
				surface.DrawRect(self.caret_pos.x, self.caret_pos.y, 2, self.caret_pos.h)
			end
		end
	end

end


include("tests/markup.lua")  