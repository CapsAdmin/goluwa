#!/bin/bash

pushd luajit
	make
popd

for dir in ./*; do
	if [ -d ${dir} ]; then
		pushd ${dir}
			make &
		popd
	fi
done
