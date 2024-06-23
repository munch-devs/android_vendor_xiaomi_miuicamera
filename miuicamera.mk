# Configs
PRODUCT_COPY_FILES += \
    $(call find-copy-subdir-files,*,vendor/xiaomi/miuicamera/configs,$(TARGET_COPY_OUT_SYSTEM)/etc)

PRODUCT_PACKAGES += \
    libgui_shim_miuicamera

# Props
PRODUCT_SYSTEM_PROPERTIES += \
    persist.vendor.camera.privapp.list=com.android.camera \
    ro.com.google.lens.oem_camera_package=com.android.camera \
    ro.miui.notch=1 \
    ro.hardware.camera=xiaomi

# Sepolicy
BOARD_VENDOR_SEPOLICY_DIRS += \
	vendor/xiaomi/miuicamera/sepolicy/vendor

$(call inherit-product, vendor/xiaomi/miuicamera/miuicamera-vendor.mk)

