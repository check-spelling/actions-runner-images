#!/bin/bash -e -o pipefail
source ~/utils/utils.sh

# What is this for?
# This script fixes an issue appeared for some brew users where brew upgrade
# would return an error code. This is caused by the official macOS
# Python installers which install files into /usr/local/bin.
#
# What it does?
# The script looks for files in /usr/local/bin that are links to
# ../../../Library/Frameworks/Python.framework/* and replaces them with
# equivalent symlinks in /usr/local/bin/.python-brew-shims.
#
# License
# Distributed by MIT license.

echo "Tweaking Python Tooling"

SHIMS=.python-brew-shims

(
    cd /usr/local/bin
    for file in $(find . -mindepth 1 -maxdepth 1 -type l); do
        destination=$(readlink "$file")
        case "$destination" in
            ../../../Library/Frameworks/Python.framework/*)
                mkdir -p "$SHIMS"
                ln -s "../$destination" "$SHIMS/$file"
                sudo rm -f "$file"
                ln -s "$SHIMS/$file" .
            ;;
        esac
    done
)

invoke_tests "Python"
