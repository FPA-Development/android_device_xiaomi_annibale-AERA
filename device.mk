#
# Copyright (C) 2023 The Android Open Source Project
# Copyright (C) 2026 AERA Recovery Project contributors
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/annibale

# Base product configuration
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)

# Virtual A/B OTA configuration
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression_with_xor.mk)

# Emulated storage support
$(call inherit-product, $(SRC_TARGET_DIR)/product/emulated_storage.mk)

# Configure twrp common.mk
$(call inherit-product, vendor/twrp/config/common.mk)

# Device-specific AERA configuration
$(call inherit-product, $(DEVICE_PATH)/aera_annibale.mk)

# Dynamic partition tools
PRODUCT_PACKAGES += \
    lpflash \
    lpmake \
    lpunpack

# OEM OTA certificate
PRODUCT_EXTRA_RECOVERY_KEYS += \
    vendor/recovery/security/miui

# Shipping API level (SM8750 / Android 15 GKI 6.6, 4 KiB pages)
PRODUCT_SHIPPING_API_LEVEL := 35
PRODUCT_TARGET_VNDK_VERSION := 35
BOARD_SHIPPING_API_LEVEL := 35
SHIPPING_API_LEVEL := 35
PRODUCT_CHECK_PREBUILT_MAX_PAGE_SIZE := false

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# FUSE passthrough
PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.fuse.passthrough.enable=true

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += $(DEVICE_PATH)
