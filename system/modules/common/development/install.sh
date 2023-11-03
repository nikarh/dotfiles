#!/bin/bash -e

pkg diffutils upx dhex sysstat gdb svgcleaner tokei `# General use` \
    code code-marketplace `# IDE` \
    jdk-openjdk openjdk-src `# Java` \
    go nvm bash-language-server `# Langs/Platforms` \
    sdl2 glu `# Game dev` \
    cmake ccache cppcheck clang lld lldb `# C++` \
    rustup cargo-make mold `# Rust` \
    ghidra vitasdk-git vitasdk-packages-git vita-parse-core-git vita3k-bin `# Vita` \
