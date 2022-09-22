local _catchError = runfile("diff/catch_error.lua")._catchError
local options = {_catchError = _catchError}
return {options = options}