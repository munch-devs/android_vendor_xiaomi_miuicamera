#!/bin/bash

MIUICAMERA_DIR="vendor/xiaomi/miuicamera/proprietary/system/priv-app/MiuiCamera"
MIUICAMERA_APK="${MIUICAMERA_DIR}/MiuiCamera.apk"

if [ -f "${MIUICAMERA_APK}.part00" ]; then
    cat "${MIUICAMERA_APK}.part"* > "${MIUICAMERA_APK}"
    rm -f "${MIUICAMERA_APK}.part"*
fi