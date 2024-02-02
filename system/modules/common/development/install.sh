#!/bin/bash -e

pkg diffutils upx dhex sysstat gdb svgcleaner tokei strace `# General use` \
    code code-marketplace `# IDE` \
    jdk-openjdk openjdk-src `# Java` \
    go fnm-bin bun-bin bash-language-server `# Langs/Platforms` \
    sdl2 glu `# Game dev` \
    cmake ccache cppcheck clang lld lldb `# C++` \
    rustup mold webkit2gtk zig `# Rust` \
    ghidra vitasdk-git vitasdk-packages-git vita-parse-core-git vita3k-bin `# Vita` \
