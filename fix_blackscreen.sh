#!/bin/sh

op1_succes=0
op2_succes=0

#KMS changes, op1
GETTY_LOGIN_SERVICE=/etc/systemd/system/getty@tty1.service.d/override.conf
KMS_CONF=/mnt/loader/entries/gridos.conf
DATE=`TZ='Europe/Stockholm' date +%Y-%b-%d.%H:%M:%S`
HOME_OMBORI=`getent passwd ombori | cut -d: -f6`

mount /dev/sda1 /mnt
if [ -f "$KMS_CONF" ]; then
    echo "/dev/sda1 exists and mounted!"

    OS_KMS_CONF=`cat $KMS_CONF | awk '/title / {print $2 $3}'`
    echo "Current OS: $OS_KMS_CONF"

    if [ $OS_KMS_CONF == "GridOS0.9.5" ]; then
        mv $KMS_CONF $HOME_OMBORI/.old_gridos.conf-$DATE
        touch $KMS_CONF
        echo "title GridOS 0.9.5 
linux /vmlinuz
initrd /initrd.img
options root=ZFS=gridos/ROOT/gridos.0.9.5 zfsforce=1 acpi_osi=\"Linux\" i915.fastboot=1 i915.enable_psr=0 ro quiet splash" > $KMS_CONF

        chown root $KMS_CONF
        chmod u=rwx,g=xr,o=xr $KMS_CONF

        op1_succes=1
        echo "KMS Change Succesful!!"
    else
        echo "ERR! Current OS is not GRIDOS 0.9.5"
        echo "Contact with Ombori Tech team!"
    fi
else
    echo "ERR! /dev/sda1 CAN'T mount!"
    echo "Contact with Ombori Tech team!"
fi


#autologin getty service change to fasten, op2
if [ -f "$GETTY_LOGIN_SERVICE" ]; then
    echo "/getty@tty1.service.d service override found!"

    sed -i 's/Type=idle/Type=simple/g' $GETTY_LOGIN_SERVICE
    echo `systemctl daemon-reload`

    op2_succes=1
    echo "GETTY Change Succesful!!"
else
    echo "ERR! getty@tty1.service.d service override CAN'T found!"
    echo "Contact with Ombori Tech team!"
fi

#result
if [[ $op1_succes == 1 && $op2_succes == 1 ]]; then
    echo "Fix is Succesful. A reboot is required!"
fi
