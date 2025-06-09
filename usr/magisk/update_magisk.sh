#!/bin/bash
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ver="$(cat "$DIR/magisk_version" 2>/dev/null || echo -n '')"
nver="v29.0"
echo "Updating Magisk from '$ver' to '$nver'"

curl -s -L "https://github.com/topjohnwu/Magisk/releases/download/$nver/Magisk-$nver.zip" -o "$DIR/magisk.zip"
unzip -o "$DIR/magisk.zip" -d "$DIR"

# استخراج magiskinit
for path in arm/magiskinit64 lib/arm64-v8a/libmagiskinit.so lib/armeabi-v7a/libmagiskinit.so; do
  if [ -f "$DIR/$path" ]; then
    mv -f "$DIR/$path" "$DIR/magiskinit"
    break
  fi
done
if [ ! -f "$DIR/magiskinit" ]; then
  echo "❌ magiskinit not found in zip"
  exit 11
fi

# استخراج stub إن وجد
[ -f "$DIR/assets/stub.apk" ] && mv -f "$DIR/assets/stub.apk" "$DIR/stub"

echo -n "$nver" > "$DIR/magisk_version"
rm -f "$DIR/magisk.zip"
touch "$DIR/initramfs_list"
echo "✅ Magisk $nver prepared."
