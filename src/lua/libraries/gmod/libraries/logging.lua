local gmod = ... or gmod

function gmod.env.Msg(...) log(...) end
function gmod.env.MsgC(...) log(...) end
function gmod.env.MsgN(...) logn(...) end
function gmod.env.ErrorNoHalt(...) local args = {...} table.insert(args, 2) wlog(unpack(args)) end