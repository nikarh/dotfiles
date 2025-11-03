#!/bin/bash -e

pkg diffutils upx dhex sysstat gdb svgcleaner tokei strace `# General use` \
    code code-marketplace code-features `# IDE` \
    dive helm `# devops` \
    mise bash-language-server `# Langs/Platforms` \
    sdl2 glu `# Game dev` \
    cmake ccache cppcheck clang lld lldb `# C++` \
    rustup mold wild webkit2gtk zig `# Rust` \
    ghidra vitasdk-git vitasdk-packages-git vita-parse-core-git vita3k-bin `# Vita` \
    kchmviewer git-cliff \
    env-secrets-bin
