local META = (...) or prototype.GetRegistered("markup")

local function set_cull_clockwise()
	-- ???
end

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

local function orthonormalM2x2ToVMatrix(m11, m12, m21, m22)
	local det = detM2x2(m11, m12, m21, m22)

	if det < 0 then
		surface.Scale(1, -1)
	end

	local angle = math.atan2 (m21, m11)
	surface.Rotate(math.deg(angle))
end

META.tags.translate =
{
	arguments = {0, 0},

	pre_draw = function(markup, self, x, y, dx, dy)
		surface.PushMatrix()

		surface.Translate(dx, dy)


	end,

	post_draw = function()
		surface.PopMatrix()
	end,
}

META.tags.scale =
{
	arguments = {1, 1},

	init = function()

	end,

	pre_draw = function(markup, self, x, y, scaleX, scaleY)
		surface.PushMatrix()

		self.matrixDeterminant = scaleX * scaleY

		if math.abs (self.matrixDeterminant) > 10 then
			scaleX, scaleY = normalizeV2(scaleX, scaleY)
			scaleX, scaleY = scaleV2(scaleX, scaleY, 10)
		end

		local centerY = y - self.tag_height / 2

		surface.Translate(x, centerY)
			surface.Scale(scaleX, scaleY)

			if scaleX < 0 then
				surface.Translate(-self.tag_width, 0)
			end
		surface.Translate(-x, -centerY)



		set_cull_clockwise(self.matrixDeterminant < 0)
	end,

	post_draw = function(markup, self)
		if self.matrixDeterminant < 0 then
			set_cull_clockwise(false)
		end

		surface.PopMatrix()
	end,
}

META.tags.size =
{
	arguments = {1},

	pre_draw = function(markup, self, x, y, size)
		markup.tags.scale.pre_draw(markup, self, x, y, size, size)
	end,

	post_draw = function(markup, self)
		markup.tags.scale.post_draw(markup, self)
	end,
}

META.tags.rotate =
{
	arguments = {45},

	pre_draw = function(markup, self, x, y, deg)
		surface.PushMatrix()

		local center_x = self.tag_center_x
		local center_y = self.tag_center_y

		surface.Translate(center_x, center_y)
			surface.Rotate(math.rad(deg))
		surface.Translate(-center_x, -center_y)


	end,

	post_draw = function()
		surface.PopMatrix()
	end,
}

META.tags.matrixez =
{
	arguments = {0,0,1,1,0},

	pre_draw = function(markup, self, x, y, X, Y, scaleX, scaleY, angleInDegrees)
		self.matrixDeterminant = scaleX * scaleY

		if math.abs (self.matrixDeterminant) > 10 then
			scaleX, scaleY = normalizeV2(scaleX, scaleY)
			scaleX, scaleY = scaleV2(scaleX, scaleY, 10)
		end

		local centerX = self.tag_center_x
		local centerY = self.tag_center_y

		surface.PushMatrix()

		surface.Translate(x, centerY)
			surface.Translate(X,Y)
			surface.Scale(scaleX, scaleY)
			if scaleX < 0 then
				surface.Translate(-self.tag_width, 0)
			end
			if angleInDegrees ~= 0 then
				surface.Translate(centerX)
					surface.Rotate(angleInDegrees)
				surface.Translate(-centerX)
			end
		surface.Translate(x, -centerY)



		set_cull_clockwise(self.matrixDeterminant < 0)
	end,

	post_draw = function(markup, self)
		if self.matrixDeterminant < 0 then
			set_cull_clockwise(false)
		end

		surface.PopMatrix()
	end,
}

META.tags.matrix =
{
	arguments = {1, 0, 0, 1, 0, 0},

	pre_draw = function(markup, self, x, y, a11, a12, a21, a22, dx, dy)
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

		surface.PushMatrix()

		surface.Translate(x, y)
			surface.Translate(dx, dy)

			orthonormalM2x2ToVMatrix(q211, q212, q221, q222)
				surface.Scale(scaleX, scaleY)
			orthonormalM2x2ToVMatrix(q111, q112, q121, q122)

		surface.Translate(-x, -y)



		set_cull_clockwise(self.matrixDeterminant < 0)
	end,

	post_draw = function(markup, self)
		if self.matrixDeterminant < 0 then
			set_cull_clockwise(false)
		end

		surface.PopMatrix()
	end,
}

prototype.UpdateObjects(META)