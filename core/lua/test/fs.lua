local files = fs.get_files(".")

test(table.hasvalue, files, "core").expect_compare(function(a, b) return type(a) == "number" end)
test(table.hasvalue, files, "goluwa").expect_compare(function(a, b) return type(a) == "number" end)

do
    local res = fs.get_files_recursively("framework")
    if #res < 50 then
        test.fail("fs.GetFilesRecursively('framework')", "expected more than 50 results, got " .. #res)
    end
end

fs.create_directory("TEST")
fs.create_directory("TEST/TEST")
fs.link("goluwa.cmd", "TEST/TEST/foo")
fs.remove("TEST/TEST/foo")
fs.remove("TEST/TEST")
fs.remove("TEST")
