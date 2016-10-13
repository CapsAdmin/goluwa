This directory is mounted to the root directory.

* goluwa/src/lua/*
* goluwa/myaddon/lua/*

meaning `vfs.Find("lua/*")` would look in both `goluwa/src/lua/*` and `goluwa/myaddon/lua/*` and return results as if there was only one lua folder. This is similar to how source engine addons or garry's mod addons work.



### [lua/](lua/)

The lua source code


### [cli/](cli/)
Platform specific launch scripts. It's mostly for downloading requried binaries and launching luajit with the proper init.lua file.

### [languages/](languages/)
Language translation data used the gui and other things.
