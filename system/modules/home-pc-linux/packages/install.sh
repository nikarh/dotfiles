#!/bin/bash -e

pkg stressapptest \
    moonlight-qt busybox flatpak qtqr \
    kicad \
    virtualbox virtualbox-guest-iso virtualbox-guest-utils \
    \
    bluedevil plasma-disks plasma-firewall plasma-nm plasma-pa plasma-sdk \
    plasma-systemmonitor plasma-thunderbolt plasma-vault plasma-welcome plasma-workspace-wallpapers \
    plasma-browser-integration plasma-desktop plymouth-kcm \
    kde-gtk-config kdeplasma-addons kgamma5 khotkeys kscreen ksshaskpass kwallet-pam kwayland-integration kwrited \
    drkonqi discover oxygen
