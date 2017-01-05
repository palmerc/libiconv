ANDROID_NDK_DIR=/Users/palmerc/Development/android-ndk/standalone-r13b
LIBICONV_PARENT_DIR=${HOME}/Development/dcmtk-compile
LIBICONV_INSTALL_DIR=${LIBICONV_PARENT_DIR}/libiconv

declare -a COMPILE_ARCHITECTURES=("arm" "armv7a" "x86")
#declare -a COMPILE_ARCHITECTURES=("x86")
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

    STANDALONE_TOOLCHAIN="${ANDROID_NDK_DIR}-${COMPILER_GROUP}"
    ANDROID_NDK_BIN="${STANDALONE_TOOLCHAIN}/bin"
    SYSROOT_DIR="${STANDALONE_TOOLCHAIN}/sysroot"

    export CFLAGS="--sysroot=${SYSROOT_DIR}"
    export CXXFLAGS="--sysroot=${SYSROOT_DIR}"

    unset ABI_NAME
    unset COMPILER_PREFIX
    unset CFLAGS
    unset LDFLAGS
    case ${ARCH} in
        "arm" )
            ABI_NAME=armeabi
            COMPILER_PREFIX=arm-linux-androideabi
            ;;
        "armv7a" )
            ABI_NAME=armeabi-v7a
            COMPILER_PREFIX=arm-linux-androideabi
            export CFLAGS="${CFLAGS} -march=armv7-a -mfpu=neon -mfloat-abi=softfp -mthumb" 
            export LDFLAGS="-march=armv7-a -Wl,--fix-cortex-a8"
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
    export AS=${ANDROID_NDK_BIN}/${COMPILER_PREFIX}-as
    export RANLIB=${ANDROID_NDK_BIN}/${COMPILER_PREFIX}-ranlib
    export STRIP=${ANDROID_NDK_BIN}/${COMPILER_PREFIX}-strip

   echo "---- Compiling for ${ARCH}"
   ./configure --enable-static --host="${COMPILER_PREFIX}" --prefix="${LIBICONV_INSTALL_DIR}/${ABI_NAME}"
   make clean
   make -j4
   make install

   unset CC
   unset CPP
   unset CXX
   unset LD
   unset AR
   unset AS
   unset RANLIB
   unset STRIP
done
