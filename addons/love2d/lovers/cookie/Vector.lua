local VecObj = {}
VecObj.__index = VecObj

function Vector( x, y )
	local t = {}
	setmetatable( t, VecObj )
	t.x = x
	t.y = y
	return t
end

function VecObj:__mul( v )
	if( type( v ) == "table" ) then
		return Vector( self.x * v.x, self.y * v.y )
	elseif( type( v ) == "number" ) then
		return Vector( self.x * v, self.y * v )
	end
	return self
end

function VecObj:__div( v )
	if( type( v ) == "table" ) then
		return Vector( self.x / v.x, self.y / v.y )
	elseif( type( v ) == "number" ) then
		return Vector( self.x / v, self.y / v )
	end
	return self
end

function VecObj:__add( v )
	if( type( v ) == "table" ) then
		return Vector( self.x + v.x, self.y + v.y )
	elseif( type( v ) == "number" ) then
		return Vector( self.x + v, self.y + v )
	end
	return self
end

function VecObj:__sub( v )
	if( type( v ) == "table" ) then
		return Vector( self.x - v.x, self.y - v.y )
	elseif( type( v ) == "number" ) then
		return Vector( self.x - v, self.y - v )
	end
	return self
end

function VecObj:__len( v )
	return math.sqrt(self.x^2 + self.y^2)
end

function VecObj:__tostring()
	return math.floor( self.x * 1000 ) / 1000 .. ", " .. math.floor( self.y * 1000 ) / 1000
end

function VecObj:Distance( v )
	return math.sqrt( (self.x - v.x)^2 + (self.y - v.y)^2 )
end

function VecObj:Normalize()
	local l = self:__len()
	return Vector( self.x / l, self.y / l )
end

function VecObj:Angle()
	return math.deg( math.atan2( self.y, self.x ) )
end

function VecObj:Rotate( d )
	local d = d + self:Angle()
	return Vector( math.cos( math.rad( d ) ), math.sin( math.rad( d ) ) )
end

function VecObj:RotateAroundPoint( V, d )
	local L = self:Distance( V )
	return V + ((self-V):Normalize():Rotate( d ) * L)
end

function VecObj:Unpack()
	return self.x, self.y
end