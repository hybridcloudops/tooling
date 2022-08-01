#!/bin/bash
# copies go binaries to this directory
# designed to run with my personal setup

codebase_dir="$(dirname "$(pwd)")/.."
bin_dir=$(pwd)

legacyctl_dir="$codebase_dir/legacyctl/legacyctl"
legacyctld_dir="$codebase_dir/legacyctl/legacyctld"
deployer_dir="$codebase_dir/deployer"

cp -f "$legacyctl_dir/legacyctl" "$bin_dir"
cp -f "$legacyctld_dir/legacyctld" "$bin_dir"
cp -f "$deployer_dir/bsc-deployer" "$bin_dir"
