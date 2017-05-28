#!/bin/bash

#rm ../../glfw/libglfw.lua && make -C ../../glfw/
#rm ../../vulkan/libvulkan.lua && make -C ../../vulkan/
#rm ../../freeimage/libfreeimage.lua && make -C ../../freeimage/

export LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH"
./../../luajit/repo/src/luajit vulkan_test.lua

#vktrace -o ./test.vktrace -p ./../../../LuaJIT/src/luajit -a vulkan_test.lua -w .
#vkreplay -t test.vktrace
