local META = {}

META.ClassName = "META"

META.NumberType = "float"
META.Args = {"x", "y", "z", "r"}

structs.AddAllOperators(META)

structs.Register(META) 
