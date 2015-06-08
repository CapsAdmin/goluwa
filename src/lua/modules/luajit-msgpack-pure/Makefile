PREFIX=/usr/local
LMODNAME=luajit-msgpack-pure

LUA=luajit
LMODFILE=$(LMODNAME).lua

ABIVER=5.1
INSTALL_SHARE=$(PREFIX)/share
INSTALL_LMOD=$(INSTALL_SHARE)/lua/$(ABIVER)

BENCH_NLOOP=50000

all:
	@echo "This is a pure module. Nothing to make :)"

test:
	$(LUA) tests/test.lua

bench:
	$(LUA) tests/bench.lua $(BENCH_NLOOP)

install:
	install -m0644 $(LMODFILE) $(INSTALL_LMOD)/$(LMODFILE)

uninstall:
	rm -f $(INSTALL_LMOD)/$(LMODFILE)
