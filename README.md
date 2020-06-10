# What am I looking at?

This repository consists of the following:

- `system.sh` script which allows to (kind of) idempotently set up and update all packages and configs I need on Archlinux. This script is used daily by me only on 64 bit intel CPU's with systemd-boot EFI bootloader.
- `user.sh` script which set's up convential dotfiles with configurations for all software I use as a non-root user. Essentially this is a bootstrap of the usual dotfiles.
- A magical `bluetooth-key-sync.sh` shell script, which copies bluetooth connection keys from a Windows neighbour partition. This allows me to connect all of my bluetooth devices, such as a headset, only once on a dual-boot setup. The alternative solution would be changing my bluetooth MAC address on Linux (not a great solution since headsets usually can be connected to a limited number of MAC's).

# What's the purpose of all this?

I'm too lazy to try Nix, and too sick of setting up my linux manually again and again when I buy new hardware or change job.
