local zip = require'minizip'
local glue = require'glue'
local pp = require'pp'

local filename = 'test.zip'
local password = 'doh'
local hello = 'hello'
local hello_again = 'hello again'

local z = zip.open(filename, 'w')

z:add_file{filename = 'dir1/file1.txt', password = password, date = os.date'*t'}
z:write(hello)
z:close_file()

z:add_file{filename = 'dir1/file2.txt'}
z:write(hello_again)
z:close_file()

z:close('one dir, two files')


local z = zip.open(filename)
pp(z:get_global_info())

for info in z:files() do
	pp(info)
end

assert(z:extract('dir1/file1.txt', password) == hello)
assert(z:extract'dir1/file2.txt' == hello_again)

z:close()

os.remove(filename)
