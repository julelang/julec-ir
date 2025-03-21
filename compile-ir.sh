#!/bin/bash
# Copyright 2023-2024 The Jule Programming Language.
# Use of this source code is governed by a BSD 3-Clause
# license that can be found in the LICENSE file.

declare unknown=255

declare arch_i386=0
declare arch_amd64=1
declare arch_arm64=2

declare os_windows=0
declare os_linux=1
declare os_darwin=2

declare ir_name=ir.cpp

function get_arch() {
    arch=$(uname -m)
    if [[ $arch == x86_64* ]]; then
        return $arch_amd64
    elif [[ $arch == i*86 ]]; then
        return $arch_i386
    elif  [[ $arch == arm64* || $arch == aarch64* ]]; then
        return $arch_arm64
    else
        return $unknown
    fi
}

function get_os() {
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        return $os_linux
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        return $os_darwin
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
        return $os_windows
    else
        return $unknown
    fi
}

curl_ir() {
    curl -o $ir_name $1
}

get_ir() {
    get_arch
    declare arch=$?

    if [[ $arch == $unknown ]]; then
        echo "Your architecture is not supported."
        exit 1
    fi

    get_os
    declare os=$?

    if [[ $os == $unknown ]]; then
        echo "Your operating system is not supported."
        exit 1
    fi

    if [[ $os == $os_windows ]]; then
        if [[ $arch == $arch_i386 ]]; then
            curl_ir https://raw.githubusercontent.com/julelang/julec-ir/main/src/windows-i386.cpp
        elif [[ $arch == $arch_amd64 ]]; then
            curl_ir https://raw.githubusercontent.com/julelang/julec-ir/main/src/windows-amd64.cpp
        elif [[ $arch == $arch_arm64 ]]; then
            curl_ir https://raw.githubusercontent.com/julelang/julec-ir/main/src/windows-arm64.cpp
        else
            echo "Your operating system and architecture combinations is not supported"
            exit 1
        fi
    elif [[ $os == $os_linux ]]; then
        if [[ $arch == $arch_i386 ]]; then
            curl_ir https://raw.githubusercontent.com/julelang/julec-ir/main/src/linux-i386.cpp
        elif [[ $arch == $arch_amd64 ]]; then
            curl_ir https://raw.githubusercontent.com/julelang/julec-ir/main/src/linux-amd64.cpp
        elif [[ $arch == $arch_arm64 ]]; then
            curl_ir https://raw.githubusercontent.com/julelang/julec-ir/main/src/linux-arm64.cpp
        else
            echo "Your operating system and architecture combinations is not supported"
            exit 1
        fi
    elif [[ $os == $os_darwin ]]; then
        if [[ $arch == $arch_amd64 ]]; then
            curl_ir https://raw.githubusercontent.com/julelang/julec-ir/main/src/darwin-amd64.cpp
        elif [[ $arch == $arch_arm64 ]]; then
            curl_ir https://raw.githubusercontent.com/julelang/julec-ir/main/src/darwin-arm64.cpp
        else
            echo "Your operating system and architecture combinations is not supported"
            exit 1
        fi
    fi
}

function log() {
    echo ">>> " $1
    echo ""
}

log "Getting latest Jule@master source tree..."
curl -Lko julec.zip https://github.com/julelang/jule/archive/refs/heads/master.tar.gz
tar -xzf julec.zip -C .
echo ""

log "Getting latest JuleC IR distribution..."
cd jule-master
get_ir
echo ""

log "Compiling IR distribution..."
mkdir bin
clang++ -Wno-everything -fwrapv -ffloat-store --std=c++17 -O3 -fno-strict-aliasing -flto -DNDEBUG -fomit-frame-pointer -o bin/julec $ir_name

if [[ $? == 0 ]]; then
    echo "Your IR JuleC compilation is read-to-use."
else
    echo "Compilation failed."
fi
