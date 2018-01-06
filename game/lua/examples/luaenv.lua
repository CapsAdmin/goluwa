local env = system.CreateLuaEnvironment("test")
env:Send("print(1+1)")
env.OnReceive = function(a) print(a) end