#!/bin/sh
#
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: ISC
#
# dhcp_wan_renew.sh - OpenWrt/QSDK adaptor for WAN DHCP renew after 802.1X success
#
# Deploy target:
#   /etc/802.1x/dhcp_wan_renew.sh
#
# This script is intentionally small and platform-specific.
# It is invoked by the policy layer script (8021x_action.sh).
#
# Behavior:
#   - Trigger netifd renew for both IPv4 (wan) and IPv6 (wan6)
#   - Return non-zero on failure so caller can log it

set -u

LOG_TAG="${LOG_TAG:-dhcp_wan_renew}"

log_msg() {
  logger -t "$LOG_TAG" "$*"
}

# Basic sanity check
if ! command -v ubus >/dev/null 2>&1; then
  log_msg "ERROR: ubus not found"
  exit 127
fi

rc=0

error_msg=""

# IPv4 renew
if ubus list network.interface.wan >/dev/null 2>&1; then
  if ! ubus call network.interface.wan renew >/dev/null 2>&1; then
    rc=1
    error_msg="${error_msg}wan "
  fi
fi

# IPv6 renew
if ubus list network.interface.wan6 >/dev/null 2>&1; then
  if ! ubus call network.interface.wan6 renew >/dev/null 2>&1; then
    rc=1
    error_msg="${error_msg}wan6 "
  fi
fi

if [ "$rc" -ne 0 ]; then
  log_msg "ERROR: ubus renew failed for: $error_msg"
  exit 1
fi

log_msg "OK: ubus renew triggered (wan/wan6)"
exit 0
