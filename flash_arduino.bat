@echo off
"C:\Program Files (x86)\Arduino\hardware\tools\avr\bin\avrdude" -C "C:\Program Files (x86)\Arduino\hardware\tools\avr\etc\avrdude.conf" -v -p atmega32u4 -c stk500v1 -P COM3 -b 19200 -e -U lock:w:0x3F:m -U efuse:w:0xcb:m -U hfuse:w:0xd8:m -U lfuse:w:0xff:m
"C:\Program Files (x86)\Arduino\hardware\tools\avr\bin\avrdude" -C "C:\Program Files (x86)\Arduino\hardware\tools\avr\etc\avrdude.conf" -v -p atmega32u4 -c stk500v1 -P COM3 -b 19200    -U lock:w:0x2F:m -U flash:w:Arduino-Saturn-Controller.o:e
