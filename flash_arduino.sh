#!/bin/bash
avrdude -C $TOP_DIR/etc/avrdude.conf -v -patmega328p -carduino -b115200 -P/dev/ttyACM0 -D -Uflash:w:code.hex:i
