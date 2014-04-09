ARCH=$(getconf LONG_BIT)

if [ $ARCH -eq "64" ]; then
	cd .base/bin/linux/x64
	echo x64
else
	cd .base/bin/linux/x86
	echo x86
fi

while true; do
	$(hash screen 2> /dev/null && echo "screen") env LD_LIBRARY_PATH=. ./luajit ../../../lua/init.lua
	# BROKE (when using screen) ==> if [ $? -eq 0 ] || [ $? -ge 128 ]; then echo "im outta here"; break; fi
	sleep 1
done
