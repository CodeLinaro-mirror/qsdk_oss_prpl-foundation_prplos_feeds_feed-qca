#!/bin/sh
#
# Copyright (c) 2023 Qualcomm Innovation Center, Inc. All rights reserved.
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

disable_qdisc_on_eth() {
        [ -f /tmp/sysinfo/board_name ] && {
                board=ap$(cat /tmp/sysinfo/board_name | awk -F 'ap' '{print$2}')
        }

	tc qdisc replace dev eth0 root noqueue
	tc qdisc replace dev eth1 root noqueue
	tc qdisc replace dev eth2 root noqueue
	tc qdisc replace dev eth3 root noqueue
	tc qdisc replace dev eth4 root noqueue
	tc qdisc replace dev eth5 root noqueue

        echo "##### Qdisc disable for DS mode in $board #######" > /dev/ttyMSM0
}
