This directory is mounted to the parent folder.

* goluwa/src/lua/*
* goluwa/myaddon/lua/*

meaning `vfs.Find("lua/*")` would look in both `goluwa/src/lua/*` and `goluwa/myaddon/lua/*` and return results as if there was only one lua folder. This is similar to how source engine addons or garry's mod addons work.



### [lua/](lua/)

The lua source code used in goluwa.


### [cli/](cli/)
Platform specific launch and build scripts.

### [languages/](languages/)
Language translation data used the gui and other things.
