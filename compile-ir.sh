#!/bin/bash
# Copyright 2023 The Jule Project Contributors. All rights reserved.
# Use of this source code is governed by a BSD 3-Clause
# license that can be found in the LICENSE file.

declare unknown=255

declare arch_i386=0
declare arch_amd64=1
declare arch_arm64=2

declare os_windows=0
declare os_linux=1
declare os_macos=2

declare arch=$unknown
declare os=$unknown
declare target=$unknown

# global return value register
declare ret=$unknown

function panic() {
	echo "<error>" $1
	exit 1
}

function log() {
	echo "<log>" $1
}

function init_arch() {
	_arch=$(uname -m)
	if [[ $_arch == x86_64* ]]; then
		arch=$arch_amd64
	elif [[ $_arch == i*86 ]]; then
		arch=$arch_i386
	elif  [[ $_arch == arm64* || $_arch == aarch64* ]]; then
		arch=$arch_arm64
	else
		panic "your architecture is not supported"
	fi
}

function init_os() {
	if [[ "$OSTYPE" == "linux-gnu" ]]; then
		os=$os_linux
	elif [[ "$OSTYPE" == "darwin"* ]]; then
		os=$os_macos
	elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
		os=$os_windows
	else
		panic "your operating system is not supported"
	fi
}

function get_os_string() {
	if [[ $os == $os_linux ]]; then
		ret="linux"
	elif [[ $os == $os_macos ]]; then
		ret="macos"
	elif [[ $os == $os_windows ]]; then
		ret="windows"
	else
		panic "unreachable"
	fi
}

function get_arch_string() {
	if [[ $arch == $arch_i386 ]]; then
		ret="i386"
	elif [[ $arch == $arch_amd64 ]]; then
		ret="amd64"
	elif [[ $arch == $arch_arm64 ]]; then
		ret="arm64"
	else
		panic "unreachable"
	fi
}

function get_target_string() {
	get_arch_string
	arch_s=$ret
	get_os_string
	os_s=$ret
	ret="$os_s-$arch_s"
}

function check_target() {
	if [[ $target == "windows-i386" || $target == "windows-amd64" || $target == "windows-arm64" ]]; then
		return
	elif [[ $target == "linux-i386" || $target == "linux-amd64" || $target == "linux-arm64" ]]; then
		return
	elif [[ $target == "macos-amd64" || $target == "macos-arm64" ]]; then
		return
	else
		panic "your system configuration is not supported: $target"
	fi
}

function get_ir_url() {
	ret="https://raw.githubusercontent.com/julelang/julec-ir/main/src/$target.cpp"
}

function get_compile_command() {
	ret=$(curl -fsSL "https://raw.githubusercontent.com/julelang/julec-ir/main/meta/$target.txt")
	ret="clang++ ${ret#* }"
}

function main() {
	log "getting latest jule@master source tree"
	if [[ -e "jule.zip" ]]; then
		panic "jule.zip is already exist in the current path"
	fi
	curl -Lkfo jule.zip https://github.com/julelang/jule/archive/refs/heads/master.tar.gz
	if [ $? -ne 0 ]; then
		panic "jule@master download failed"
	fi
	if [[ -e "jule-master" ]]; then
		panic "jule-master is already exist in the current path"
	fi
	tar -xzf jule.zip -C .
	rm jule.zip
	if [[ -e "jule" ]]; then
		panic "jule is already exist in the current path"
	fi
	mv jule-master jule

	log "getting latest Jule IR distribution..."
	cd jule
	get_ir_url
	curl -fo ir.cpp $ret
	if [ $? -ne 0 ]; then
		panic "IR download failed"
	fi

	log "compiling the Jule compiler..."
	if [ ! -d "bin" ]; then
		mkdir bin
	fi
	get_compile_command
	$ret
	if [[ $? == 0 ]]; then
		log "your Jule compiler is ready to use"
	else
		panic "compilation failed, check errors above"
	fi
	if [ -f "ir.cpp" ]; then
		rm ir.cpp
	fi
}

function init() {
	init_arch
	init_os

	get_target_string
	target=$ret
	ret=$unknown

	check_target
}

init
main
