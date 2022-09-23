local files = assert(fs.get_files("."))

test(table.has_value, files, "core").expect_compare(function(a, b)
	return type(a) == "number"
end)

test(table.has_value, files, "goluwa").expect_compare(function(a, b)
	return type(a) == "number"
end)

do
	local res = assert(fs.get_files_recursive("framework"))

	if #res < 50 then
		test.fail(
			"fs.GetFilesRecursively('framework')",
			"expected more than 50 results, got " .. #res
		)
	end
end

test(fs.create_directory, "TEST").expect(true)
test(fs.create_directory, "TEST/TEST").expect(true)
local f = io.open("foo", "w")
f:write("hello world")
f:close()
test(fs.link, "foo", "TEST/TEST/foo").expect(true)
test(fs.set_current_directory, "TEST/TEST").expect(true)
local f = io.open("foo", "r")
test(function()
	return f:read("*all")
end).expect("hello world")
f:close()
test(fs.set_current_directory, "../../").expect(true)

test(fs.get_attributes, "TEST/TEST/foo").expect_compare(function(a)
	return type(a) == "table"
end)

test(fs.get_type, "TEST/TEST/foo").expect("file")
test(fs.RemoveRecursively, "TEST").expect(true)

test(fs.get_attributes, "TEST/TEST/foo").expect_compare(nil, function(a)
	return type(a) == "string"
end)

test(fs.copy, "goluwa.cmd", "goluwa2.cmd").expect_compare(function()
	return fs.Read("goluwa.cmd") == fs.Read("goluwa2.cmd")
end)

test(fs.remove_file, "goluwa2.cmd").expect(true)
test(fs.remove_file, "foo").expect(true)