#!/usr/bin/env bash
if [[ $1 == "" ]]; then
    echo "Usage: $0 <feature>"
    exit 1
fi

macos () {
    fileExt="dylib"
    newLine="\n"
}
wsl () {
    echo "Ubuntu on Windows"
    fileExt="so"
    newLine="\r\n"
}

cygwin () {
    echo Cygwin
    fileExt="so"
    newLine="\r\n"
}

mingw () {
    echo MinGW
    fileExt="so"
    newLine="\r\n"
}

linux () {
    fileExt="so"
    newLine="\n"
}

unknown () {
    echo "No idea what OS $(uname -s) is, bailing."
    fileExt="so"
    newLine="\r\n"
}


unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     linux;;
    Darwin*)    macos;;
    CYGWIN*)    cygwin;;
    MINGW*)     mingw;;
    *)          unknown
esac

if [[ $thisCPU == ""  ]]; then
    thisCPU=$( echo | gcc -march=native -dM -E - | tr -d '#define' | tr $newLine ' ' )
    echo "thisCPU not set, using: $thisCPU"
fi
if [[ "$CFLAGS" == "" || "$ASMFLAGS" == "" ]]; then
    echo "CFLAGS and ASMFLAGS must be set."
    exit 1
fi


unameOut="$(uname -s)"
fileExt="so"
case "${unameOut}" in
    Linux*)     fileExt="so";;
    Darwin*)    fileExt="dylib";;
    CYGWIN*)    fileExt="so";;
    MINGW*)     fileExt="so";;
    *)          unknown
esac


build="make $1/libXKCP.$fileExt"
if [[ $thisCPU == *"$1"* ]]; then
    echo "Building & testing $1"
    $build && make $1/UnitTests && bin/$1/UnitTests -a
else
    echo "Building $1"
    $build && echo "No $1 feature found on this CPU, skipping tests."
fi
