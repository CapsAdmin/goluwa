local LineObj = {}
LineObj.__index = LineObj

function Line( A, B, C )
	local t = setmetatable( {}, LineObj )
	t.A = A
	t.B = B
	t.Color = C or {255,255,255,255}
	return t
end

function LineObj:SetA( V )
	self.A = V
end

function LineObj:SetB( V )
	self.B = V
end

function LineObj:SetPoints( A, B )
	self.A = A
	self.B = B
end

function LineObj:Intersects( L )
	local A1 = self.A
	local A2 = self.B
	local B1 = L.A
	local B2 = L.B

	local An = (A2 - A1):Normalize()
	local Bn = (B2 - B1):Normalize()
	
	-- If the lines are parallel return false.
	if( An.x == Bn.x ) then return false end
	
	local Ad = A2:Distance(A1)
	local Bd = B2:Distance(B1)
	
	local Aa = An:Angle()
	
	local Offset = A1
	A1 = Vector( 0, 0 )
	A2 = A2 - Offset
	B1 = B1 - Offset
	B2 = B2 - Offset
	
	if( Aa ~= 0 ) then
		B1 = B1:RotateAroundPoint( Vector( 0, 0 ), -Aa )
		B2 = B2:RotateAroundPoint( Vector( 0, 0 ), -Aa )
		
		-- If both of these points are on the same side of the x axis, then there's no way they'll intersect.
		if( (B1.y < 0) == (B2.y < 0) ) then
			return false
		end
		
		Bn = (B2-B1):Normalize()
		A2 = Vector( Ad, 0 )
	end
	
	-- Figure out where line B intersects with A(the x-axis)
	C = B1 + (Bn*math.min(Bd,(B1.y/-Bn.y)+.1))

	-- Make sure the point where line B intersects with the x-axis is not beyond the length of A.
	if( C.x < Ad and C.x > 0 and (B1.y < 0) ~= (C.y < 0) ) then
		return true, Offset + (An*C.x)
	end
	return false
end

--[[
if( love ) then
	function LineObj:Draw()
		love.graphics.setColor( unpack( self.Color ) )
		love.graphics.line( self.A.x, self.A.y, self.B.x, self.B.y )
	end
end
]]--
