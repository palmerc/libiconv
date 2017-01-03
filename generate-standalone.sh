#!/bin/bash 

ANDROID_NDK_DIR=/opt/android-ndk-r13b
ANDROID_API=19
ANDROID_STL=gnustl
INSTALL_PREFIX=/opt/standalone-r13b
declare -a COMPILE_ARCHITECTURES=("arm" "x86")

pushd ${ANDROID_NDK_DIR}
for ARCH in "${COMPILE_ARCHITECTURES[@]}"
do
    build/tools/make_standalone_toolchain.py \
        --arch ${ARCH} \
        --api ${ANDROID_API} \
        --stl ${ANDROID_STL} \
        --install-dir ${INSTALL_PREFIX}-${ARCH}
done
popd
