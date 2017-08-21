os.execute("mkdir repo")

os.execute("git clone https://github.com/lua/lua repo/lua")
os.execute("git -C repo/lua checkout tags/v5_1_1")
os.execute("make -C repo/lua/")
os.execute("cp repo/lua/lua ../../../../data/bin/linux_x64/lua")

os.execute("git clone https://github.com/facebook/luaffifb repo/luaffi")
os.execute("make -C repo/luaffi")
os.execute("cp repo/luaffi/ffi.so ../../../../data/bin/linux_x64/ffi.so")

