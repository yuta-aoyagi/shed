#!/bin/sh

# SPDX-FileCopyrightText: 2021 vgaetera <https://openwrt.org/user/vgaetera>
# SPDX-FileContributor: Modified by Yuta Aoyagi <https://github.com/yuta-aoyagi> in 2022
#
# SPDX-License-Identifier: CC-BY-SA-4.0
#
# Unless otherwise separately undertaken by the Licensor, to the extent possible, the Licensor offers the Licensed Material as-is and as-available, and makes no representations or warranties of any kind concerning the Licensed Material, whether express, implied, statutory, or other.
#
# This shell script is a modified version of a part of an Web page <https://openwrt.org/docs/guide-user/network/openwrt_as_clientdevice#command-line_instructions>, which is licensed under CC-BY-SA-4.0 <https://creativecommons.org/licenses/by-sa/4.0/legalcode>.

# @(#)ifup.sh: configures initial DHCP client & starts lan up

uci set network.lan.proto=dhcp && uci commit network &&
  /etc/init.d/network restart
