ANDROID_NDK_DIR=/opt/standalone-r13b
LIBICONV_INSTALL_DIR=${HOME}/Development/libiconv

declare -a COMPILE_ARCHITECTURES=("arm" "armv7a" "x86")
SAVED_PATH="${PATH}"
for ARCH in "${COMPILE_ARCHITECTURES[@]}"
do
    COMPILER_GROUP=""
    COMPILER_PREFIX=""
    case ${ARCH} in
        "arm" )
            COMPILER_GROUP=arm
            ;;
        "armv7a" )
            COMPILER_GROUP=arm
            ;;
        "x86" )
            COMPILER_GROUP=x86
            ;;
    esac

    export ANDROID_NDK_ROOT="${ANDROID_NDK_DIR}-${COMPILER_GROUP}"

    ANDROID_NDK_BIN="${ANDROID_NDK_ROOT}/bin"
    ANDROID_SYSROOT_DIR="${ANDROID_NDK_ROOT}/sysroot"

    export PATH="${ANDROID_NDK_BIN}:${SAVED_PATH}"

    export CFLAGS="--sysroot=${ANDROID_SYSROOT_DIR}"
    export CXXFLAGS="--sysroot=${ANDROID_SYSROOT_DIR}"
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
    export AR=${ANDROID_NDK_BIN}/${COMPILER_PREFIX}-ar
    export RANLIB=${ANDROID_NDK_BIN}/${COMPILER_PREFIX}-ranlib
    export STRIP=${ANDROID_NDK_BIN}/${COMPILER_PREFIX}-strip

   echo "---- Compiling for ${ARCH}"
   ./configure --host="${COMPILER_PREFIX}" --prefix="${LIBICONV_INSTALL_DIR}/${ABI_NAME}"
   make clean
   make -j4
   make install
done

export PATH="${SAVED_PATH}"
