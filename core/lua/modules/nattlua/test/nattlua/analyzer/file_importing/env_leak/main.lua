local foo = 1337
--[[#local type bar = 888]]
-- these upvalues should not leak to other_file.lua
-- this is fixed by using analyzer:CreateAndPushModuleScope() rather than analyzer:CreateAndPushFunctionScope()
require("test.nattlua.analyzer.file_importing.env_leak.other_file")
