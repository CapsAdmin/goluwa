#!/bin/bash

cd ../../../data/bin
mkdir src
cd src

git clone https://github.com/bulletphysics/bullet3
cd bullet3
mkdir build
cd build
cmake -DBUILD_SHARED_LIBS=ON ..
make

cd ../../

git clone https://github.com/CapsAdmin/bullet3-c-api

cd bullet3-c-api
rm -r bullet_include
ln -s ../bullet3/src/ bullet_include
cp ../bullet3/build/src/Bullet3Collision/*.a bullet_lib/x64/
cp ../bullet3/build/src/Bullet3Common/*.a bullet_lib/x64/
cp ../bullet3/build/src/Bullet3Dynamics/*.a bullet_lib/x64/
cp ../bullet3/build/src/Bullet3Geometry/*.a bullet_lib/x64/
cp ../bullet3/build/src/Bullet3OpenCL/*.a bullet_lib/x64/
cp ../bullet3/build/src/Bullet3Serialize/Bullet2FileLoader/*.a bullet_lib/x64/
cp ../bullet3/build/src/BulletCollision/*.a bullet_lib/x64/
cp ../bullet3/build/src/BulletDynamics/*.a bullet_lib/x64/
cp ../bullet3/build/src/BulletInverseDynamics/*.a bullet_lib/x64/
cp ../bullet3/build/src/LinearMath/*.a bullet_lib/x64/

premake4 gmake