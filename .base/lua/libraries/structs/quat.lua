local structs = (...) or _G.structs

local META = {}

META.ClassName = "Quat"

META.NumberType = "float"
META.Args = {"x", "y", "z", "w"}

structs.AddAllOperators(META)

structs.Register(META) 
