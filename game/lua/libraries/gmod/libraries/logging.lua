local gine = ... or _G.gine

function gine.env.Msg(...) log(...) end
function gine.env.MsgC(...) log(...) end
function gine.env.MsgN(...) logn(...) end
function gine.env.ErrorNoHalt(...) local args = {...} table.insert(args, 2) wlog(unpack(args)) end
