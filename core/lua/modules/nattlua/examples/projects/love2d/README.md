This a löve example written in Nattlua (lua with a typesystem and some other things)

First clone [nattlua](https://github.com/CapsAdmin/NattLua) somewhere and run
```
luajit build.lua
sudo cp build_output.lua /usr/local/bin/nattlua
```

Then you can run the following commands:

* `nattlua build-api` build and update love type defintions from https://github.com/love2d-community/love-api
* `nattlua build` build dist/main.lua from src/main.nlua
* `nattlua run` run the output with love

running `nattlua build` will build `dist/main.lua` which is a single lua file based on the imports of `src/main.nlua` and type information stripped.
