#!/bin/bash

for dir in ./*; do
	if [ -d ${dir} ]; then
		pushd ${dir}
			make clean
 		popd
	fi
done
