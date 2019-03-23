#!/bin/bash
if [[ "$1" == "--release" ]]; then
    make -C linux_fde/release && ./build/linux_fde/release/viktoria_flutter
else
    make -C linux_fde/debug && ./build/linux_fde/debug/viktoria_flutter
fi