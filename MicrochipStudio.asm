.def SCRH	= r0		;Scratch register used during multiplies. Does not need to be restored after usage.
.def ZERO	= r1		;Should always be maintained as ZERO. Used in MUL
.def SRT		= r2	;For storing the SREG temporarily while in interrupts
.def MTR		= r16	;Main Temp Register
.def VTR		= r17	;Interrupt (Vector) Temp Register
.def OUTPUT0	= r18	;This is the output to PORTF for ZYXR--T-
.def OUTPUT1	= r19	;This is the output to PORTF for UDLR--T-
.def OUTPUT2	= r20	;This is the output to PORTF for BCAS--T-
.def OUTPUT3	= r21	;This is the output to PORTF for 001L--T-
.def PAIRL 	= r22	;For a paired MUL register Low byte
.def PAIRH 	= r23	;For a paired MUL register High byte
.def TEMP 	= r25	;For temporary use
;.def XL 		= r26	;X Low byte
;.def XH 		= r27	;X High byte
;.def YL 		= r28	;Y Low byte
;.def YH 		= r29	;Y High byte
;.def ZL 		= r30	;Z Low byte
;.def ZH 		= r31	;Z High byte

;.equiv PINB, 	0x03
;.equiv DDRB,	0x04
;.equiv PORTB,	0x05
;.equiv PINC,	0x06
;.equiv DDRC,	0x07
;.equiv PORTC,	0x08
;.equiv PIND, 	0x09
;.equiv DDRD,	0x0A
;.equiv PORTD,	0x0B
;.equiv PINE,	0x0C
;.equiv DDRE, 	0x0D
;.equiv PORTE, 	0x0E
;.equiv PINF, 	0x0F
;.equiv DDRF, 	0x10
;.equiv PORTF, 	0x11
;.equiv EIMSK, 	0x1D
;.equiv EICRA, 	0x0069
;.equiv SREG, 	0x3F	;STATUS REGISTER - This gets modified with almost every instruction
;.equiv SPH, 	0x3E	;STACK POINTER HIGH
;.equiv SPL, 	0x3D	;STACK POINTER LOW
;.equiv PD5,		5
;equiv OUTPUT0 0x0126	;0x800126
;equiv OUTPUT1 0x0127	;0x800127
;equiv OUTPUT2 0x0128	;0x800128
;equiv OUTPUT3 0x0129	;0x800129

;.section .text
__vectors:
jmp __ctors_end		;Reset Handler
jmp __vector_1	  ;IRQ0 External Interrupt Handler
jmp __vector_2	
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

__vector_2:
;SBIS = SKIP if SET SBIC = skip if cleared
sbis	PIND,	PD0		;PD0 = 1?
rjmp	__TH0v2			;PD0 = 0
sbis	PIND,	PD1		;PD1 = 1? PD0 = 1
out		PORTF,	OUTPUT1 ;PD1 = 0 So TH1:TR0
rjmp  __TH1TR1v2		;PD1 = 1 (Or 0 after above finished)
__TH0v2:
sbis	PIND,	PD1		;PD1 = 1?
out		PORTF,	OUTPUT0 ;PD1 = 0 So TH0:TR0
sbic	PIND,	PD1		;PD1 = 0?
out		PORTF,  OUTPUT2	;PD1 = 1 So TH0:TR1
reti					;Exit
__TH1TR1v2:				;This technically gets called when TH1:TR0 as well
sbis	PIND,	PD1		;PD1 = 0?
reti					;Exit
out		PORTF,  OUTPUT3 ;PD1 = l So TH1:TR1
reti					;Exit


;32 clock budget at best
;5 clock minimum to interrupt leaving us with 27 left
;each clock is 0.0625us and we need to be under 2us
;17 clocks max for CASE 0
;15 clocks max for CASE 1
;20 clocks max for CASE 2
;20 clocks max for CASE 3
__vector_1:
;SBIS = SKIP if SET SBIC = skip if cleared
sbis	PIND,	PD0		;PD0 = 1?
rjmp	__TH0			;PD0 = 0
sbis	PIND,	PD1		;PD1 = 1? PD0 = 1
out		PORTF,	OUTPUT1 ;PD1 = 0 So TH1:TR0
rjmp  __TH1TR1			;PD1 = 1 (Or 0 after above finished)
__TH0:
sbis	PIND,	PD1		;PD1 = 1?
out		PORTF,	OUTPUT0 ;PD1 = 0 So TH0:TR0
sbic	PIND,	PD1		;PD1 = 0?
out		PORTF,  OUTPUT2	;PD1 = 1 So TH0:TR1
reti					;Exit
__TH1TR1:				;This technically gets called when TH1:TR0 as well
sbis	PIND,	PD1		;PD1 = 0?
reti					;Exit
out		PORTF,  OUTPUT3 ;PD1 = l So TH1:TR1
reti					;Exit

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
;EICRA |= bit (ISC00);      // Set interrupt on rising and falling
lds		MTR,	EICRA		;Begin interrupt on rising and falling
ori		MTR,	0B00000001
sts		EICRA, 	MTR			;Set interrupt on rising and falling
;EICRA &= ~(bit(ISC10) | bit (ISC11)); // Clear existing flags of interrupt 1 
lds		MTR,	EICRA
andi	MTR,	0B11110011
sts		EICRA,	MTR
;EICRA |= bit (ISC10);      ;Set interrupt on rising and falling
lds		MTR,	EICRA
ori		MTR,	0B00000100
sts		EICRA,	MTR	
;Enable both interrupts
in		MTR,	EIMSK
ori		MTR,	0B00000011
out		EIMSK, 	MTR			;Enable INT0 AND INT1 bit0/1 of EIMSK
sei							;Enable interrupts
ldi		OUTPUT0,0B11110010	;ZYXR--T-
ldi		OUTPUT1,0B01110010	;UDLR--T-
ldi		OUTPUT2,0B11110010	;BCAS--T-
ldi		OUTPUT3,0B00110010	;001L--T- First 3 bits are hardcoded
jmp   setupoutputs;

setupoutputs:
;cbi		PORTD,	PD5			;Turn on TXLED (PD5)
;OUTPUT0 = ((PIND & B10000010) | ((PIND & B00011100) << 2)) | B00000010;
in		MTR, 	PIND
in		PAIRL,	PIND
andi	MTR, 	0B10000010
ori		MTR, 	0B00000010;
ldi		TEMP,	DDRB
mul		PAIRL,	TEMP		;Uses temporary registers SCRH and ZERO for the multiply
movw	PAIRL,	SCRH		;moves SCRH:ZERO to PAIRL:PAIRH
eor		ZERO,	ZERO		;RESETS ZERO REGISTER
andi	PAIRL,	0B01110000
or		MTR,	PAIRL
mov		OUTPUT0,MTR			;ZYXR--T-
;OUTPUT1 = ((PINB & B00011110) << 3) | B00000010;
in		MTR,	PINB
ldi		PAIRL,	PORTC
mul		MTR,	PAIRL
movw	MTR,	SCRH
eor		ZERO,	ZERO
andi	MTR,	0B11110000
ori		MTR,	0B00000010
mov		OUTPUT1,MTR			;UDLR--T-
;OUTPUT2 = ((PINB & B11100000) | ((PINE & B01000000) >> 2)) | B00000010;
in		MTR,	PINB
in		TEMP,	PINE
andi	MTR,	0B11100000
ori		MTR,	0B00000010
lsr		TEMP				;Load shift right
lsr		TEMP				;Load shift right
andi	TEMP,	0B00010000
or		MTR,	TEMP
mov		OUTPUT2,MTR
;For this one in particular we need to set 001L according to the documentation here (page 97):
;https://cdn.preterhuman.net/texts/gaming_and_diversion/CONSOLES/sega/ST-169-R1-072694.pdf
;OUTPUT3 = (((PINC & B01000000) >> 2) | B00100010);
in		MTR,	PINC
lsr		MTR
lsr		MTR
andi	MTR,	0B00010000
ori		MTR,	0B00100010
mov		OUTPUT3,MTR			;001L--T- First 3 bits are hardcoded
rjmp	setupoutputs

_exit:
cli
