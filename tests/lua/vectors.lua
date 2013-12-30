--[[

GMOD                  GOLUWA

======0 0 0======    ======0 0 0======
FORWARD = +1 +0 -0    FORWARD = +1 +0 -0
RIGHT 	= +0 -1 -0    RIGHT   = +0 -1 +0
UP 		= +0 +0 +1    UP 	  = +0 +0 +1
==================   ==================      

======180 0 0======  ======180 0 0======
FORWARD = -1 -0 +0    FORWARD = +1 +0 -0
RIGHT 	= +0 -1 +0    RIGHT   = +0 +1 -1
UP 		= -1 -0 -1    UP 	  = -0 +0 -1
==================   ==================

======0 0 180======  ======0 0 180======
FORWARD = +1 +0 -0    FORWARD = -1 -1 -0
RIGHT 	= +0 +1 +0    RIGHT   = +0 +1 +0
UP 		= -0 +0 -1    UP 	  = -0 +0 +1
==================   ==================


]]

local msg = gmod and MsgN or logn

local printv = function(str, v)
	msg(str .. " = " .. math.floor(v.x) .. " " .. math.floor(v.y) .. " " .. math.floor(v.z)) 
end

function PrintDirectons(p, y, r) 
	local ang = gmod and Angle(p,y,r) or Ang3(math.rad(p),math.rad(y),math.rad(r)) 

	msg("\n======" .. p .. " " .. y .. " " .. r .. "======")
	if gmod then 		
		printv("FORWARD", ang:Forward()) 
		printv("RIGHT", ang:Right()) 
		printv("UP", ang:Up()) 
	else 
		printv("FORWARD", ang:GetForward()) 
		printv("RIGHT", ang:GetRight()) 
		printv("UP", ang:GetUp()) 
	end
	msg("==================\n")
end

PrintDirectons(0, 0, 0)  
PrintDirectons(180, 0, 0)
PrintDirectons(0, 0, 180)
   