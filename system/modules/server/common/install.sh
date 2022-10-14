#!/bin/bash -e

sudo cp -ufrTv "$ROOT/root/var/" /var
sudo chown -R 1000:1000 /var/lib/{traefik,authelia}
