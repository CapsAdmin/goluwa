local META = {}

META.ClassName = "Quat"

META.NumberType = "float"
META.Args = {"x", "y", "z", "r"}

structs.AddAllOperators(META)

structs.Register(META) 
