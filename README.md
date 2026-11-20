# AERA Recovery Device Tree for POCO F8 Pro (`annibale`)

Device tree for building **AERA Recovery (Android 16 / `aera-16.0`)** for the **Xiaomi POCO F8 Pro** (`annibale`), powered by Qualcomm Snapdragon 8 Elite (`SM8750` / `sun`).

## Device Specifications

| Spec | Details |
| :--- | :--- |
| Device | POCO F8 Pro (`annibale`) |
| SoC | Qualcomm SM8750-AB Snapdragon 8 Elite (3 nm) |
| Board / Platform | `sun` / `xiaomi_sm8750` |
| CPU | Octa-core Oryon V2 (2x 4.32 GHz + 6x 3.53 GHz) |
| GPU | Adreno 830 |
| Kernel | Prebuilt GKI 6.6 (`6.6.77-android15-8`, 4 KiB pages, boot header v4) |
| Storage | UFS 4.1 (Virtual A/B, dedicated `recovery_a`/`recovery_b`) |
| Super Partition | `11811160064` bytes (`qti_dynamic_partitions`) |
| Recovery Partition | `104857600` bytes (100 MiB) |
| Battery | 6210 mAh |

## Build Instructions

1. Sync the AERA Recovery 16.0 manifest:

```bash
mkdir -p ~/android/AERA_16.0
cd ~/android/AERA_16.0
repo init -u https://github.com/AERA-Recovery/android_manifest.git -b aera-16.0
repo sync -c --force-sync --no-clone-bundle --no-tags -j$(nproc)
```

2. Clone this device tree into `device/xiaomi/annibale`:

```bash
git clone -b aera-16.0 \
  https://github.com/annibale-devs/android_device_xiaomi_annibale-AERA.git \
  device/xiaomi/annibale
```

3. Build AERA Recovery:

```bash
source build/envsetup.sh
lunch twrp_annibale-bp2a-eng
mka adbd recoveryimage
```

Output image will be generated at `out/target/product/annibale/recovery.img`.

## Notes

- **Graphics**: Uses AERA's default software renderer fallback until `annibale`-matched stock Adreno 830 EGL/GLES and SnapAlloc blobs are extracted.
- **Root Manager**: Enabled via `AERA_ENABLE_ROOT_MANAGER=1` with `AERA_ROOT_MODULE_KERNELS := 6.6`.
- **Optional bring-up**: Wi-Fi (`AERA_ENABLE_WLAN`), audio bridge, and AIDL haptics (`FIXED_HAPTICS := true`) can be enabled once stock `annibale` firmware/configs are verified on device.
