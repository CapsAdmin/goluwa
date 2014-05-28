local cd = "%ROOT%"

console.AddCommand("ls", function()
	local files = vfs.Find(cd)
	table.print(files)
end)

console.AddCommand("cd", function(line, folder)
	if not folder then
		logn(cd)
	elseif folder == ".." then
		cd = cd:match("(.+)/")
	elseif vfs.IsDir(cd .. "/" .. folder) then
		cd = cd .. "/" .. folder
	end
end, nil, function(arg, args)
	if #args > 1 then return end
	print(#args)
	
	local out = {".."}
	
	for folder in vfs.Iterate(cd) do
		if vfs.IsDir(folder) then
			table.insert(out, folder)
		end
	end
	
	return out
end)

console.AddCommand("quit", function()
	os.exit()
end)

console.AddCommand("exit", function()
	os.exit()
end)

console.AddCommand("restart", function()
	system.Restart()
end)