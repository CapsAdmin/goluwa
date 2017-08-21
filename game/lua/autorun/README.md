Everything in this directory is executed after everything is initialized. The same applies to the sub directories except they depend on certain things to be availble. For instance if you don't have a sound the `sound/*` directory will not autorun.

The scripts here are mostly toy scripts that use the goluwa api. For instance the zsnes menu, the game editor, chatbox, etc.

There are some other autorun folders that are not used here. One of them is your username, so if you make a folder with your OS' username it will autorun only when it's your username. There's also `client/*` which only runs if you're client, but in most cases `graphics/*` is enough.
