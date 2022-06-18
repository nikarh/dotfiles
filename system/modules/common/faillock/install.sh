#!/bin/bash -e

require-arg "conf"

sudo mkdir -p /etc/security
echo -en "$ARGS_conf" | sudo tee /etc/security/faillock.conf > /dev/null