;/*  Arduino Saturn Controller
; *  Author: Ryan Myers <ryan.p.myers@gmail.com>
; *
; *  Copyright (c) 2021 Ryan Myers <https://ryanmyers.ca>
; *  
; *  GNU GENERAL PUBLIC LICENSE
; *  Version 3, 29 June 2007
; *  
; *  This program is free software: you can redistribute it and/or modify
; *  it under the terms of the GNU General Public License as published by
; *  the Free Software Foundation, either version 3 of the License, or
; *  (at your option) any later version.
; *  
; *  This program is distributed in the hope that it will be useful,
; *  but WITHOUT ANY WARRANTY; without even the implied warranty of
; *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; *  GNU General Public License for more details.
; *  
; *  You should have received a copy of the GNU General Public License
; *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
; *  
; */
SCRH    = 0   ;Scratch register used during multiplies. Does not need to be restored after usage.
ZERO    = 1   ;Should always be maintained as ZERO. Used in MUL
SRT     = 2   ;For storing the SREG temporarily while in interrupts
MTR     = 16  ;Main Temp Register
VTR     = 17  ;Interrupt (Vector) Temp Register
OUTPUT0 = 18  ;This is the output to PORTF for ZYXR--T-
OUTPUT1 = 19  ;This is the output to PORTF for UDLR--T-
OUTPUT2 = 20  ;This is the output to PORTF for BCAS--T-
OUTPUT3 = 21  ;This is the output to PORTF for 001L--T-
PAIRL   = 22  ;For a paired MUL register Low byte
PAIRH   = 23  ;For a paired MUL register High byte
TEMP    = 25  ;For temporary use
XL      = 26  ;X Low byte
XH      = 27  ;X High byte
YL      = 28  ;Y Low byte
YH      = 29  ;Y High byte
ZL      = 30  ;Z Low byte
ZH      = 31  ;Z High byte

.equiv PINB,  0x03
.equiv DDRB,  0x04
.equiv PORTB, 0x05
.equiv PINC,  0x06
.equiv DDRC,  0x07
.equiv PORTC, 0x08
.equiv PIND,  0x09
.equiv DDRD,  0x0A
.equiv PORTD, 0x0B
.equiv PINE,  0x0C
.equiv DDRE,  0x0D
.equiv PORTE, 0x0E
.equiv PINF,  0x0F
.equiv DDRF,  0x10
.equiv PORTF, 0x11
.equiv EIMSK, 0x1D
.equiv EICRA, 0x0069
.equiv SREG,  0x3F  ;STATUS REGISTER - This gets modified with almost every instruction
.equiv SPH,   0x3E  ;STACK POINTER HIGH
.equiv SPL,   0x3D  ;STACK POINTER LOW
.equiv PD5,   5
.equiv PD0,   0
.equiv PD1,   1

__vectors:
jmp __reset         ;Reset Handler
jmp __vector_1      ;IRQ0 External Interrupt Handler
jmp __vector_2      ;IRQ1 External Interrupt Handler
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt 
jmp __bad_interrupt 
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt
jmp __bad_interrupt

;Called up at the start of all code, and when reset
__reset:
eor   ZERO, ZERO        ;Always define the ZERO register and set it to zero on load
out   SREG, ZERO        ;Default the Status Register to ZERO as well
ldi   YL,   0B11111111  ;Not sure why we care about YL yet.
ldi   YH,   DDRD        ;Not sure why YH is DDRD yet either.
out   SPH,  YH          ;Set stack pointer high to YH
out   SPL,  YL          ;Set stack pointer low to YL
call  main
jmp   _exit

__bad_interrupt:
jmp   0

;/**
; * Interrupt when Saturn S1 (TR) pin changes 
; * This code is identical to below with just different label names.
; * I purposefully only used ASM that doesn't affect SREG so we didn't need to 
; * do any PUSH and POPS on any registers.
; */
__vector_2:
sbis  PIND,   PD0     ;PD0 = 1?
rjmp  __TH0v2         ;PD0 = 0
sbis  PIND,   PD1     ;PD1 = 1? PD0 = 1
out   PORTF,  OUTPUT1 ;PD1 = 0 So TH1:TR0
rjmp  __TH1TR1v2      ;PD1 = 1 (Or 0 after above finished)
__TH0v2:
sbis  PIND,   PD1     ;PD1 = 1?
out   PORTF,  OUTPUT0 ;PD1 = 0 So TH0:TR0
sbic  PIND,   PD1     ;PD1 = 0?
out   PORTF,  OUTPUT2 ;PD1 = 1 So TH0:TR1
reti                  ;Exit
__TH1TR1v2:           ;This technically gets called when TH1:TR0 as well
sbis  PIND,   PD1     ;PD1 = 0?
reti                  ;Exit
out   PORTF,  OUTPUT3 ;PD1 = l So TH1:TR1
reti                  ;Exit

;Interrupt when Saturn S0 (TH) pin changes
__vector_1:
sbis  PIND,   PD0     ;PD0 = 1?
rjmp  __TH0           ;PD0 = 0
sbis  PIND,   PD1     ;PD1 = 1? PD0 = 1
out   PORTF,  OUTPUT1 ;PD1 = 0 So TH1:TR0
rjmp  __TH1TR1        ;PD1 = 1 (Or 0 after above finished)
__TH0:
sbis  PIND,   PD1     ;PD1 = 1?
out   PORTF,  OUTPUT0 ;PD1 = 0 So TH0:TR0
sbic  PIND,   PD1     ;PD1 = 0?
out   PORTF,  OUTPUT2 ;PD1 = 1 So TH0:TR1
reti                  ;Exit
__TH1TR1:             ;This technically gets called when TH1:TR0 as well
sbis  PIND,   PD1     ;PD1 = 0?
reti                  ;Exit
out   PORTF,  OUTPUT3 ;PD1 = l So TH1:TR1
reti                  ;Exit

;Set up all of the inputs/outputs
main:
sei                   ;Enable interrupts

;Setup controller pins Up, Down, Left, Right, A, B, C
;           BCAUDLR-;
;DDRB  &= ~B11111110; //Set them up as inputs
in    MTR,    DDRB
andi  MTR,    0B00000001
out   DDRB,   MTR     ;BCAUDLR- as inputs
;PORTB |=  B11111110; //Enable internal pull-ups
in    MTR,    PORTB
ori   MTR,    0B11111110
out   PORTB,  MTR     ;Enable internal pullups on above


;Setup controller pin L
;          -L------;
;DDRC  &= ~B01000000; //Set it up as input
cbi   DDRC,   0B00000110
;PORTC |=  B01000000; //Enable internal pull-ups
sbi   PORTC,  0B00000110


;Setup controller pins Z Y X and R as inputs
;           Z--YXR--
;DDRD  &= ~B10011100; //Set them up as inputs
in    MTR,    DDRD
andi  MTR,    0B01100011
out   DDRD,   MTR
;PORTD |=  B10011100; //Enable internal pull-ups
in    MTR,    PORTD     
ori   MTR,    0B10011100
out   PORTD,  MTR


;Setup controller pin Start
;           -S------;
;DDRE  &= ~B01000000; //Set it up as input
cbi   DDRE,   0B00000110
;PORTE |=  B01000000; //Enable internal pull-ups
sbi   PORTE,  0B00000110


;Setup Saturn select pins S0 (TH) and S1 (TR)
;           ------10
;DDRD  &= ~B00000011; //Set them up as inputs
in    MTR,    DDRD
andi  MTR,    0B11111100
out   DDRD,   MTR
;PORTD |=  B00000011; //Enable internal pull-ups
in    MTR,    PORTD
ori   MTR,    0B00000011
out   PORTD,  MTR


;Setup Saturn data pins D0, D1, D2, D3, and TL ACK
;         0123--T-
;DDRF  |=  B11110010; //Set them up as outputs
in    MTR,    DDRF
ori   MTR,    0B11110010
out   DDRF,   MTR
;PORTF |=  B11110010; //Set them HIGH by default
in    MTR,    PORTF
ori   MTR,    0B11110010
out   PORTF,  MTR


;Interrupt 0 for clock (PD0, pin 3) (TH S0 on Saturn)
;EICRA &= ~(bit(ISC00) | bit (ISC01)); // Clear existing flags of interrupt 0 
lds   MTR,    EICRA
andi  MTR,    0B11111100
sts   EICRA,  MTR
;EICRA |= bit (ISC00);// Set interrupt on rising and falling
lds   MTR,    EICRA
ori   MTR,    0B00000001
sts   EICRA,  MTR 


;Interrupt 1 for clock (PD1, pin 2) (TR S1 on Saturn)
;EICRA &= ~(bit(ISC10) | bit (ISC11)); // Clear existing flags of interrupt 1 
lds   MTR,    EICRA
andi  MTR,    0B11110011
sts   EICRA,  MTR
;EICRA |= bit (ISC10); //Set interrupt on rising and falling
lds   MTR,    EICRA
ori   MTR,    0B00000100
sts   EICRA,  MTR 


;Enable both interrupts
in    MTR,    EIMSK
ori   MTR,    0B00000011
out   EIMSK,  MTR
sei

;Default outputs to high which means unpressed.
ldi   OUTPUT0,0B11110010  ;ZYXR--T-
ldi   OUTPUT1,0B01110010  ;UDLR--T-
ldi   OUTPUT2,0B11110010  ;BCAS--T-
ldi   OUTPUT3,0B00110010  ;001L--T- First 3 bits are hardcoded
jmp   setupoutputs;

;During the main loop, just continuosly update the values of the outputs so they're ready when the interrupts fire.
setupoutputs:
;0:0    ZYXR--T-
;PIND = Z--YXR--
;OUTPUTS[0] = ((PIND & B10000010) | ((PIND & B00011100) << 2)) | B00000010;
in    MTR,    PIND
in    PAIRL,  PIND
andi  MTR,    0B10000010
ori   MTR,    0B00000010;
ldi   TEMP,   DDRB
mul   PAIRL,  TEMP    ;Uses temporary registers SCRH and ZERO for the multiply
movw  PAIRL,  SCRH    ;moves SCRH:ZERO to PAIRL:PAIRH
eor   ZERO,   ZERO    ;RESETS ZERO REGISTER
andi  PAIRL,  0B01110000
or    MTR,    PAIRL
mov   OUTPUT0,MTR     ;ZYXR--T-

;0:1    UDLR--T-
;PINB = ---UDLR-
;OUTPUTS[1] = ((PINB & B00011110) << 3) | B00000010;
in    MTR,    PINB
ldi   PAIRL,  PORTC
mul   MTR,    PAIRL
movw  MTR,    SCRH
eor   ZERO,   ZERO
andi  MTR,    0B11110000
ori   MTR,    0B00000010
mov   OUTPUT1,MTR     ;UDLR--T-

;1:0    BCAS--T-
;PINB = BCA-----
;PINE = -S------
;OUTPUTS[2] = ((PINB & B11100000) | ((PINE & B01000000) >> 2)) | B00000010;
in    MTR,    PINB
in    TEMP,   PINE
andi  MTR,    0B11100000
ori   MTR,    0B00000010
lsr   TEMP
lsr   TEMP
andi  TEMP,   0B00010000
or    MTR,    TEMP
mov   OUTPUT2,MTR

;1:1    001L--T-
;PINC = -L------
;For this one in particular we need to set 001L according to the documentation here (page 97):
;https://cdn.preterhuman.net/texts/gaming_and_diversion/CONSOLES/sega/ST-169-R1-072694.pdf
;OUTPUTS[3] = (((PINC & B01000000) >> 2) | B00100010);
in    MTR,    PINC
lsr   MTR
lsr   MTR
andi  MTR,    0B00010000
ori   MTR,    0B00100010
mov   OUTPUT3,MTR     ;001L--T- First 3 bits are hardcoded
rjmp  setupoutputs

_exit:
cli
