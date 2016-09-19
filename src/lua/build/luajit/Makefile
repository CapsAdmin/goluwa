LUA_URL = https://github.com/LuaJIT/LuaJIT repo
LUA_BRANCH = v2.1

LUA_DIR = ../luajit/
LUA_BIN = $(LUA_DIR)repo/src/luajit

all: repo
	export LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH" && ./$(LUA_BIN) build.lua
repo:
	git clone $(LUA_URL)
	cd repo; git checkout $(LUA_BRANCH)
	cd repo; export CFLAGS=-fPIC; make

clean:
	rm -rf repo
