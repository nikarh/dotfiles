# What am I looking at?

This repository contains:

- Shell script `system.sh` which allows to (kind of) idemptoently set up and update all packages and configs I need on archlinux.
- Makefile which set's up convential dotfiles with configurations for all software I use


## My bootloader flags

- MSI laptop
```bash
i915.modeset=1  `# KMS for plymouth`
i915.fastboot=1 `# Flicker free KMS`
rd.udev.log-priority=3 rd.systemd.show_status=0 vt.global_cursor_default=0 loglevel=3 quiet splash `# Plymouth`
ec_sys.write_support=1 `# Fan control`
nmi_watchdog=0 `# Disable kernel freezes checks`
acpi_osi=! acpi_osi="!Windows 2009" # Might actually be useless right now
```