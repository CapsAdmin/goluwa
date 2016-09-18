package.path = package.path .. ";../?.lua"
local ffibuild = require("ffibuild")

local path = "../../../../data/bin/" .. jit.os:lower() .. "_" .. jit.arch:lower() .. "/"
os.execute("mkdir -p " .. path)
os.execute("cp curses.lua " .. path .. "libcurses.lua")
