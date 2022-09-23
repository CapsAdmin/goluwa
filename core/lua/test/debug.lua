local THENAME = function() end
test(debug.get_name, THENAME, "THENAME")
THENAME = nil

local function THENAME() end

test(debug.get_name, THENAME, "THENAME")
THENAME = nil
local foo = {
	THENAME = function() end,
}
test(debug.get_name, foo.THENAME, "THENAME")
foo = nil
local foo = {}

function foo.THENAME() end

test(debug.get_name, foo.THENAME, "foo.THENAME")
foo = nil
local foo = {}
foo["THENAME"] = {}
local wtf = function() end
foo["THENAME"][wtf] = function() end
test(debug.get_name, foo.THENAME[wtf], "foo['THENAME'][wtf]")
foo = nil