#!/bin/bash

# تحقق من وجود ملف zip لـ Magisk
if [ $# -lt 1 ]; then
    echo "Usage: $0 <magisk-zip-file>"
    exit 1
fi

ZIP="$1"
MAGISKDIR="usr/magisk"

# أنشئ المجلد إذا لم يكن موجودًا
mkdir -p "$MAGISKDIR"

# استخراج الملفات المطلوبة
echo "Extracting files from $ZIP..."

# استخراج الملفات إلى مجلد مؤقت
TMPDIR=$(mktemp -d)
unzip -q "$ZIP" -d "$TMPDIR"

# استخراج magiskinit (init)
cp "$TMPDIR/lib/arm64-v8a/libmagiskinit.so" "$MAGISKDIR/magiskinit"
chmod 0755 "$MAGISKDIR/magiskinit"

# استخراج magisk64 وضغطه
cp "$TMPDIR/lib/arm64-v8a/libmagisk64.so" "$MAGISKDIR/magisk64"
xz -f -k "$MAGISKDIR/magisk64"
mv "$MAGISKDIR/magisk64.xz" "$MAGISKDIR/magisk64.xz"

# استخراج magisk32 وضغطه
cp "$TMPDIR/lib/armeabi-v7a/libmagisk32.so" "$MAGISKDIR/magisk32"
xz -f -k "$MAGISKDIR/magisk32"
mv "$MAGISKDIR/magisk32.xz" "$MAGISKDIR/magisk32.xz"

# استخراج stub وضغطه
unzip -p "$ZIP" assets/stub.apk > "$MAGISKDIR/stub"
xz -f -k "$MAGISKDIR/stub"
mv "$MAGISKDIR/stub.xz" "$MAGISKDIR/stub.xz"

# إنشاء ملف النسخة
MAGISK_VER=$(unzip -p "$ZIP" assets/util_functions.sh | grep -oP '(?<=MAGISK_VER=).*' | tr -d '"')
echo "$MAGISK_VER" > "$MAGISKDIR/magisk_version"

# ملف نسخ احتياطي فارغ
touch "$MAGISKDIR/backup_magisk"
chmod 0705 "$MAGISKDIR/backup_magisk"

# تنظيف الملفات المؤقتة
rm -rf "$TMPDIR" "$MAGISKDIR/magisk32" "$MAGISKDIR/magisk64" "$MAGISKDIR/stub"

echo "Done. Magisk updated to version: $MAGISK_VER"
