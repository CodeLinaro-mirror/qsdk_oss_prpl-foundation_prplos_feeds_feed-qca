#!/bin/sh
#
# Copyright (c) Qualcomm Technologies, Inc. and/or its subsidiaries.
# SPDX-License-Identifier: ISC
#
# 802.1X action script for wired supplicant (QSDK/OpenWrt)
#
# Deploy target:
#   /etc/802.1x/8021x_action.sh
#
# Trigger model:
#   wpa_cli -i <ifname> -p /var/run/wpa_supplicant -a /etc/802.1x/8021x_action.sh -B
#
# Invocation arguments:
#   $1=<ifname>, $2=<event>  (e.g. "eth0 CTRL-EVENT-EAP-SUCCESS")
#   IFNAME/WPA_IFNAME env vars are NOT reliably set.
#
# Policy:
#   1. Main triggers: CTRL-EVENT-EAP-SUCCESS, CTRL-EVENT-EAP-SUCCESS2
#   2. Auxiliary trigger: CONNECTED(CTRL-EVENT-CONNECTED) (for initial bring-up confirmation)
#   3. Gate on suppPortStatus=Authorized (timeout: 3s default)
#   4. 10-second throttling window + tail-trigger (per-ifname)
#   5. If gating passes: call adaptor script to trigger DHCP renew
#
# Logging:
#   - Syslog always

set -u

# ============================================================================
# Configuration (Environment Variables)
# ============================================================================

# Authorized gating timeout (seconds)
GATING_TIMEOUT_SEC="${GATING_TIMEOUT_SEC:-3}"

# Throttling window (seconds)
THROTTLE_WINDOW_SEC="${THROTTLE_WINDOW_SEC:-10}"

# Adaptor script path (platform-specific DHCP renew)
RENEW_SCRIPT="${RENEW_SCRIPT:-/etc/802.1x/dhcp_wan_renew.sh}"


# Must match -p used by wpa_cli listener in 8021x-client
WPA_CTRL_DIR="${WPA_CTRL_DIR:-/var/run/wpa_supplicant}"

STATE_DIR="${STATE_DIR:-/tmp/8021x_state}"

# lock stale timeout (seconds)
LOCK_TIMEOUT_SEC="${LOCK_TIMEOUT_SEC:-60}"

# =============================================================================
# Input
# =============================================================================

IFNAME="${1:-}"
EVENT="${2:-}"

# =============================================================================
# Logging
# =============================================================================

log_msg() {
  msg="$1"
  logger -t 8021x_action "$msg"
}

# =============================================================================
# Lock (file: "<pid> <ts>")
# =============================================================================

acquire_lock() {
  lock_file="$1"
  timeout="${2:-60}"
  now_ts=$(date +%s)

  # Atomic lock creation (noclobber ensures exclusive creation)
  if (set -o noclobber; echo "$$ $now_ts" > "$lock_file") 2>/dev/null; then
    return 0
  fi

  # Lock exists, check if stale
  if [ -f "$lock_file" ]; then
    lock_pid=$(awk '{print $1}' "$lock_file" 2>/dev/null || echo "")
    lock_ts=$(awk '{print $2}' "$lock_file" 2>/dev/null || echo "")

    # Check if lock holder is alive
    if [ -n "$lock_pid" ] && kill -0 "$lock_pid" 2>/dev/null; then
      return 1
    fi

    # Check timeout
    if [ -n "$lock_ts" ] && echo "$lock_ts" | grep -Eq '^[0-9]+$'; then
      age=$((now_ts - lock_ts))
      if [ "$age" -lt "$timeout" ]; then
        return 1
      fi
    else
      # Invalid or missing timestamp, treat as stale
      log_msg "LOCK: invalid timestamp in $lock_file, treating as stale"
    fi

    log_msg "LOCK: removing stale lock $lock_file (pid=$lock_pid ts=$lock_ts)"
    rm -f "$lock_file" 2>/dev/null || true

    # Retry atomic creation
    if (set -o noclobber; echo "$$ $now_ts" > "$lock_file") 2>/dev/null; then
      return 0
    fi
  fi

  return 1
}

release_lock() {
  lock_file="$1"
  if [ -f "$lock_file" ]; then
    lock_pid=$(awk '{print $1}' "$lock_file" 2>/dev/null || echo "")
    if [ "$lock_pid" = "$$" ]; then
      rm -f "$lock_file" 2>/dev/null || true
    fi
  fi
}

# =============================================================================
# State Helpers
# =============================================================================

# Read state variables into global scope
read_state() {
  file="$1"
  if [ -f "$file" ]; then
    # Read once to reduce I/O
    content=$(cat "$file" 2>/dev/null || echo "")
    LAST_TRIGGER_TS=$(echo "$content" | grep '^LAST_TRIGGER_TS=' | cut -d= -f2 | grep -E '^[0-9]+$' || echo 0)
    NEXT_TRIGGER_TS=$(echo "$content" | grep '^NEXT_TRIGGER_TS=' | cut -d= -f2 | grep -E '^[0-9]+$' || echo 0)
    TAIL_PID=$(echo "$content" | grep '^TAIL_PID=' | cut -d= -f2 | grep -E '^[0-9]+$' || echo 0)
  else
    LAST_TRIGGER_TS=0
    NEXT_TRIGGER_TS=0
    TAIL_PID=0
  fi
}

# =============================================================================
# Main
# =============================================================================

if [ -z "$IFNAME" ]; then
  exit 1
fi

case "$EVENT" in
  CTRL-EVENT-EAP-SUCCESS|CTRL-EVENT-EAP-SUCCESS2)
    # Primary triggers
    ;;
  CONNECTED)
    # Auxiliary trigger (initial bring-up confirmation)
    log_msg "CONNECTED event (auxiliary trigger)"
    ;;
  *)
    # Not a trigger event, exit silently
    exit 0
    ;;
esac

log_msg "ENTRY: ifname=$IFNAME event=$EVENT"

# -----------------------------------------------------------------------------
# Step 1: Authorized gating (CPU friendly, BusyBox friendly)
# -----------------------------------------------------------------------------

log_msg "GATING: start (timeout=${GATING_TIMEOUT_SEC}s)"

AUTHORIZED=0
i=0
while [ "$i" -lt "$GATING_TIMEOUT_SEC" ]; do
  # Use pipeline to avoid storing full status output in shell variable
  if wpa_cli -i "$IFNAME" -p "$WPA_CTRL_DIR" status 2>/dev/null | grep -q '^suppPortStatus=Authorized$'; then
    AUTHORIZED=1
    break
  fi
  sleep 1
  i=$((i + 1))
done

if [ "$AUTHORIZED" -ne 1 ]; then
  log_msg "GATING_TIMEOUT: not Authorized -> NO RENEW"
  exit 0
fi

log_msg "GATING_PASS: suppPortStatus=Authorized (ifname=$IFNAME)"

# -----------------------------------------------------------------------------
# Step 2: Strict tail-trigger throttle
# -----------------------------------------------------------------------------

# Ensure state directory exists
mkdir -p "$STATE_DIR" 2>/dev/null || true

STATE_FILE="$STATE_DIR/$IFNAME.state"
LOCK_FILE="$STATE_DIR/$IFNAME.lock"
STOP_FILE="$STATE_DIR/$IFNAME.stop"

NOW=$(date +%s)
TARGET_TS=$((NOW + THROTTLE_WINDOW_SEC))

# Acquire lock to update state
if ! acquire_lock "$LOCK_FILE" "$LOCK_TIMEOUT_SEC"; then
  sleep 1
  if ! acquire_lock "$LOCK_FILE" "$LOCK_TIMEOUT_SEC"; then
    log_msg "THROTTLE: locked, drop event"
    exit 0
  fi
fi
trap 'release_lock "$LOCK_FILE"' EXIT

# Load current state
read_state "$STATE_FILE"

ELAPSED=$((NOW - LAST_TRIGGER_TS))

if [ "$ELAPSED" -ge "$THROTTLE_WINDOW_SEC" ]; then
  # Window expired, trigger immediately
  log_msg "THROTTLE: window expired (elapsed=${ELAPSED}s >= ${THROTTLE_WINDOW_SEC}s) -> TRIGGER NOW"

  # Call adaptor script
  if [ -x "$RENEW_SCRIPT" ]; then
    "$RENEW_SCRIPT"
    rc=$?
    log_msg "RENEW_RESULT: $rc"
  else
    log_msg "ERROR: renew script not found: $RENEW_SCRIPT"
  fi

  LAST_TRIGGER_TS=$(date +%s)
  NEXT_TRIGGER_TS=0
  echo "LAST_TRIGGER_TS=$LAST_TRIGGER_TS" > "$STATE_FILE"
  echo "NEXT_TRIGGER_TS=$NEXT_TRIGGER_TS" >> "$STATE_FILE"
  echo "TAIL_PID=0" >> "$STATE_FILE"
  exit 0
fi

# Window active: strict tail trigger (always extend)
NEXT_TRIGGER_TS=$TARGET_TS

TAIL_RUNNING=0
if [ "$TAIL_PID" -gt 0 ] && kill -0 "$TAIL_PID" 2>/dev/null; then
  TAIL_RUNNING=1
fi

echo "LAST_TRIGGER_TS=$LAST_TRIGGER_TS" > "$STATE_FILE"
echo "NEXT_TRIGGER_TS=$NEXT_TRIGGER_TS" >> "$STATE_FILE"

if [ "$TAIL_RUNNING" -eq 1 ]; then
  echo "TAIL_PID=$TAIL_PID" >> "$STATE_FILE"
  log_msg "THROTTLE: window active, extend NEXT_TRIGGER_TS=$NEXT_TRIGGER_TS (tail pid=$TAIL_PID)"
  exit 0
fi

# Start new tail worker
(
  # Trap signals for cleaner exit
  trap 'exit 0' TERM INT

  # Store parent PID for enhanced orphan detection
  parent_pid=$PPID

  # Lock retry limit to prevent infinite loops
  lock_retry_count=0
  max_lock_retries=30

  # Worker loop: wait until NEXT_TRIGGER_TS stops being pushed out
  while true; do
    sleep 1

    # Enhanced orphan detection with robust /proc fallback
    # Only check /proc if it's available to avoid false positives
    if [ -r "/proc/$$/stat" ]; then
      current_ppid=$(awk '{print $4}' /proc/$$/stat 2>/dev/null || echo "")
      if [ "$current_ppid" = "1" ]; then
        # Adopted by init, parent is gone
        logger -t 8021x_action "TAIL: parent process gone (adopted by init), exiting worker"
        exit 0
      fi
    fi

    # Fallback: verify parent process still exists using kill -0
    if ! kill -0 "$parent_pid" 2>/dev/null; then
      logger -t 8021x_action "TAIL: parent process $parent_pid no longer exists, exiting worker"
      exit 0
    fi

    # stop flag means service stopped
    if [ -f "$STOP_FILE" ]; then
      exit 0
    fi

    if ! acquire_lock "$LOCK_FILE" "$LOCK_TIMEOUT_SEC"; then
      lock_retry_count=$((lock_retry_count + 1))
      if [ "$lock_retry_count" -ge "$max_lock_retries" ]; then
        logger -t 8021x_action "TAIL: failed to acquire lock after $max_lock_retries attempts, exiting"
        exit 1
      fi
      continue
    fi

    # Reset retry counter on successful lock acquisition
    lock_retry_count=0

    read_state "$STATE_FILE"
    cur_next=$NEXT_TRIGGER_TS
    release_lock "$LOCK_FILE"

    if [ "$cur_next" -le 0 ]; then
      exit 0
    fi

    now_ts=$(date +%s)
    if [ "$now_ts" -lt "$cur_next" ]; then
      continue
    fi

    # due
    if ! acquire_lock "$LOCK_FILE" "$LOCK_TIMEOUT_SEC"; then
      lock_retry_count=$((lock_retry_count + 1))
      if [ "$lock_retry_count" -ge "$max_lock_retries" ]; then
        logger -t 8021x_action "TAIL: failed to acquire lock after $max_lock_retries attempts, exiting"
        exit 1
      fi
      continue
    fi

    # Reset retry counter on successful lock acquisition
    lock_retry_count=0

    if [ -f "$STOP_FILE" ]; then
      release_lock "$LOCK_FILE"
      exit 0
    fi

    # re-check due (might be extended)
    read_state "$STATE_FILE"
    cur_next=$NEXT_TRIGGER_TS
    now_ts=$(date +%s)

    if [ "$cur_next" -le 0 ] || [ "$now_ts" -lt "$cur_next" ]; then
      release_lock "$LOCK_FILE"
      continue
    fi

    logger -t 8021x_action "TAIL: executing deferred renew (ifname=$IFNAME)"
    if [ -x "$RENEW_SCRIPT" ]; then
      "$RENEW_SCRIPT"
      rc=$?
      logger -t 8021x_action "TAIL_RENEW_RESULT: $rc (ifname=$IFNAME)"
    else
      logger -t 8021x_action "TAIL_ERROR: renew script not found: $RENEW_SCRIPT"
    fi

    last_ts=$(date +%s)
    echo "LAST_TRIGGER_TS=$last_ts" > "$STATE_FILE"
    echo "NEXT_TRIGGER_TS=0" >> "$STATE_FILE"
    echo "TAIL_PID=0" >> "$STATE_FILE"

    release_lock "$LOCK_FILE"
    exit 0
  done
) &

tail_pid=$!

# record the tail worker PID under the existing lock.
echo "LAST_TRIGGER_TS=$LAST_TRIGGER_TS" > "$STATE_FILE"
echo "NEXT_TRIGGER_TS=$NEXT_TRIGGER_TS" >> "$STATE_FILE"
echo "TAIL_PID=$tail_pid" >> "$STATE_FILE"

log_msg "THROTTLE: started tail worker pid=$tail_pid, NEXT_TRIGGER_TS=$NEXT_TRIGGER_TS"

exit 0
