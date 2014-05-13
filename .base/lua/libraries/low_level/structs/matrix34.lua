local META = {}

META.ClassName = "matrix34"

META.NumberType = "float"
META.Args = 
{
	"m00", "m01", "m02", "m03",
	"m10", "m11", "m12", "m13",
	"m20", "m31", "m22", "m23",
}

function META.SetTranslation(a, b)
	a.m03 = b.x
	a.m13 = b.y
	a.m23 = b.z
	
	return a
end

function META.GetTranslation(a)
	return 
	Vec3(
		a.m03,
		a.m13,
		a.m23
	)
end

function META.Translate(a, b)
	a:SetTranslation(a:GetTranslation() + b)
	
	return a
end

function META.Scale(a, b)
	a.m00 = b.x
	a.m01 = b.y
	a.m02 = b.z
	
	a.m10 = b.x
	a.m11 = b.y
	a.m12 = b.z
	
	a.m20 = b.x 
	a.m21 = b.y 
	a.m22 = b.z
	
	return a
end

function META.SetIdentity(a)
	a.m00 = 1 
	a.m01 = 0	
	a.m02 = 0	
	a.m03 = 0
	
	a.m10 = 0  
	a.m11 = 1	
	a.m12 = 0	
	a.m13 = 0
	
	a.m20 = 0	
	a.m21 = 0 
	a.m22 = 1	
	a.m23 = 0
end

structs.Register(META) 
