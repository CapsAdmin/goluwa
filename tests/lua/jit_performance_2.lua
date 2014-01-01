local tostring=tostring

print("TRACE TEST CASE: ")

local bullshit={}
bullshit.asd=1
bullshit.func1=function(a) bullshit.asd=a end
bullshit.func2=function(b) bullshit.func1(b) end
bullshit.func3=function(c) bullshit.func2(c) end
bullshit.func4=function(d) bullshit.func3(d) end

local start=0 --just to make sure that the declaration of this local wont make difference on time measurement

jit.flush(true)

print("initial address :"..tostring(bullshit.func3))

start = glfw.GetTime()

for i=1,10000000000 do
	bullshit.func4(1) 
end

print("Took: "..glfw.GetTime()-start)

--oops! lets replace the func3 again :p
bullshit.func3=function(c) bullshit.func2(c) end

jit.flush(true)

print("final address :"..tostring(bullshit.func3))

start = glfw.GetTime()

for i=1,10000000000 do
	bullshit.func4(1)
end

print("Took: "..glfw.GetTime()-start)


print("SETS CASE: ")



local nomnom={}
nomnom.Health=100

function nomnom:SetHealth(h)
	self.Health=h
end

print("tab:SetVar(v) test")

local garbage=0
garbage=collectgarbage("count")

start = glfw.GetTime()

for i=1,10000000000 do
	nomnom:SetHealth(100) 
end

print("Took: "..glfw.GetTime()-start .. " garbage: "..collectgarbage("count")-garbage)
collectgarbage()

function nomnom.SetHealth2(h)
	nomnom.Health=h
end

print("tab.SetVar(v) test")
garbage=collectgarbage("count")

start = glfw.GetTime()

for i=1,10000000000 do
	nomnom.SetHealth2(100) 
end

print("Took: "..glfw.GetTime()-start .. " garbage: "..collectgarbage("count")-garbage)
collectgarbage()


print("tab.Var= test")
garbage=collectgarbage("count")

start = glfw.GetTime()

for i=1,10000000000 do
	nomnom.Health=100
end

print("Took: "..glfw.GetTime()-start .. " garbage: "..collectgarbage("count")-garbage)
collectgarbage()


