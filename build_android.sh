#!/bin/bash

# NDK目录
TOOLCHAIN=$NDK_PATH/toolchains/llvm/prebuilt/linux-x86_64
# 最低支持的android sdk版本
API=21

function build_android
{
echo "Compiling FFmpeg for $CPU"

./configure \
 --prefix=$PREFIX \
 --enable-neon \
 --enable-shared \
 --enable-small \
 --disable-vulkan \
 --disable-gpl \
 --disable-postproc \
 --enable-jni \
 --enable-mediacodec \
 --disable-doc \
 --enable-ffmpeg \
 --disable-ffplay \
 --enable-ffprobe \
 --disable-avdevice \
 --disable-symver \
 --enable-cross-compile \
 --cross-prefix=$CROSS_PREFIX \
 --target-os=android \
 --arch=$ARCH \
 --cpu=$CPU \
 --cc=$CC \
 --cxx=$CXX \
 --sysroot=$SYSROOT \
 --extra-cflags="-mno-stackrealign -Os -fpic -mfpu=neon $OPTIMIZE_CFLAGS" \
 --extra-ldflags="$ADDI_LDFLAGS"
 #--enable-decoder=h264_mediacodec
 #--disable-ffmpeg
 #--disable-programs
 #--disable-debug
 #--disable-stripping
 #--disable-linux-perf
 #--disable-hwaccels

#make clean
#make -j4
#make install

echo "The Compilation of FFmpeg for $CPU is completed"
}

function print_supported_cpus
{
    echo "Supports the following CPUs:"
    echo "1. armv7-a"
    echo "2. armv8-a"
}

function print_usage
{
    echo "Usage: $0 [CPU]"
    echo "Example: $0 armv7-a"
	print_supported_cpus
}

# 传入CPU参数
CPU=$1

if [ -z "$CPU" ]; then
    print_usage
    exit 1
elif [ "$CPU" = "help" ]; then
    print_usage
elif [ "$CPU" = "armv7-a" ]; then
    ARCH=arm
    CC=$TOOLCHAIN/bin/armv7a-linux-androideabi$API-clang
    CXX=$TOOLCHAIN/bin/armv7a-linux-androideabi$API-clang++
    SYSROOT=$TOOLCHAIN/sysroot
    CROSS_PREFIX=$TOOLCHAIN/bin/llvm-
    PREFIX=$(pwd)/android/$CPU
    ADDI_LDFLAGS=" "
    OPTIMIZE_CFLAGS="-mfloat-abi=softfp -march=$CPU"
    build_android
elif [ "$CPU" = "armv8-a" ]; then
    ARCH=arm64
    CC=$TOOLCHAIN/bin/aarch64-linux-android$API-clang
    CXX=$TOOLCHAIN/bin/aarch64-linux-android$API-clang++
    SYSROOT=$TOOLCHAIN/sysroot
    CROSS_PREFIX=$TOOLCHAIN/bin/llvm-
    PREFIX=$(pwd)/android/$CPU
    OPTIMIZE_CFLAGS="-march=$CPU"
    build_android
else
    echo "Unsupported CPU: $CPU"
    print_supported_cpus
fi
