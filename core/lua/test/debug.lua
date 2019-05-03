local THENAME = function() end test(debug.getname, THENAME, "THENAME") THENAME = nil
local function THENAME() end test(debug.getname, THENAME, "THENAME") THENAME = nil
local foo = {THENAME = function() end} test(debug.getname, foo.THENAME, "THENAME") foo = nil
local foo = {} function foo.THENAME() end test(debug.getname, foo.THENAME, "foo.THENAME") foo = nil
local foo = {}; foo["THENAME"] = {}; local wtf = function() end; foo['THENAME'][wtf] = function() end test(debug.getname, foo.THENAME[wtf], "foo['THENAME'][wtf]") foo = nil