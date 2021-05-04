.DEVICE ATmega32
.def mtr 		= r24	;main temp register
.def vtr 		= r16	;vector temp register
.def output0 	= r17
.def output1 	= r18
.def output2 	= r19
.def output3 	= r20
.def SRT 		= r1	;SREG Temporary Storage
.def XL			= r26	;X Low bit
.def XH			= r27	;X High bit
.def YL			= r28	;Y Low bit
.def YH			= r29	;Y High bit
.def ZL			= r30	;Z Low bit
.def ZH			= r31	;Z High bit

.define PINB 	0x03
.define DDRB 	0x04
.define PORTB 	0x05
.define PINC 	0x06
.define DDRC 	0x07
.define PORTC 	0x08
.define PIND 	0x09
.define DDRD 	0x0A
.define PORTD 	0x0B
.define PINE 	0x0C
.define DDRE 	0x0D
.define PORTE 	0x0E
.define PINF 	0x0F
.define DDRF 	0x10
.define PORTF 	0x11
.define EIMSK 	0x1D
.define EICRA 	0x0069
;.define OUTPUT0 0x0126	;0x800126
;.define OUTPUT1 0x0127	;0x800127
;.define OUTPUT2 0x0128	;0x800128
;.define OUTPUT3 0x0129	;0x800129

.define SREG 	0x3F	;STATUS REGISTER - This gets modified with almost every instruction
.define SPH 	0x3E	;STACK POINTER HIGH
.define SPL 	0x3D	;STACK POINTER LOW

__vectors:
jmp __RESET		;Reset Handler
jmp __EXT_INT0	;IRQ0 External Interrupt Handler
jmp __bad_vector	
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector	
jmp __bad_vector	
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector
jmp __bad_vector

__RESET:
eor		SRT,	SRT
out		SREG,	SRT
ldi		YL, 	0B11111111
ldi		YH, 	DDRD
out		SPH, 	YH
out		SPL, 	YL
call	main
jmp		_exit

__bad_vector:
jmp		0

;32 clock budget at best
;5 clock minimum to interrupt leaving us with 27 left
;each clock is 0.0625us and we need to be under 2us
;17 clocks max for CASE 0
;15 clocks max for CASE 1
;20 clocks max for CASE 2
;20 clocks max for CASE 3
__EXT_INT0:
in		SRT,	SREG		;1 clock SAVE SREG
in		vtr,	PIND		;1 clock
andi	vtr,	0B00000011	;1 clock
cpi		vtr,	0B00000001	;1 clock
breq	case1				;1/2 clocks
brcs	case0				;1/2 clocks
cpi		vtr,	0B00000010	;1 clock
breq	case2 	   			;1/2 clocks
rjmp	case3    			;2 clocks
case0:				
out		PORTF,	output0		;1 clock
rjmp	endvector			;2 clocks 
case1:
out		PORTF,	output1		;1 clock
rjmp	endvector			;2 clocks
case2:
out		PORTF,	output2		;1 clock
rjmp	endvector			;2 clocks
case3:
out		PORTF,	output3		;1 clock
endvector:
out	SREG,	SRT				;1 clock RESTORE SREG
reti						;5 clocks

main:
sei							;Enable interrupts
in		mtr,	DDRB
andi	mtr, 	0B00000001
out		DDRB,	mtr			;BCAUDLR- as inputs
in		mtr,	PORTB
ori		mtr, 	0B11111110
out		PORTB,	mtr			;Enable internal pullups on above
cbi		DDRC,	0B00000110
sbi		PORTC,	0B00000110
in		mtr,	DDRD
andi	mtr,	0B01100011
out		DDRD,	mtr
in		mtr,	PORTD 		;??? Is PORTD right?
ori		mtr,	0B10011100
out		PORTD,	mtr
cbi		DDRE,	0B00000110
sbi		PORTE, 	0B00000110
in		mtr,	DDRD
andi	mtr,	0B11111100
out		DDRD, 	mtr
in		mtr,	PORTD
ori		mtr,	0B00000011
out		PORTD,	mtr
in		mtr,	DDRF
ori		mtr,	0B11110010
out		DDRF,	mtr
in		mtr, 	PORTF
ori		mtr,	0B11110010
out		PORTF, 	mtr
lds		mtr,	EICRA		;Begin clearing flags on interrupt0
andi	mtr,	0B11111100
sts		EICRA,	mtr			;Clear existing flags on interrupt0
lds		mtr,	EICRA		;Begin interrupt on rising and falling
ori		mtr,	0B00000001
sts		EICRA, 	mtr			;Set interrupt on rising and falling
sbi		EIMSK, 	0			;Enable INT0 bit0 of EIMSK
ldi		output0,0B11110010	;ZYXR--T-
ldi		output1,0B01110010	;UDLR--T-
ldi		output2,0B11110010	;BCAS--T-
ldi		output3,0B00110010	;001L--T- First 3 bits are hardcoded

loop:
nop
rjmp	loop

_exit:
cli
