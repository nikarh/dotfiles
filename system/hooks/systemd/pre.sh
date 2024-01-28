#!/bin/bash -e

function enable-unit {
    if [[ "$(systemctl is-enabled "${@: -1}")" == "enabled" ]]; then
        return
    fi

    sudo systemctl enable $@

}

function disable-unit {
    if [[ "$(systemctl is-enabled "${@: -1}")" == "disabled" ]]; then
        return
    fi

    sudo systemctl enable $@
}
