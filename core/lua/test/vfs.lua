test(vfs.Write, "data/test.txt", "foo").expect(3)
test(R, "data/test.txt").expect(e.USERDATA_FOLDER .. "test.txt")
test(vfs.Read, "data/test.txt").expect("foo")
test(vfs.Delete, "data/test.txt").expect(true)

test(vfs.Read, "data/test.txt").expect_compare(nil, function(arg)
	return arg:starts_with("unable to open file:")
end)

do
	for i = 1, 3 do
		test(vfs.Write, "data/lol/a/b/" .. i .. ".txt", tostring(i)).expect(1)
		test(vfs.Read, "data/lol/a/b/" .. i .. ".txt").expect(tostring(i))
	end

	local found = {["1.txt"] = true, ["2.txt"] = true, ["3.txt"] = true}

	for path in vfs.Iterate("data/lol/a/b/") do
		if found[path] then found[path] = nil end
	end

	if next(found) then test.fail("vfs.Iterate failed") end
end

vfs.Mount(R("os:data/lol/a/b/"), "os:test")
test(vfs.Read, "os:test/1.txt").expect("1")
vfs.Unmount(R("os:data/lol/a/b/"), "os:test") --test(vfs.Read, "os:test/1.txt").expect(nil)