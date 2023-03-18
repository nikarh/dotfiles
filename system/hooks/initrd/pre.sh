#!/bin/bash -e

export REBUILD_INITRD=0

function add-module-to-initrd {
    if ! grep -q "^MODULES.*${1}" /etc/mkinitcpio.conf; then
        sudo sed -E -i "s/^(MODULES=\()(.*)/\1${1} \2/; s/^(MODULES.*) (\).*)/\1\2/" /etc/mkinitcpio.conf
        export REBUILD_INITRD=1
    fi
}

function remove-module-from-initrd {
    if grep -q "^MODULES.*${1}" /etc/mkinitcpio.conf; then
        sudo sed -E -i "s/^(MODULES=\()(.*)${1}(.*)/\1\2\3/; s/^(MODULES=\() (.*)/\1\2/; s/^(MODULES=\(.*) \)/\1)/" /etc/mkinitcpio.conf
        export REBUILD_INITRD=1
    fi
}
