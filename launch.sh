has_command() {
	command -v $1 2>&1 >/dev/null
	return $?
}

is_arch() {
	if [ $(getconf LONG_BIT) = "$1" ]; then
		return 0
	else
		return 1
	fi
}

cd .base/bin/linux/$(is_arch 64 && echo x64 || echo x86)

while true; do
	tmux attach-session -t goluwa || tmux new-session -s goluwa 'env - PATH=$PWD LD_LIBRARY_PATH=$PWD TERM=$TERM USER=$USER HOME=$HOME DISPLAY=$DISPLAY ./luajit ../../../lua/init.lua'
	if [ $? -eq 0 ] || [ $? -ge 128 ]; then echo "im outta here"; break; fi
	sleep 1
done
