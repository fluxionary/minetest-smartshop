#!/usr/bin/env bash
cd "$(dirname "$0")"

rm -rf mods
mkdir mods

git clone https://github.com/fluxionary/minetest-fmod.git mods/fmod
git clone https://github.com/fluxionary/minetest-futil.git mods/futil
