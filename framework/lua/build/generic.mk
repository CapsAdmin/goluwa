LUA_DIR = ../luajit/
LUA_BIN = $(LUA_DIR)repo/src/luajit

all: $(LUA_BIN)
	export LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH" && ./$(LUA_BIN) build.lua ${ARGS}

$(LUA_BIN):
	cd ../luajit && make

clean:
	rm -rf repo/
	mkdir ../tmp
	mv build.lua ../tmp/
	mv Makefile ../tmp/
	rm -f *
	mv ../tmp/* .
	rmdir ../tmp
