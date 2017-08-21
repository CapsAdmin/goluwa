function system.ExecuteArgs(args)
	args = args or _G.ARGS

	local skip_lua = nil

	if not args then
		local str = os.getenv("GOLUWA_ARGS")

		if str then
			if str:startswith("cli --") then
				args = str:sub(5):split("--", true)
				table.remove(args, 1) -- uh
				skip_lua = true
			else
				local func, err = loadstring("return " .. str)

				if func then
					local ok, tbl = pcall(func)

					if not ok then
						logn("failed to execute ARGS: ", tbl)
					end

					args = tbl
				else
					logn("failed to execute ARGS: ", err)
				end
			end
		end
	end

	if args then
		for _, arg in ipairs(args) do
			commands.RunString(tostring(arg), skip_lua, true, true)
		end
	end
end
