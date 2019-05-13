local config = {}

-- This is needed for UTF8. Assume everything is a letter if it's not any of the other types.
config.FallbackCharacterType = "letter"

function config.OnInitialize(tk, str, on_error)
	tk.code = string.utf8totable(str)
	tk.code_length = #tk.code
	tk.tbl_cache = {}
end
function config.GetLength(tk)
	return tk.code_length
end
function config.GetCharOffset(tk, i)
	return tk.code[tk.i + i] or ""
end

local table_concat = table.concat
function config.GetCharsRange(tk, start, stop)
	local length = stop-start

	if not tk.tbl_cache[length] then
		tk.tbl_cache[length] = {}
	end
	local str = tk.tbl_cache[length]

	local str_i = 1
	for i = start, stop do
		str[str_i] = tk.code[i] or ""
		str_i = str_i + 1
	end
	return table_concat(str)
end

return config