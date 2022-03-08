#!/bin/sh

# SPDX-FileCopyrightText: 2021 vgaetera <https://openwrt.org/user/vgaetera>
# SPDX-FileContributor: Modified by Yuta Aoyagi <https://github.com/yuta-aoyagi> in 2022
#
# SPDX-License-Identifier: CC-BY-SA-4.0
#
# Unless otherwise separately undertaken by the Licensor, to the extent possible, the Licensor offers the Licensed Material as-is and as-available, and makes no representations or warranties of any kind concerning the Licensed Material, whether express, implied, statutory, or other.
#
# This shell script is a modified version of a section `Resizing partitions' and `Resizing Ext4 rootfs' in an Web page <https://openwrt.org/docs/guide-user/installation/openwrt_x86>, which is licensed under CC-BY-SA-4.0 <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.

# @(#)expand-rootfs.sh: expands the second partition and resizes the rootfs in it

# Some other projects (autoconf & shunit2) say `expr` is more portable than
# $(()).
# shellcheck disable=2003
# They also say `` is more portable than $().
# shellcheck disable=2006

opkg update
opkg install fdisk losetup resize2fs

boot_part() {
  sed -n '/[	 ]\/boot[	 ].*$/ {
    s///p
    q
    }' /etc/mtab
}

BOOT=`boot_part`

println_boot() {
  printf %s\\n "$BOOT"
}

DISK=`println_boot | sed 's/[0-9].*$//'`
PART=`println_boot | sed 's/.*[^0-9]//'`
PART=`expr "$PART" + 1`
export ROOT
ROOT=$DISK$PART

"$@" # Before fdisk, run the given command as a hook.

filter_root() {
  sed -n "\\|^${ROOT}[	 ]*|s///p"
}

OFFS=`fdisk -lo device,start "$DISK" | filter_root`
printf "p\\nd\\n%s\\nn\\np\\n%s\\n%s"'\n\np\nw\n' "$PART" "$PART" "$OFFS" |
  fdisk "$DISK"

LOOP=`losetup -f`
losetup "$LOOP" "$ROOT"
fsck.ext4 -y "$LOOP" || [ $? = 1 ] || exit
resize2fs "$LOOP"
reboot
