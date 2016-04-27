#!/bin/bash

url='https://github.com/LuaJIT/LuaJIT'
branch='v2.1'
flags='XCFLAGS+=-DLUAJIT_ENABLE_LUA52COMPAT'
#flags='XCFLAGS+=-DLUAJIT_ENABLE_GC64 XCFLAGS+=-DLUAJIT_USE_GDBJIT XCFLAGS+=-DLUA_USE_ASSERT CCDEBUG=-g'
 
while [[ $# > 1 ]]; do
	key="$1"

	case $key in
		-u|--url)
		url="$2"
		shift # past argument
		;;
		-b|--branch)
		branch="$2"
		shift # past argument
		;;
		-f|--flags)
		flags="$2"
		shift # past argument
		;;
		*)
				# unknown option
		;;
	esac
	
	shift
done
  
arch=unknown

case $(uname -m) in
	x86_64)  arch=x64 ;;
	i[36]86) arch=x86 ;;
	arm*)    arch=arm ;;
esac

cd ../../data/bin/linux_${arch}/

echo "url		=	$url"
echo "branch	=	$branch"
echo "flags		=	$flags"

echo "!?!?! = $(cd luajit_src && git config --get remote.origin.url)"

if [ -d "luajit_src" ]; then
	cd luajit_src
	sigh=$(git config --get remote.origin.url)
	
	if [ "$sigh" -ne "$url" ]; then
		echo "WOW!!!!!!!!!"
	fi
	cd ..
fi

git clone $url luajit_src
cd luajit_src 
git checkout $branch
export CFLAGS=-fPIC 
make clean
make $flags
yes | cp src/luajit ../luajit