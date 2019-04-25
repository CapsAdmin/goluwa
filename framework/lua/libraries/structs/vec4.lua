local structs = (...) or _G.structs

local META = prototype.CreateTemplate("Vec4")

META.NumberType = "double"
META.Args = {{"x", "r"}, {"y", "g"}, {"z", "b"}, {"w", "a"}}

structs.AddAllOperators(META)

structs.AddOperator(META, "generic_vector")
structs.Swizzle(META)
structs.Swizzle(META, 3, "structs.Vec3")
structs.Swizzle(META, 2, "structs.Vec2")

structs.Register(META)

serializer.GetLibrary("luadata").SetModifier("vec4", function(var) return ("Vec4(%f, %f, %f)"):format(var:Unpack()) end, structs.Vec4, "Vec4")
