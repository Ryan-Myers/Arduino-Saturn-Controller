@echo off
"C:\Program Files (x86)\Arduino\hardware\tools\avr\bin\avr-gcc" -x assembler-with-cpp -nostartfiles -mmcu=atmega32u4 -o Arduino-Saturn-Controller.o Arduino-Saturn-Controller.asm
