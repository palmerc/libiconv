## Example by cross-compiling libiconv 

### Build a standalone toolchain

When compiling using Automake you'll need a standalone toolchain that embodies one target architecture and a specific platform revision. The procedure is outlined in the following script.

### generate-standalone.sh

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

### Replace config.sub and config.guess

On some older projects you'll find that the config.guess and config.sub files won't recognize the Android NDK toolchain so you'll need to grab a newer one from automake. In this project I copied the files from Automake 1.15 and just overwrote the ones in the libiconv project.

### Compiling for 3 architectures

Note: I haven't compiled 64-bit targets in this example. I would need to raise the Android API to 21 to add ARM64 and x86_64.

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

### Validating the libraries target the desired architecture

From the NDK you can find `arm-linux-androideabi-readelf` to determine if for example I'm using Thumb-1 or Thumb-2 instructions in armeabi and armeabi-v7a respectively.

    arm-linux-androideabi-readelf -A libiconv.so.2.5.1.so

### armeabi
    Attribute Section: aeabi
    File Attributes
      Tag_CPU_name: "5TE"
      Tag_CPU_arch: v5TE
      Tag_ARM_ISA_use: Yes
      Tag_THUMB_ISA_use: Thumb-1
      Tag_FP_arch: VFPv2
      Tag_ABI_PCS_wchar_t: 4
      Tag_ABI_FP_denormal: Needed
      Tag_ABI_FP_exceptions: Needed
      Tag_ABI_FP_number_model: IEEE 754
      Tag_ABI_align_needed: 8-byte
      Tag_ABI_enum_size: int
      Tag_ABI_optimization_goals: Aggressive Speed

### armeabi-v7a

    Attribute Section: aeabi
    File Attributes
      Tag_CPU_name: "ARM v7"
      Tag_CPU_arch: v7
      Tag_CPU_arch_profile: Application
      Tag_ARM_ISA_use: Yes
      Tag_THUMB_ISA_use: Thumb-2
      Tag_FP_arch: VFPv3
      Tag_Advanced_SIMD_arch: NEONv1
      Tag_ABI_PCS_wchar_t: 4
      Tag_ABI_FP_denormal: Needed
      Tag_ABI_FP_exceptions: Needed
      Tag_ABI_FP_number_model: IEEE 754
      Tag_ABI_align_needed: 8-byte
      Tag_ABI_enum_size: int
      Tag_ABI_HardFP_use: Deprecated
      Tag_ABI_optimization_goals: Aggressive Speed
      Tag_CPU_unaligned_access: v6
