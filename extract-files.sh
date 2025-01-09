#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=miuicamera
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

export TARGET_ENABLE_CHECKELF=true

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

KANG=
SECTION=

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        -n | --no-cleanup )
                CLEAN_VENDOR=false
                ;;
        -k | --kang )
                KANG="--kang"
                ;;
        -s | --section )
                SECTION="${2}"; shift
                CLEAN_VENDOR=false
                ;;
        * )
                SRC="${1}"
                ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        system/lib64/libcamera_algoup_jni.xiaomi.so)
            [ "$2" = "" ] && return 0
            grep -q "libgui_shim_miuicamera.so" "${2}" || "${PATCHELF}" --add-needed libgui_shim_miuicamera.so "${2}"
            "${SIGSCAN}" -p "08 AD 40 F9" -P "08 A9 40 F9" -f "${2}"
            ;;
        system/lib64/libcamera_mianode_jni.xiaomi.so)
            [ "$2" = "" ] && return 0
            grep -q "libgui_shim_miuicamera.so" "${2}" || "${PATCHELF}" --add-needed libgui_shim_miuicamera.so "${2}"
            ;;
        system/lib64/libmicampostproc_client.so)            
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --remove-needed libhidltransport.so "${2}"
            ;;
        vendor/bin/hw/android.hardware.camera.provider@2.4-service_64 | vendor/lib/android.hardware.camera.provider@2.4-legacy.so | vendor/lib/camera.device@1.0-impl.so | vendor/lib64/android.hardware.camera.provider@2.4-legacy.so | vendor/lib64/camera.device@1.0-impl.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "vendor.qti.hardware.camera.device@1.0.so" "vendor.qti.hardware.camera.device@1.0_vendor.so" "${2}"
            ;;
        *)
            return 1
            ;;
    esac

    return 0
}

function blob_fixup_dry() {
    blob_fixup "$1" ""
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"

"${MY_DIR}/setup-makefiles.sh"
