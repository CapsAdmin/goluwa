#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

luarocks --local install luasocket
luarocks --local install luasec

cp -r ~/.luarocks/lib/lua/5.1/mime ../linux_x64/mime
cp -r ~/.luarocks/lib/lua/5.1/socket ../linux_x64/socket
cp ~/.luarocks/lib/lua/5.1/ssl.so ../linux_x64/ssl.so

luarocks --local remove luasocket
luarocks --local remove luasec
