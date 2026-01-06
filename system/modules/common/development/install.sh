#!/bin/bash -e

pkg diffutils upx dhex sysstat gdb svgcleaner tokei strace `# General use` \
    code code-marketplace code-features `# IDE` \
    dive `# explore docker image contents` \
    mise `# Langs/Platforms` \
    cmake ccache cppcheck clang lld lldb `# C++` \
    rustup mold wild zig `# Rust` \
    git-cliff \
    postgresql \
    env-secrets-bin


if [ -n "$ARGS_game" ]; then
    pkg diffutils sdl2 glu aseprite-git
fi

if [ -n "$ARGS_vita" ]; then
    pkg ghidra vitasdk-git vitasdk-packages-git vita-parse-core-git vita3k-bin
fi

if [ -n "$ARGS_cad" ]; then
    pkg freecad openscad-bosl2-git openscad-git
fi
