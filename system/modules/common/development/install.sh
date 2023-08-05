#!/bin/bash -e

pkg diffutils upx dhex sysstat gdb svgcleaner tokei `# General use` \
    code code-marketplace `# IDE` \
    jdk-openjdk openjdk-src `# Java` \
    go nvm bash-language-server `# Langs/Platforms` \
    sdl2 glu `# Game dev` \
    cmake ccache cppcheck clang lld lldb `# C++` \
    rustup cargo-make mold `# Rust` \
    openbsd-netcat ghidra psvita-sdk vita-parse-core-git  `# Vita` \


