local META = {}

META.ClassName = "Vec2i"
META.NumberType = "int"
META.Args = {{"x", "w", "p"}, {"y", "h", "y"}}

function META.StructOverride()
	return ffi.metatype("sfVector2i", META)
end

structs.AddAllOperators(META) 

structs.Register(META)
