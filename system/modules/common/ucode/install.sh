#!/bin/bash -e

CPU_MODEL=$(grep model\ name /proc/cpuinfo | head -n 1)
if grep -qi amd <<< "$CPU_MODEL"; then
    pkg amd-ucode
elif grep -qi intel <<< "$CPU_MODEL"; then
    pkg intel-ucode intel-media-driver libva-intel-driver
fi