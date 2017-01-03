## Cross-compiling libiconv 

This demonstrates cross-compiling an Automake project for ARM using the Android NDK.

### config.sub and config.guess

On some older projects you'll find that the config.guess and config.sub files won't recognize the Android NDK toolchain so you'll need to grab a newer one from automake. In this project I copied the files from Automake 1.15 and just overwrote the ones in the libiconv project.

### Build a standalone toolchain

When compiling using Automake you'll need a standalone toolchain that embodies one target architecture and a specific platform revision. 


#### generate-standalone.sh

    #!/bin/bash 

    ANDROID_NDK_DIR=/opt/android-ndk-r13b
    ANDROID_API=19
    ANDROID_STL=gnustl
    INSTALL_PREFIX=/opt/standalone-r13b
    declare -a COMPILE_ARCHITECTURES=("arm" "x86")

    pushd ${ANDROID_NDK_DIR}
    for ARCH in "${COMPILE_ARCHITECTURES[@]}"
    do
        INSTALL_DIR=${INSTALL_PREFIX}-${ARCH}
        build/tools/make_standalone_toolchain.py \
            --arch ${ARCH} \
            --api ${ANDROID_API} \
            --stl ${ANDROID_STL} \
            --install-dir ${INSTALL_DIR}
    done
    popd

ANDROID_NDK_DIR=/opt/standalone-r13b
LIBICONV_INSTALL_DIR=${HOME}/Development/libiconv

declare -a COMPILE_ARCHITECTURES=("arm" "armv7a" "x86")
SAVED_PATH="${PATH}"
for ARCH in "${COMPILE_ARCHITECTURES[@]}"
do
    export ANDROID_NDK_ROOT="${ANDROID_NDK_DIR}-${ARCH}"

    ANDROID_NDK_BIN="${ANDROID_NDK_ROOT}/bin"
    ANDROID_SYSROOT_DIR="${ANDROID_NDK_ROOT}/sysroot"

    export PATH="${ANDROID_NDK_BIN}:${SAVED_PATH}"
    export CFLAGS="--sysroot=${ANDROID_SYSROOT_DIR}"
    export CXXFLAGS="--sysroot=${ANDROID_SYSROOT_DIR}"

    COMPILER_PREFIX=""
    case ${ARCH} in
        "arm" )
            ABI_NAME=armeabi
            COMPILER_PREFIX=arm-linux-androideabi
            ;;
        "armv7a" )
            ABI_NAME=armeabi-v7a
            COMPILER_PREFIX=arm-linux-androideabi
            CFLAGS="${CFLAGS} -march=armv7-a -mfpu=neon -mfloat-abi=softfp" 
            ;;
        "x86" )
            ABI_NAME=x86
            COMPILER_PREFIX=i686-linux-android
            ;;
    esac

    export CC=${ANDROID_NDK_BIN}/${COMPILER_PREFIX}-gcc
    export CPP=${ANDROID_NDK_BIN}/${COMPILER_PREFIX}-cpp
    export CXX=${ANDROID_NDK_BIN}/${COMPILER_PREFIX}-g++
    export LD=${ANDROID_NDK_BIN}/${COMPILER_PREFIX}-ld
    export RANLIB=${ANDROID_NDK_BIN}/${COMPILER_PREFIX}-ranlib
    export STRIP=${ANDROID_NDK_BIN}/${COMPILER_PREFIX}-strip

   echo "---- Compiling for ${ARCH}"
   ./configure --host="${COMPILER_PREFIX}" --prefix="${LIBICONV_INSTALL_DIR}/${ABI_NAME}"
   make clean
   make -j4
   make install
done

export PATH="${SAVED_PATH}"
