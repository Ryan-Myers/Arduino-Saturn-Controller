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
;equiv OUTPUT0 0x0126	;0x800126
;equiv OUTPUT1 0x0127	;0x800127
;equiv OUTPUT2 0x0128	;0x800128
;equiv OUTPUT3 0x0129	;0x800129

.section .text
vectors:
jmp RESET		;Reset Handler
jmp EXT_INT0	;IRQ0 External Interrupt Handler
jmp bad_vector	
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector	
jmp bad_vector	
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector
jmp bad_vector

;Called up at the start of all code, and when reset
RESET:
eor		ZERO,	ZERO		;Always define the ZERO register and set it to zero on load
out		SREG,	ZERO		;Default the Status Register to ZERO as well
ldi		YL, 	0B11111111 	;Not sure why we care about YL yet.
ldi		YH, 	DDRD		;Not sure why YH is DDRD yet either.
out		SPH, 	YH			;Set stack pointer to YH
out		SPL, 	YL			;Set stack pointer low to YL
call	main
jmp		exit

bad_vector:
jmp		0

;32 clock budget at best
;5 clock minimum to interrupt leaving us with 27 left
;each clock is 0.0625us and we need to be under 2us
;17 clocks max for CASE 0
;15 clocks max for CASE 1
;20 clocks max for CASE 2
;20 clocks max for CASE 3
EXT_INT0:
in		SRT,	SREG		;1 clock SAVE SREG
in		VTR,	PIND		;1 clock
andi	VTR,	0B00000011	;1 clock
cpi		VTR,	0B00000001	;1 clock
breq	case1				;1/2 clocks
brcs	case0				;1/2 clocks
cpi		VTR,	0B00000010	;1 clock
breq	case2 	   			;1/2 clocks
rjmp	case3    			;2 clocks
case0:				
out		PORTF,	OUTPUT0		;1 clock
rjmp	endvector			;2 clocks 
case1:
out		PORTF,	OUTPUT1		;1 clock
rjmp	endvector			;2 clocks
case2:
out		PORTF,	OUTPUT2		;1 clock
rjmp	endvector			;2 clocks
case3:
out		PORTF,	OUTPUT3		;1 clock
endvector:
out		SREG,	SRT			;1 clock RESTORE SREG
reti						;5 clocks

main:
sei							;Enable interrupts
in		MTR,	DDRB
andi	MTR, 	0B00000001
out		DDRB,	MTR			;BCAUDLR- as inputs
in		MTR,	PORTB
ori		MTR, 	0B11111110
out		PORTB,	MTR			;Enable internal pullups on above
cbi		DDRC,	0B00000110
sbi		PORTC,	0B00000110
in		MTR,	DDRD
andi	MTR,	0B01100011
out		DDRD,	MTR
in		MTR,	PORTD 		;??? Is PORTD right?
ori		MTR,	0B10011100
out		PORTD,	MTR
cbi		DDRE,	0B00000110
sbi		PORTE, 	0B00000110
in		MTR,	DDRD
andi	MTR,	0B11111100
out		DDRD, 	MTR
in		MTR,	PORTD
ori		MTR,	0B00000011
out		PORTD,	MTR
in		MTR,	DDRF
ori		MTR,	0B11110010
out		DDRF,	MTR
in		MTR, 	PORTF
ori		MTR,	0B11110010
out		PORTF, 	MTR
lds		MTR,	EICRA		;Begin clearing flags on interrupt0
andi	MTR,	0B11111100
sts		EICRA,	MTR			;Clear existing flags on interrupt0
lds		MTR,	EICRA		;Begin interrupt on rising and falling
ori		MTR,	0B00000001
sts		EICRA, 	MTR			;Set interrupt on rising and falling
sbi		EIMSK, 	0			;Enable INT0 bit0 of EIMSK
ldi		OUTPUT0,0B11110010	;ZYXR--T-
ldi		OUTPUT1,0B01110010	;UDLR--T-
ldi		OUTPUT2,0B11110010	;BCAS--T-
ldi		OUTPUT3,0B00110010	;001L--T- First 3 bits are hardcoded

setupoutputs:
cbi		PORTB,	0B00000101	;Turn on TXLED
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
sbi 	PORTD, 	0B00000101	;Turn off TXLED
rjmp	setupoutputs

exit:
cli
