#!/bin/bash -e -o pipefail
source ~/utils/utils.sh

# What is this for?
# This script fixes an issue appeared for some brew users where brew upgrade
# would return an error code. This is caused by the official macOS
# Python installers which install files into /usr/local/bin, and some
# go installer which installs files into /usr/local/bin....
#
# What it does?
# The script looks for files in /usr/local/bin that are not links to
# ../Cellar/* or ../Homebrew/* and replaces them with
# equivalent symlinks in /usr/local/bin/.brew-shims.
#
# License
# Distributed by MIT license.

echo "Tweaking usr/local/bin Tooling"

SHIMS=.brew-shims

shim() {
    file=$(basename "$1")
    mkdir -p "$SHIMS"
    ln -s "$2" "$SHIMS/$file"
    sudo rm -f "$file"
    ln -s "$SHIMS/$file" .
}

(
    cd /usr/local/bin
    for file in $(find . -mindepth 1 -maxdepth 1 -type l); do
        destination=$(readlink "$file")
        case "$destination" in
            ../Cellar/*)
            ;;
            ../Homebrew/*)
            ;;
            /*)
                shim "$file" "$destination"
            ;;
            *)
                shim "$file" "../$destination"
            ;;
        esac
    done
)

invoke_tests "Python"
