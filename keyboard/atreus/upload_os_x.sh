#!/bin/bash

KEYMAP=unmanbearpig_multidvorak

compile_firmware() {
    make clean
    make KEYMAP=$1 ||  (echo 'Could not compile :(' 1>$2; exit 2)
}

compile_firmware $KEYMAP

original_devs=$(ls /dev/)

echo 'Waiting for the device... Do that thing on your keyboard!'

new_device() {
    diff <(echo "$original_devs") <(ls /dev/) | grep cu.usbmodem
}

extract_device() {
    new_device | awk '{ print $2 }'
}

flash_device() {
    avrdude -p atmega32u4 -c avr109 -U flash:w:$1 -P $2
}

while ! new_device ; do
    sleep 0.5
done

echo "found new device `extract_device`"

extract_device || exit 1

device=/dev/`extract_device`

filename=atreus.hex

sleep 1

echo 'flashing...'
flash_device $filename $device

echo 'done!'
