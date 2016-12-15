#!/bin/sh

echo Starting | systemd-cat -p info -t "droid-hcismd-up.sh"

# transport is smd
setprop ro.qualcomm.bt.hci_transport smd

# initialise chip
init_output=$(/system/bin/hci_qcomm_init -e -d /dev/ttyHS0 2>1)
echo $init_output | systemd-cat -p info -t "droid-hcismd-up.sh"

bt_mac=$(echo $init_output | grep -oP '([0-9a-f]{2}:){5}([0-9a-f]{2})')

echo Setting bluetooth address to $bt_mac | systemd-cat -p info -t "droid-hcismd-up.sh"
echo $bt_mac > /var/lib/bluetooth/board-address

# Maximum number of attempts to enable hcismd to try to get
# hci0 to come online.  Writing to sysfs too early seems to
# not work, so we loop.
MAXTRIES=15

seq 1 $MAXTRIES | while read i ; do
    echo 1 > /sys/module/hci_smd/parameters/hcismd_set
    if [ -e /sys/class/bluetooth/hci0 ] ; then
        # found hci0, exit successfully
        echo Init succesfully | systemd-cat -p info -t "droid-hcismd-up.sh"
        exit 0
    fi
    sleep 1
    if [ $i == $MAXTRIES ] ; then
        # must have gotten through all our retries, fail
        echo Init failed | systemd-cat -p info -t "droid-hcismd-up.sh"
        exit 1
    fi
done
