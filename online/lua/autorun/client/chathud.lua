if SERVER then return end

setfenv(1, _G)

-- sorry but I use this somewhere else as well
-- don't worry too much about using EXT if you're not sure how
-- I can fix your mistakes

local EXT -- EXT for external 
local GMOD = gmod ~= nil

-- these are used by EXT.SetColor, EXT.SetFont etc
local FONT = "chathud"
local R, G, B, A = 255, 255, 255, 255
local X, Y = 0, 0
local C -- shortcut for config

if GMOD then
	local TEMP_CLR = Color(R,G,B,A)
	local TEMP_VEC = Vector(0, 0, 0)
	local TEMP_ANG = Angle(0, 0, 0)

	local white = Material("vgui/white")
	
	EXT = {
		Rand = math.Rand,
		FormatPrint = function(fmt, ...) MsgN(string.format(fmt, ...)) end,
		GetFrameTime = FrameTime,
		GetTime = RealTime,
		LoadString = function(str) 
			local func = CompileString(str, "chathud_expression", false)
			if type(func) == "string" then
				return false, func
			end
			return func
		end,
		
		CreateConVar = function(name, def) return CreateClientConVar(name, tostring(def), true, false) end,
		GetConVarFloat = function(c) return c:GetFloat() end,
		
		HSVToColor = function(h,s,v) local c = HSVToColor(h%360, s, v) return c.r, c.g, c.b end,
		SetMaterial = function(mat) surface.SetMaterial(mat or white) end,
		SetColor = function(r,g,b,a) R=r G=g B=b A=a or 255 surface.SetTextColor(R,G,B,A) surface.SetDrawColor(R,G,B,A) end,
		DrawRect = surface.DrawTexturedRect,
		DrawText = function(str) 
			if FONT == chathud.fonts.default.name and surface.DrawPrettyText then 
				
				local data = chathud.fonts.default.data
				
				TEMP_CLR.r = R
				TEMP_CLR.g = G
				TEMP_CLR.b = B
				TEMP_CLR.a = A
				
				surface.DrawPrettyText(str, X, Y, data.font, data.size, data.weight, data.blursize, TEMP_CLR)
			else
				surface.DrawText(str)
			end
		end,
		SetTextPos = function(x, y) X=x Y=y surface.SetTextPos(x,y) end,
		SetFont = function(str)
			
			str = chathud.font_translate[str] or str
		
			if not pcall(surface.SetFont, str) then
				str = chathud.fonts.default.name
				FONT = str
				surface.SetFont(str) 
			else
				FONT = str				
			end
		end,
		GetTextSize = surface.GetTextSize,
		SetAlphaMultiplier = surface.SetAlphaMultiplier,	
		GetScreenHeight = ScrH,
		GetScreenWidth = ScrW,
		
		SetCullClockWise = function(b) render.CullMode(b and MATERIAL_CULLMODE_CW or MATERIAL_CULLMODE_CCW) end,
		FindMaterial = function(path)			
			if _G.pac and path:find("http") then
				local mat = CreateMaterial("chathud_texture_tag" .. util.CRC(path) .. "_" .. FrameNumber(), "UnlitGeneric", {})

				pac.urltex.GetMaterialFromURL(path, function(_mat)
					mat:SetTexture("$basetexture", _mat:GetTexture("$basetexture"))
				end, nil, "UnlitGeneric", size, false)

				mat:SetFloat("$alpha", 0.999)
			
				return mat
			else
				local mat = Material(path)
				local shader = mat:GetShader()
				
				if shader == "VertexLitGeneric" or shader == "Cable" then
					local tex_path = mat:GetString("$basetexture")
					
					if tex_path then
						local params = {}
						
						params["$basetexture"] = tex_path
						params["$vertexcolor"] = 1
						params["$vertexalpha"] = 1
						
						mat = CreateMaterial("markup_fixmat_" .. tex_path, "UnlitGeneric", params)
					end	
				end

				return mat
			end
		end,
				
		CreateMatrix = Matrix,
		
		TranslateMatrix = function(m, x, y, z) TEMP_VEC.x=x or 0 TEMP_VEC.y=y or 0 m:Translate(TEMP_VEC) end,
		ScaleMatrix = function(m, x, y, z) TEMP_VEC.x=x or 0 TEMP_VEC.y=y or 0 m:Scale(TEMP_VEC) end,
		RotateMatrix = function(m, a) TEMP_ANG.y=a or 0 m:Rotate(TEMP_ANG) end,
		
		PushMatrix = cam.PushModelMatrix,
		PopMatrix = cam.PopModelMatrix,
	}
else
	EXT = {
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
			if G>1 then R=G/255 end 
			if B>1 then R=B/255 end 
			if A>1 then R=A/255 end 
			
			surface.Color(R,G,B,A) 
		end,
		DrawRect = surface.DrawRect,
		DrawText = surface.DrawText,
		SetTextPos = function(x, y) X=x Y=y surface.SetTextPos(x,y) end,
		SetFont = function(str)			
			str = chathud.font_translate[str] or str
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
end

-- config start

chathud = { 
	font_translate = {
		-- usage
		-- chathud.font_translate.chathud_default = "my_font"
		-- to override fonts
	},
	config = {
		max_width = 500,
		max_height = 1200,
		height_spacing = 3,
		history_life = 20,
		
		extras = {
			["...."] = {type = "font", val = "DefaultFixed"},
			["!!!!"] = {type = "font", val = "Trebuchet24"},
			["!!!!!11"] = {type = "font", val = "DermaLarge"},
		},
		
		smiley_translate =
		{
			v = "vee",
		},	

		shortcuts = {		
			smug = "<texture=masks/smug>",
			downs = "<texture=masks/downs>",
			saddowns = "<texture=masks/saddowns>",
			niggly = "<texture=masks/niggly>",
			colbert = "<texture=masks/colbert>",
			eli = "<texture=models/eli/eli_tex4z,4>",
			grin = "<rotate=90>:D<rotate=-90>",
		}
		
	},
	
	fonts = {
		default = {
			name = "chathud_default",
			data = {
				font = "DejaVu Sans",
				size = 14,
				antialias = true,
				outline = false,
				weight = 580, 
			} ,
		},
		
		chatprint = {
			name = "chathud_chatprint",
			color = Color(201, 255, 41, 255),
			data = {
				font = "Verdana",
				size = 16,
				weight = 600,
				antialias = true,
				shadow = true,
			},
		},
	},		
	
	tags = {
		hsv =
		{
			arguments = {0, 1, 1},
			
			draw = function(self, x,y,a, h, s, v)
				local r,g,b = EXT.HSVToColor(h, s, v)
				EXT.SetColor(r, g, b, 255)
				EXT.SetColor(r, g, b, 255)
			end,
		},
		
		color =
		{
			arguments = {255, 255, 255, 255},
			
			draw = function(self, x,y,a, r,g,b,a)
				EXT.SetColor(r, g, b, a)
				EXT.SetColor(r, g, b, a)
			end,
		},

		physics =
		{
			annoying = true,
			
			arguments = {1, 0, 0, 0, 0.99, 0.1},
			
			pre = function(self, gx, gy, vx, vy, drag, rand_mult)
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
			
			draw = function(self, x,y,a, gravity_y, gravity_x, vx, vy, drag, rand_mult)
				local delta = EXT.GetFrameTime() * 5
				
				local part = self.part
				
				local cx = x
				local cy = y - 10
				
				local W, H = C.max_width/2, EXT.GetScreenHeight()
				
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
		},
		
		font =
		{
			annoying = true,
			
			arguments = {"chathud_default"},
			
			draw = function(self, x,y,a, font)
				EXT.SetFont(font)
			end,
			
			pre = function(self, font)
				EXT.SetFont(font)
			end,
		},
		
		texture =
		{		
			arguments = {"error", {default = 1, min = 1, max = 4}},
			
			pre = function(self, path)
				self.mat = EXT.FindMaterial(path)
			end,

			get_size = function(self, path, size_mult)
				return 16 * size_mult, 16 * size_mult
			end,
			
			draw = function(self, x,y,a, path)
				EXT.SetMaterial(self.mat)
				EXT.DrawRect(x, y, self.w, self.h)
			end,
		},
	}
}


do -- matrix tag
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

	chathud.tags.translate =
	{
		annoying = true,
		arguments = {0, 0},
		
		draw = function(self, x, y, a, dx, dy)
			local mat = EXT.CreateMatrix()
			EXT.TranslateMatrix(mat, dx, dy)
			
			EXT.PushMatrix(mat)
		end,
		
		post = function()
			EXT.PopMatrix()
		end,
	}
	
	chathud.tags.scale =
	{
		annoying = true,
		arguments = {1, nil},
		
		draw = function(self, x, y, a, scaleX, scaleY)
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
		
		post = function(self)
			if self.matrixDeterminant < 0 then
				EXT.SetCullClockWise(false)
			end
			
			EXT.PopMatrix()
		end,
	}
	
	chathud.tags.rotate =
	{
		annoying = true,
		arguments = {0},
		
		draw = function(self, x, y, a, angleInDegrees)
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

	chathud.tags.matrixez =
	{
		annoying = true,
		arguments = {0,0,1,1,0},
		
		draw = function(self, x, y, a, X, Y, scaleX, scaleY, angleInDegrees)
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
		
		post = function(self)
			if self.matrixDeterminant < 0 then
				EXT.SetCullClockWise(false)
			end
			
			EXT.PopMatrix()
		end,
	}
	
	chathud.tags.matrix =
	{
		annoying = true,
		
		arguments = {1, 0, 0, 1, 0, 0},
		
		draw = function(self, x, y, a, a11, a12, a21, a22, dx, dy)
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
		
		post = function(self)
			if self.matrixDeterminant < 0 then
				EXT.SetCullClockWise(false)
			end
			
			EXT.PopMatrix()
		end,
	}
end

-- internal

C = chathud.config

local history = {}
local variables = {}
local time_speed = 1
local time_offset = 0

local height_mult = EXT.CreateConVar("cl_chathud_height_mult", 0.76)
local width_mult = EXT.CreateConVar("cl_chathud_width_mult", 0.3)


local panic = false

do -- expression
	-- used like <tag=[pi * rand()]>
	
	local lib =
	{
		PI = math.pi,
		pi = math.pi,
		rand = math.random,
		random = math.random,
		randx = function(a,b)
			a = a or -1
			b = b or 1
			return EXT.Rand(a, b)
		end,
		
		abs = math.abs,
		sgn = function (x)
			if x < 0 then return -1 end
			if x > 0 then return  1 end
			return 0
		end,
		
		acos = math.acos,
		asin = math.asin,
		atan = math.atan,
		atan2 = math.atan2,
		ceil = math.ceil,
		cos = math.cos,
		cosh = math.cosh,
		deg = math.deg,
		exp = math.exp,
		floor = math.floor,
		frexp = math.frexp,
		ldexp = math.ldexp,
		log = math.log,
		log10 = math.log10,
		max = math.max,
		min = math.min,
		rad = math.rad,
		sin = math.sin,
		sinc = function (x)
			if x == 0 then return 1 end
			return math.sin(x) / x
		end,
		sinh = math.sinh,
		sqrt = math.sqrt,
		tanh = math.tanh,
		tan = math.tan,
		
		clamp = math.Clamp,
		pow = math.pow
	}

	local blacklist = {"repeat", "until", "function", "end"}

	local expressions = {}

	function chathud.CompileExpression(str, extra_lib)
		local source = str

		for _, word in pairs(blacklist) do
			if str:find("[%p%s]" .. word) or str:find(word .. "[%p%s]") then
				return false, string.format("illegal characters used %q", word)
			end
		end
		
		local functions = {}
		
		for k,v in pairs(lib) do functions[k] = v end
		
		if extra_lib then
			for k,v in pairs(extra_lib) do functions[k] = v end
		end
		
		local t0 = EXT.GetTime()
		functions.t    = function () return EXT.GetTime() - t0 end
		functions.time = function () return EXT.GetTime() - t0 end
		functions.select = select
		
		str = "local input = select(1, ...) return " .. str
		
		local func, err = EXT.LoadString(str)
		
		if func then
			setfenv(func, functions)
			expressions[func] = source
			return true, func
		else
			return false, err
		end
	end
end

local function split_text(str, maxwide)
	local lines = {}
	local pos = 0
	local last_pos = 0
	local wide = 0
	local found = false
	
	local space_pos
	
	for char in str:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
		pos = pos + #char
		
		local w, h = EXT.GetTextSize(char == "&" and "%" or char)
		
		w = w or 0
		h = h or 0
		
		if char == " " then
			space_pos = pos
		end

		if wide + w >= maxwide then
			if space_pos then
				table.insert(lines, str:sub(last_pos+1, space_pos))
				last_pos = space_pos
			else
				table.insert(lines, str:sub(last_pos+1, pos))
				last_pos = pos
			end
			
			wide = 0
			found = true
			space_pos = nil
		else
			wide = wide + w
		end
    end
	
	if found then
		table.insert(lines, str:sub(last_pos+1, pos))
	else
		table.insert(lines, str)
	end
	
	return lines
end

local function run_tag(line, name, ...)
	if not line.val.tag then return end
	
	if line.type == "custom" then
		
		if not chathud.CanRunAnnoyingTags() then
			return
		end
	
		local func = line.val.tag and line.val.tag[name]
		
		if func then		
			local sigh = {line, ...}
			for k,v in pairs(line.val.args) do
				if type(v) == "function" then
					local ok, val = pcall(v, line.exp_env)
					if ok and val then
						v = val
					else
						v = line.val.tag.arguments[k]
						if type(v) == "table" then
							v = v.default
						end
					end
				end
				table.insert(sigh, v)
			end
			
			local args = {pcall(func, unpack(sigh))}
			
			if not args[1] then
				history = {}
				EXT.FormatPrint("tag error %s", args[2])
			else
				return select(2, unpack(args))
			end
		end
	end
end

local function parse_tag_arguments(str)
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
			local ok, func = chathud.CompileExpression(expressions[arg])
			if func then
				table.insert(out, func)
			else
				EXT.FormatPrint("chathud expression error: %s", func)
				table.insert(out, 0)
			end
		else
			table.insert(out, arg)
		end
	end
	
	return out
end

local function to_markup(str)
	local data = {}
	local found = false
	
	local in_tag = false
	local current_string = {}
	local current_tag = {}
	
	-- just used for <r>
	local tags = {}
	
	for i = 0, #str do
		local char = string.sub(str, i, i)
		
		if char == "<" then
			if current_string then
				table.insert(data, table.concat(current_string, ""))
			end
			
			current_tag = {}
			in_tag = true
		elseif char == ">" and in_tag then
			if current_tag then
				local input = table.concat(current_tag, "") .. ">"
				local tag, args = input:match("<(.-)[=?](.+)>")
								
				local info = chathud.tags[tag]
				
				if info then				
					local args = parse_tag_arguments(args or "")
					
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
					
					local tag = {tag = info, type = tag, args = args}
					table.insert(data, tag)
					
					-- for special tags
					table.insert(tags, tag)
				else
					if tag == "repeat" or tag == "r" then
						local args = parse_tag_arguments(args or "")
						local count = tonumber(args[1]) or 1
						
						for i = 0, count - 1 do
							local last = tags[#tags - i]
							if last then
								table.insert(data, last)
							else
								break
							end
						end
						
						found = true
					elseif (tag == "variable" or tag == "var" or tag == "v") and args then
						local args = parse_tag_arguments(args)
						local set = variables[args[1]]
						
						if set then
							for k,v in pairs(set) do
								table.insert(data, v)
							end
							found = true
						end
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
		table.insert(data, table.concat(current_string, ""))
	else
		data = {str}
	end
	
	return data
end

local function add_markup(markup)	
	C.max_width = EXT.GetScreenWidth() * EXT.GetConVarFloat(width_mult)
	C.max_height = EXT.GetScreenHeight() * EXT.GetConVarFloat(height_mult)
	
	markup.life_time = EXT.GetTime() + C.history_life
	table.insert(history, 1, markup)
end

do
	-- this converts chat.AddText to our markup language

	-- just for readability really

	local function is_color(var)
		return GMOD and var.r and var.g and var.b
	end

	local function is_font(var)
		return #var == 1 and type(var[1]) == "string"
	end

	function chathud.AddText(...)
		
		local args = {...}
		
		if panic then
			panic = false
		end
		
		local is_maybe_player_chat = false
		
		-- preprocess :something: to <texture=something>
		for k,v in pairs(args) do
			if type(v) == "string" then
				for _k, _v in pairs(C.smiley_translate) do
					v = v:gsub(":" .. _k .. ":", ":" .. _v .. ":")
				end
				args[k] = v:gsub("(:[%w_]-:)", function(str)
					str = str:sub(2, -2)
					
					if variables[str] then
						return "<v=" .. str .. ">"
					end
					
					if C.shortcuts[str] then
						return C.shortcuts[str]
					end
				end)
			end
		end

		-- normalize everything into a consistent markup table
		-- strings are also parsed
		local markup = {}
		
		for i, var in pairs(args) do
			local t = type(var)
			
			if not GMOD then
				local t = typex(var)
				
				if t == "color" then
					table.insert(markup, {type = "color", val = var})
				elseif t == "player" then
					table.insert(markup, {type = "color", val = var:GetUniqueColor()})
					table.insert(markup, {type = "string", val = var:GetNick()}) 
					table.insert(markup, {type = "color", val = Color(1,1,1,1)})
				end
			end
			
			if t == "Player" then
				table.insert(markup, {type = "color", val = team.GetColor(var:Team())})
				table.insert(markup, {type = "string", val = var:Name()})
				table.insert(markup, {type = "color", val = color_white})
				
				is_maybe_player_chat = true
			elseif t == "string" then
				if var:sub(1, 2) == ": " then
					is_maybe_player_chat = true
				end
				
				if is_maybe_player_chat and (var == ": sh" or var:find("%ssh%s")) then
					panic = true
				end
				
				for i, var in pairs(to_markup(var)) do
					if type(var) == "string"  then
						table.insert(markup, {type = "string", val = var})
					else
						table.insert(markup, {type = "custom", val = var})
					end
				end
				
			elseif t == "table" then
				if is_color(var) then
					table.insert(markup, {type = "color", val = var})
				elseif is_font(var) then
					table.insert(markup, {type = "font", val = var[1]})
				end
			elseif t ~= "cdata" then
				EXT.FormatPrint("tried to parse unknown type %q", t)
			end

		end
		
		-- concatenate all repeated strings to properly work with with splitting and better performance
		local concatenated = {}
		local last_data = {}
		
		for i, data in pairs(markup) do
			
			if not (data.type == "color" and markup[i+1] and markup[i+1].type == "color")  then
				if last_data.type == "string" and data.type == "string" then
					last_data.val = last_data.val .. data.val
				else
					table.insert(concatenated, data)
					last_data = data
				end
			end
		end
		
		for find, add in pairs(C.extras) do
			for i, data in pairs(concatenated) do
				if data.type == "string" and data.val:find(find, nil, true) then
					
					table.insert(concatenated, 1, add)
					return
				end
			end
		end
		
		EXT.SetFont(chathud.fonts.default.name)
		
		-- get the size of each object
		local temp = {}
		
		for i, data in pairs(concatenated) do
			if data.type == "font" then
				EXT.SetFont(data.val)
			elseif data.type == "string" then
				-- this really should be done in the previous loop..
				for _, str in pairs(split_text(data.val, C.max_width)) do
					local w, h = EXT.GetTextSize(str)
					table.insert(temp, {type = "string", val = str, w = w, h = h, x = 0, y = 0})
				end
				
				goto NEXT
			elseif data.type == "custom" then
				local info = data.val.tag
				
				local w, h = run_tag(data, "get_size")
				data.w = w
				data.h = h
				
				run_tag(data, "pre")
			end
			
			-- for consistency sake everything should have x y w h
			data.x = data.x or 0
			data.y = data.y or 0
			data.w = data.w or 0
			data.h = data.h or 0
			
			table.insert(temp, data)
			
			::NEXT::
		end
		
		-- split it up if needed
		
		local markup = {w = 0, h = 0, data = {}}
		
		local y = 0
		
		local width = 0
		
		local split = false
		local line_height = 0
		
		for i, data in pairs(temp) do
			data.x = width
			data.y = y
			
			width = width + data.w

			-- figure out how tall this line is
			if data.h > line_height then
				line_height = data.h
			end
			
			if width + data.w >= C.max_width and i ~= #temp then
				y = y + line_height
				
				if width > markup.w then
					markup.w = width
				end
				
				width = 0
				split = true
				
				markup.h = markup.h + line_height
			end
			
			table.insert(markup.data, data)
		end
					
		if not split then
			markup.w = width
			markup.h = line_height
			
			for i, data in pairs(markup.data) do
				data.y = line_height - data.h
			end
		else
			markup.h = markup.h + line_height
		end
		
		-- this is for expressions to be use d like line.i+time()
		for i, data in pairs(markup.data) do
			data.exp_env = { i = i, w = data.w, h = data.h, x = data.x, y = data.y, rand = math.random() }
		end
		
		-- build linked list
		local prev = nil
		for _, data in ipairs(markup.data) do
			if prev then 
				prev.next = data 
			end
			prev = data
		end
		
		for i, data in pairs(markup.data) do
			local w = 0
			local h = 0
			local node = data.next
			while node do
				w = w + node.w
				h = math.max (h, node.h)
				node = node.next
			end
			
			data.message_width = w
			data.message_height = h				
		end
		
		markup.h = markup.h + C.height_spacing
			
		add_markup(markup)
	end
end	

function chathud.Draw()
	local history_x = 45
	local history_y = C.max_height
	
	for i, markup in pairs(history) do
		history_y = history_y - markup.h
		local alpha = math.min(math.max(markup.life_time - EXT.GetTime(), 0), 1) ^ 5
				
		-- reset font and color for every line
		EXT.SetAlphaMultiplier(alpha)
		EXT.SetFont(chathud.fonts.default.name)
		EXT.SetColor(255, 255, 255, 255)
		EXT.SetColor(255, 255, 255, 255)
				
		for _, data in pairs(markup.data) do
			local x = history_x + data.x
			local y = history_y + data.y
			
			if y > 0 and x > 0 then 						
				if data.type == "font" then
					EXT.SetFont(data.val)
				elseif data.type == "string" then
					EXT.SetTextPos(x, y)
					EXT.DrawText(data.val)
				elseif data.type == "color" then
					local c = data.val
					
					EXT.SetColor(c.r, c.g, c.b, c.a * alpha)
				elseif data.type == "custom" and not data.stop then
					data.started = true
					run_tag(data, "draw", x, y, alpha)
				end
			end
		end
		
		for _, data in pairs(markup.data) do
			if data.type == "custom" then
				if not data.stop and data.started and data.val.tag and data.val.tag.post then
					data.started = false
					run_tag(data, "post")
				end
				
				if panic then
					data.stop = true
				end
			end
		end
		
		if alpha == 0 then
			table.remove(history, i)
		end
	end
	
	EXT.SetAlphaMultiplier(1)	
end

function chathud.GetPlayer()
	return chathud.current_player or NULL
end

if GMOD then

	for name, data in pairs(chathud.fonts) do
		surface.CreateFont(data.name, data.data)
	end
	
	if surface.DrawFlag then
		chathud.tags.flag =
		{		
			arguments = {"gb"},
			
			draw = function(self, x,y,a, flag)
				surface.DrawFlag(flag, x, y-12)
			end,
		}
	end

	for _, v in pairs(file.Find("materials/icon16/*.png", "GAME")) do
		C.shortcuts[v:gsub("(%.png)$","")] = "<texture=materials/icon16/" .. v .. ">"
	end
	
	function chathud.CanRunAnnoyingTags()
		local you = LocalPlayer()
		local him = chathud.GetPlayer()
		
		return 
			not (
				him:IsValid() and 
				him.IsFriend and 
				you ~= chathud.GetPlayer() and 
				not you:IsFriend(him) 
			)
	end
	
	do 
		-- kinda hacky but it should work
		hook.Add("PlayerSay", "chathud", function(ply)
			chathud.current_player = ply
			timer.Simple(0, function() chathud.current_player = NULL end)
		end)
		hook.Add("OnPlayerChat", "chathud", function(ply)
			chathud.current_player = ply
			timer.Simple(0, function() chathud.current_player = NULL end)
		end)
	end
	
	hook.Add("ChatText", "chathud", function(_, _, msg)
		chathud.AddText(
			{chathud.fonts.chatprint.name}, 
			chathud.fonts.chatprint.color, 
			tostring(msg)
		)
	end)

	local chathud_show = EXT.CreateConVar("cl_chathud_show", 1)

	hook.Add("HUDShouldDraw", "chathud", function(name)
		if name == "CHudChat" and chathud_show:GetBool() then
			return false
		end
	end)
	
	hook.Add("HUDPaint", "chathud", function()
		if chathud_show:GetBool() then
			chathud.Draw()
		end
	end)
	hook.Add("HUDShouldDraw", "chathud", function(name)
		if name == "CHudChat" and chathud_show:GetBool() then
			return false
		end
	end)
	
	hook.Add("HUDPaint", "chathud", function()
		if chathud_show:GetBool() then
			chathud.Draw()
		end
	end)
	
	-- NEED: lua/includes/extensions/chat_addtext_hack.lua
	_G.PrimaryChatAddText = chathud.AddText
	chat.AddTextX = chathud.AddText
else
	function chathud.CanRunAnnoyingTags()
		return true
	end
	
	event.AddListener("PreDrawMenu", "chathud", function()
		chathud.Draw()
	end)
end