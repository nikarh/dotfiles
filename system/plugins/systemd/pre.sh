#!/bin/bash -e

function enable-service {
    if [[ "$(systemctl is-enabled "${@: -1}")" == "enabled" ]]; then
        return
    fi

    sudo systemctl enable $@

}

function disable-service {
    if [[ "$(systemctl is-enabled "${@: -1}")" == "disabled" ]]; then
        return
    fi

    sudo systemctl enable $@
}
