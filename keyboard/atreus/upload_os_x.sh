#!/bin/bash

compile_firmware() {
    make clean
    make KEYMAP=$1 ||  (echo 'Could not compile :(' 1>$2; exit 2)
}

original_devs=$(ls /dev/)
new_device() {
    diff <(echo "$original_devs") <(ls /dev/) | grep cu.usbmodem
}

extract_device() {
    new_device | awk '{ print $2 }'
}

flash_device() {
    echo 'flashing...'
    avrdude -p atmega32u4 -c avr109 -U flash:w:$1 -P $2
}

wait_for_the_device() {
    echo 'Waiting for the device... Do that thing on your keyboard!'

    while ! new_device ; do
        sleep 0.5
    done

    extract_device || exit 1
    echo "found new device `extract_device`"
}

main() {
    KEYMAP=unmanbearpig_multidvorak
    compile_firmware $KEYMAP

    wait_for_the_device
    sleep 1 # It looks like it needs some time to start working

    device=/dev/`extract_device`
    filename=atreus.hex
    flash_device $filename $device

    echo 'done!'
}

main
