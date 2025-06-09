#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

ver="$(cat $DIR/magisk_version 2>/dev/null || echo -n 'none')"

# This script is designed to update Magisk within a custom kernel build.
# It supports Magisk v26.x and is also compatible with Magisk v29.0 as the core
# extraction paths for magiskboot and magisk.zip remain consistent.
# Magisk v29.0 introduces XZ compression for module zip files, which is handled
# by Magisk itself and does not require changes in this extraction script.

if [ "x$1" = "xcanary" ]
then
    nver="canary"
    magisk_link="https://github.com/topjohnwu/magisk-files/raw/${nver}/app-debug.apk"
elif [ "x$1" = "xalpha" ]
then
    nver="alpha"
    magisk_link="https://github.com/vvb2060/magisk_files/raw/${nver}/app-release.apk"
else
    dash='-'
    if [ "x$1" = "x" ]; then
        nver="$(curl -s https://github.com/topjohnwu/Magisk/releases | grep -m 1 -Poe 'Magisk v[\d\.]+' | sed -r 's/Magisk v([\d\.]+)/\1/')"
    else
        nver="$1"
    fi

    if [ "$nver" = "v26.3" ]; then
        dash='.'
    fi

    magisk_link="https://github.com/topjohnwu/Magisk/releases/download/${nver}/Magisk${dash}${nver}.apk"
fi

if [ "$ver" = "$nver" ]; then
    echo "Magisk version $ver is already installed. Nothing to do."
    exit 0
fi

if [ "$nver" = "none" ]; then
    echo "Cannot determine Magisk version. Please specify it as an argument (e.g., ./update_magisk.sh v26.3)"
    exit 1
fi

if [ ! -f "$DIR/magisk.apk" ]; then
    echo "Downloading Magisk $nver..."
    curl -L "$magisk_link" -o "$DIR/magisk.apk"
fi

if [ ! -f "$DIR/magisk.apk" ]; then
    echo "Failed to download Magisk $nver."
    exit 1
fi

# Extract magiskboot
if [ ! -f "$DIR/magiskboot" ]; then
    echo "Extracting magiskboot..."
    unzip -o "$DIR/magisk.apk" lib/arm64-v8a/libmagiskboot.so -d "$DIR"
    mv "$DIR/lib/arm64-v8a/libmagiskboot.so" "$DIR/magiskboot"
    rm -rf "$DIR/lib"
    chmod +x "$DIR/magiskboot"
fi

# Extract magisk.apk to magisk.zip
if [ ! -f "$DIR/magisk.zip" ]; then
    echo "Extracting magisk.zip..."
    unzip -o "$DIR/magisk.apk" assets/magisk.zip -d "$DIR"
    mv "$DIR/assets/magisk.zip" "$DIR/magisk.zip"
    rm -rf "$DIR/assets"
fi

# Update magisk_version file
echo "$nver" > "$DIR/magisk_version"

echo "Magisk updated to $nver."


