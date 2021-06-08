#!/bin/bash -e
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

section "Linking configs..."
cp -frsTv "$ROOT/user/" ~ | prepend '  '

section "Downloading random stuff from the internet..."
git-get https://github.com/mrzool/bash-sensible.git \
    ~/.config/bash-sensible | prepend '  '