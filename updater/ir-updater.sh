#!/bin/bash
# Copyright 2023 The Jule Programming Language.
# Use of this source code is governed by a BSD 3-Clause
# license that can be found in the LICENSE file.

mkdir ir_updater
curl -o ir_updater/main.jule https://raw.githubusercontent.com/julelang/julec-ir/main/updater/main.jule
julec -o ir_updater/updater ir_updater

./ir_updater/updater

echo "Cleaning..."
rm -rf ir_updater

if [ $? -eq 0 ]; then
    echo "IRs updated successfully"
    exit 0
else
    echo "Some problem(s) occurred when IRs updating"
    exit 1
fi
