#
# Copyright (C) 2023 The Android Open Source Project
# Copyright (C) 2026 AERA Recovery Project contributors
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/annibale

# Inherit from device.mk configuration
$(call inherit-product, $(DEVICE_PATH)/device.mk)

# Release name
PRODUCT_RELEASE_NAME := annibale

# Device identifier
PRODUCT_DEVICE := annibale
PRODUCT_NAME := twrp_annibale
PRODUCT_BRAND := POCO
PRODUCT_MODEL := POCO F8 Pro
PRODUCT_MANUFACTURER := Xiaomi

# Assert
TARGET_OTA_ASSERT_DEVICE := annibale

# Theme
AERA_STATUS_ICONS_ALIGN := center

# StrongBox Device Decryption
AERA_INCLUDE_OMAPI := true
