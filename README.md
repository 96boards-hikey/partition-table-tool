# HiKey960 Ptable Tool

## Description
This is an independent tool with source code to generate partition table image (traditionally, it's named ```ptable.img```) for HiKey960 board. It can be integrated into Android Source code or used independently on linux pc.

## Usage
Step 1: Edit ```struct partition partition_table_ufs[]``` in ```partition.h``` to define partition layout, names and sizes. Please also read Note 1 below.

Step 2: Build the tool ```efipartition```.

```make```

Step 3: Generate a partition image: ```ptable.img```.

```efipartition ptable.img```

Step 4: Flash ptable.img to the board. Then flash other images.
1) DIP 1 & 3 ON, DIP 2 OFF: put board into [fastboot mode](https://github.com/96boards-hikey/tools-images-hikey960/blob/master/README.md#step-1-materials-and-preperations),
2) ```fastboot flash ptable ptable.img```
3) Reboot the board. Power cycle it.
4) Flash other images which has been impacted by ptable changes. As a super set, ideally, you'd better flash all these below:
```
# bootloader
fastboot flash xloader ${IMG_FOLDER}/sec_xloader.img
fastboot flash fastboot ${IMG_FOLDER}/fastboot.img

# extra images
fastboot flash nvme   ${IMG_FOLDER}/nvme.img
fastboot flash fw_lpm3   ${IMG_FOLDER}/lpm3.img
fastboot flash trustfirmware   ${IMG_FOLDER}/bl31.bin
```
5) Proceed to [OS installation](https://github.com/96boards-hikey/tools-images-hikey960/blob/master/README.md#step-5-explore-other-modes-proceed-to-os-installation). Read Note 2 below to learn how in case you need to rebuild OS and user land images.

## How it works
Overall, ptable.img structure is as this:
```
/*------------------------|
 |          emmc          | 128K bytes
 *------------------------|
 |        ufs lu0         | 17K bytes
 *----------------------- |
 |        ufs lu1         | 17K bytes
 *----------------------- |
 |        .......         |
 *----------------------- |
 |        ufs lu6         | 17K bytes
 *----------------------- |
 |        ufs lu7         | 17K bytes
 *----------------------- |
*/
```

In order to be more general, ptable.img is made to support both emmc and ufs. It contains a 128KB emmc ptable at the beginning, then followed by UFS ptables.

## Note
1. In ```struct partition partition_table_ufs[]``` in ```partition.h```, Entries from ```PART_XLOADER_A``` to ```PART_NVME``` (inclusive) shall not be modified. They are correlated with [xloader](https://github.com/96boards-hikey/tools-images-hikey960/blob/master/sec_xloader.img). Changing of them must be done together with xloader.
```
  {PART_XLOADER_A,        0,         2*1024,          UFS_PART_0},
  {PART_XLOADER_B,        0,         2*1024,          UFS_PART_1},
  {PART_PTABLE,           0,         1024,            UFS_PART_2},/* ptable          512K */
  {PART_FRP,              1024,      7*1024,          UFS_PART_2},/* frp             512K   p1*/
  {PART_PTABLE_LU3,       0,         1024,            UFS_PART_3},/* ptable_lu3    1M    sdd  */
  {PART_XLOADER_RESERVED1,1024,       512,            UFS_PART_3},/* vrl             512K   sdd1*/
  {PART_XLOADER_RESERVED2,1536,      512,             UFS_PART_3},/* vrl backup      512K   sdd2*/
  {PART_FASTBOOT,         2*1024,      12*1024,       UFS_PART_3},/* fastboot      12M   sdd3 */
  {PART_NVME,             14*1024,   6*1024,          UFS_PART_3},/* nvme          6M    sdd4 */
  ```
2. User space, mounting points need to be updated accordingly.

    * For Android, please change ```[AOSP]/device/linaro/hikey/hikey960/fstab.hikey960```
    * For Debian, please change ```/etc/fstab```
