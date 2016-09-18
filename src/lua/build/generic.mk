LUA_DIR = ../luajit/
LUA_BIN = $(LUA_DIR)repo/src/luajit

all: $(LUA_BIN)
	export LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH" && ./$(LUA_BIN) build.lua

$(LUA_BIN):
	cd ../luajit && make luajit

clean:
	rm -f lib*.lua
	rm -rf repo
	rm -f lib*.so
