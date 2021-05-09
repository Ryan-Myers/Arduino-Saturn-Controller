SCRH	= 0		;Scratch register used during multiplies. Does not need to be restored after usage.
ZERO	= 1		;Should always be maintained as ZERO. Used in MUL
SRT		= 2		;For storing the SREG temporarily while in interrupts
MTR		= 16	;Main Temp Register
VTR		= 17	;Interrupt (Vector) Temp Register
OUTPUT0	= 18	;This is the output to PORTF for ZYXR--T-
OUTPUT1	= 19	;This is the output to PORTF for UDLR--T-
OUTPUT2	= 20	;This is the output to PORTF for BCAS--T-
OUTPUT3	= 21	;This is the output to PORTF for 001L--T-
PAIRL 	= 22	;For a paired MUL register Low byte
PAIRH 	= 23	;For a paired MUL register High byte
TEMP 	= 25	;For temporary use
XL 		= 26	;X Low byte
XH 		= 27	;X High byte
YL 		= 28	;Y Low byte
YH 		= 29	;Y High byte
ZL 		= 30	;Z Low byte
ZH 		= 31	;Z High byte

.equiv PINB, 	0x03
.equiv DDRB,	0x04
.equiv PORTB,	0x05
.equiv PINC,	0x06
.equiv DDRC,	0x07
.equiv PORTC,	0x08
.equiv PIND, 	0x09
.equiv DDRD,	0x0A
.equiv PORTD,	0x0B
.equiv PINE,	0x0C
.equiv DDRE, 	0x0D
.equiv PORTE, 	0x0E
.equiv PINF, 	0x0F
.equiv DDRF, 	0x10
.equiv PORTF, 	0x11
.equiv EIMSK, 	0x1D
.equiv EICRA, 	0x0069
.equiv SREG, 	0x3F	;STATUS REGISTER - This gets modified with almost every instruction
.equiv SPH, 	0x3E	;STACK POINTER HIGH
.equiv SPL, 	0x3D	;STACK POINTER LOW
.equiv PD5,		5
;equiv OUTPUT0 0x0126	;0x800126
;equiv OUTPUT1 0x0127	;0x800127
;equiv OUTPUT2 0x0128	;0x800128
;equiv OUTPUT3 0x0129	;0x800129

.section .text
__vectors:
jmp __ctors_end		;Reset Handler
jmp __vector_1	  ;IRQ0 External Interrupt Handler
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
jmp __bad_interrupt

__ctors_start:
cpc	r2, r23 ;????

;Called up at the start of all code, and when reset
__ctors_end:
eor		ZERO,	ZERO		;Always define the ZERO register and set it to zero on load
out		SREG,	ZERO		;Default the Status Register to ZERO as well
ldi		YL, 	0B11111111 	;Not sure why we care about YL yet.
ldi		YH, 	DDRD		;Not sure why YH is DDRD yet either.
out		SPH, 	YH			;Set stack pointer high to YH
out		SPL, 	YL			;Set stack pointer low to YL
call	main
jmp		_exit

__bad_interrupt:
jmp		0

;32 clock budget at best
;5 clock minimum to interrupt leaving us with 27 left
;each clock is 0.0625us and we need to be under 2us
;17 clocks max for CASE 0
;15 clocks max for CASE 1
;20 clocks max for CASE 2
;20 clocks max for CASE 3
__vector_1:
in		SRT,	SREG		;1 clock SAVE SREG
in		VTR,	PIND		;1 clock
andi	VTR,	0B00000011	;1 clock
cpi		VTR,	0B00000001	;1 clock
breq	__case1				;1/2 clocks
brcs	__case0				;1/2 clocks
cpi		VTR,	0B00000010	;1 clock
breq	__case2 	   			;1/2 clocks
rjmp	__case3    			;2 clocks
__case0:				
out		PORTF,	OUTPUT0		;1 clock
rjmp	__end_vector_1		;2 clocks 
__case1:
out		PORTF,	OUTPUT1		;1 clock
rjmp	__end_vector_1		;2 clocks
__case2:
out		PORTF,	OUTPUT2		;1 clock
rjmp	__end_vector_1		;2 clocks
__case3:
out		PORTF,	OUTPUT3		;1 clock
__end_vector_1:
out		SREG,	SRT			;1 clock RESTORE SREG
reti						    ;5 clocks

;Check if PIND0 (S0, TH) is set to 1
sbis  PIND, 0 ; PIND0
rjmp  __TH0 ;It's not set, it's zero 3 cycles
sbis  PIND, 1 ; PIND1
out	  PORTF,	OUTPUT1 ;It's not set, it's zero. So TH1:TR0 ;2 cycles
rjmp  __TH1TR1 ;
__TH0:
sbis  PIND, 1; PIND1
out		PORTF,	OUTPUT0 ;It's not set, it's zero. So TH0:TR0
sbic  PIND, 1
out   PORTF,  OUTPUT2 ;It's set so TH0:TR1
reti                  ;Exit
__TH1TR1: ;This technically gets called when TH1:TR0 as well
sbic  PIND, 1 ;Check if TR is 0, and if so end.
reti
out   PORTF,  OUTPUT3 ;All else fails, this is TH1:TR1
reti

;0:0
;1
;2
;1
;1
;2
;5
;=12

;0:1
;2
;1
;1
;2
;1
;5
;=12

;1:0
;1
;2
;2
;1
;5
;=11

;1:1
;2
;2
;2
;2
;1
;5
;=14

main:
sei							;Enable interrupts
;DDRB  &= ~B11111110; //Set them up as inputs
in		MTR,	DDRB
andi	MTR, 	0B00000001
out		DDRB,	MTR			;BCAUDLR- as inputs
;PORTB |=  B11111110; //Enable internal pull-ups
in		MTR,	PORTB
ori		MTR, 	0B11111110
out		PORTB,	MTR			;Enable internal pullups on above
;DDRC  &= ~B01000000; //Set it up as input
cbi		DDRC,	0B00000110
;PORTC |=  B01000000; //Enable internal pull-ups
sbi		PORTC,	0B00000110
;DDRD  &= ~B10011100; //Set them up as inputs
in		MTR,	DDRD
andi	MTR,	0B01100011
out		DDRD,	MTR
;PORTD |=  B10011100; //Enable internal pull-ups
in		MTR,	PORTD 		
ori		MTR,	0B10011100
out		PORTD,	MTR
;DDRE  &= ~B01000000; //Set it up as input
cbi		DDRE,	0B00000110
;PORTE |=  B01000000; //Enable internal pull-ups
sbi		PORTE, 	0B00000110
;DDRD  &= ~B00000011; //Set them up as inputs
in		MTR,	DDRD
andi	MTR,	0B11111100
out		DDRD, 	MTR
;PORTD |=  B00000011; //Enable internal pull-ups
in		MTR,	PORTD
ori		MTR,	0B00000011
out		PORTD,	MTR
;DDRF  |=  B11110010; //Set them up as outputs
in		MTR,	DDRF
ori		MTR,	0B11110010
out		DDRF,	MTR
;PORTF |=  B11110010; //Set them HIGH by default
in		MTR, 	PORTF
ori		MTR,	0B11110010
out		PORTF, 	MTR
;EICRA &= ~(bit(ISC00) | bit (ISC01)); // Clear existing flags of interrupt 0 
lds		MTR,	EICRA		;Begin clearing flags on interrupt0
andi	MTR,	0B11111100
sts		EICRA,	MTR			;Clear existing flags on interrupt0
;EICRA |= bit (ISC00);                 // Set interrupt on rising and falling
lds		MTR,	EICRA		;Begin interrupt on rising and falling
ori		MTR,	0B00000001
sts		EICRA, 	MTR			;Set interrupt on rising and falling
sbi		EIMSK, 	0			;Enable INT0 bit0 of EIMSK
ldi		OUTPUT0,0B11110010	;ZYXR--T-
ldi		OUTPUT1,0B01110010	;UDLR--T-
ldi		OUTPUT2,0B11110010	;BCAS--T-
ldi		OUTPUT3,0B00110010	;001L--T- First 3 bits are hardcoded
jmp   setupoutputs;

setupoutputs:
cbi		PORTD,	PD5			;Turn on TXLED (PD5)
;OUTPUT0 = ((PIND & B10000010) | ((PIND & B00011100) << 2)) | B00000010;
in		MTR, 	PIND
in		PAIRL,	PIND
andi	MTR, 	0B10000010
ori		MTR, 	0B00000010
ldi		TEMP,	0B00000100
mul		PAIRL,	TEMP		;Uses temporary registers SCRH and ZERO for the multiply
movw	PAIRL,	SCRH		;moves SCRH:ZERO to PAIRL:PAIRH
eor		ZERO,	ZERO		;RESETS ZERO REGISTER
andi	PAIRL,	0B01110000
mov		OUTPUT0,MTR			;Copy MTR into OUTPUT0
sbi 	PORTD, 	PD5			;Turn off TXLED (PD5)
rjmp	setupoutputs

_exit:
cli
