/*  Arduino Saturn Controller
 *  Author: Ryan Myers <ryan.p.myers@gmail.com>
 *
 *  Copyright (c) 2021 Ryan Myers <https://ryanmyers.ca>
 *  
 *  GNU GENERAL PUBLIC LICENSE
 *  Version 3, 29 June 2007
 *  
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *  
 */

volatile uint8_t OUTPUTS[4];
volatile uint8_t OUTPUT0;
volatile uint8_t OUTPUT1;
volatile uint8_t OUTPUT2;
volatile uint8_t OUTPUT3;

void setup() 
{
  //Setup controller pins Up, Down, Left, Right, A, B, C
  //         BCAUDLR-;
  DDRB  &= ~B11111110; //Set them up as inputs
  PORTB |=  B11111110; //Enable internal pull-ups
  
  //Setup controller pin L
  //         -L------;
  DDRC  &= ~B01000000; //Set it up as input
  PORTC |=  B01000000; //Enable internal pull-ups
  
  //Setup controller pins Z Y X and R as inputs
  //         Z--YXR--
  DDRD  &= ~B10011100; //Set them up as inputs
  PORTD |=  B10011100; //Enable internal pull-ups
  
  //Setup controller pin Start
  //         -S------;
  DDRE  &= ~B01000000; //Set it up as input
  PORTE |=  B01000000; //Enable internal pull-ups
  
  //Setup Saturn select pins S0 (TH) and S1 (TR)
  //         ------10
  DDRD  &= ~B00000011; //Set them up as inputs
  PORTD |=  B00000011; //Enable internal pull-ups
  
  //Setup Saturn data pins D0, D1, D2, D3, and TL ACK
  //         0123--T-
  DDRF  |=  B11110010; //Set them up as outputs
  PORTF |=  B11110010; //Set them HIGH by default

  // Interrupt 0 for clock (PD0, pin 3) (TH S0 on Saturn)
  EICRA &= ~(bit(ISC00) | bit (ISC01)); // Clear existing flags of interrupt 0 
  EICRA |= bit (ISC00);                 // Set interrupt on rising and falling
  
  // Interrupt 1 for clock (PD1, pin 2) (TR S1 on Saturn)
  //EICRA &= ~(bit(ISC10) | bit (ISC11)); // Clear existing flags of interrupt 1 
  //EICRA |= bit (ISC10);                 // Set interrupt on rising and falling
  
  // Enable both interrupts
  //EIMSK |= bit(INT0);//  | bit(INT1);

  //Default outputs
  /*
  OUTPUT0 = B11110010; //ZYXR
  OUTPUT1 = B11110010; //UDLR
  OUTPUT2 = B11110010; //BCAS
  OUTPUT3 = B00110010; //L
  */
  //OUTPUTS[0] = B11110010; //ZYXR
  //OUTPUTS[1] = B11110010; //UDLR
  //OUTPUTS[2] = B11110010; //BCAS
  //OUTPUTS[3] = B00110010; //L
  asm volatile(
    "ldi   r18,0B11110010 \n"
    "ldi   r19,0B01110010 \n"
    "ldi   r20,0B11110010 \n"
    "ldi   r21,0B00110010 \n"
    :
    :
    :"r18","r19", "r20", "r21"
  );
  //delay(1500);// Wait for the Saturn to start up.
}

/*
//Interrupt when Saturn S0 (TH) pin changes
ISR (INT0_vect, ISR_NAKED)
{
  /*
  asm volatile (
      "in   r2, __SREG__ \n"   //1 clock SAVE SREG
      "push r2 \n"
      "in    r17, %[rPIND] \n"    //1 clock
      "andi  r17, 0B00000011 \n"  //1 clock
      "cpi   r17, 0B00000001 \n"  //1 clock
      "breq  __case1 \n"              //1/2 clocks
      "brcs  __case0 \n"              //1/2 clocks
      "cpi   r17, 0B00000010 \n"  //1 clock
      "breq  __case2 \n"              //1/2 clocks
      "rjmp  __case3 \n"              //2 clocks
      "__case0: \n"
      "out   %[rPORTF],r18 \n" //1 clock
      "rjmp  __end_vector_1 \n"       //2 clocks
      "__case1: \n"
      "out   %[rPORTF],r19 \n" //1 clock
      "rjmp  __end_vector_1 \n"       //2 clocks
      "__case2: \n"
      "out   %[rPORTF],r20 \n" //1 clock
      "rjmp  __end_vector_1 \n"       //2 clocks
      "__case3: \n"
      "out   %[rPORTF],r21 \n"  //1 clock
      "__end_vector_1: \n"
      "pop r2 \n"
      "out   __SREG__, r2 \n"//1 clock RESTORE SREG
      "pop r2 \n"
      "reti \n"                       //5 clocks 
      : //Output operand list
      : //Input operand list
        //[OUTPUT0]"r"(OUTPUT0),
        //[OUTPUT1]"r"(OUTPUT1),
        //[OUTPUT2]"r"(OUTPUT2),
        //[OUTPUT3]"r"(OUTPUT3),
        [rPIND]"I"(_SFR_IO_ADDR(PIND)),
        [rPORTF]"I"(_SFR_IO_ADDR(PORTF))
      : //Clobber list
        //"r16"
    );*
    
    //asm volatile ("in   r3, __SREG__ \n");   //1 clock SAVE SREG
    //PORTF = OUTPUTS[PIND & B00000011];
    //asm volatile ("out   __SREG__, r3 \n");//1 clock RESTORE SREG
    //reti();


    asm volatile (
      "sbis   %[rPIND],   0 \n"
      "rjmp   __TH0 \n"
      "sbis   %[rPIND],   1 \n"
      "out    %[rPORTF],  r19 \n" //OUTPUT 1
      "rjmp   __TH1 \n"
      "__TH0: \n"
      "sbis   %[rPIND],   1 \n"
      "out    %[rPORTF],  r18 \n" //OUTPUT 0
      "out    %[rPORTF],  r20 \n" //OUTPUT 2
      "reti   \n"
      "__TH1: \n"
      "sbic   %[rPIND],   1 \n"
      "reti   \n"
      "out    %[rPORTF],  r21 \n" //OUTPUT 3
      "reti   \n"
      :
      :
        [rPIND]"I"(_SFR_IO_ADDR(PIND)),
        [rPORTF]"I"(_SFR_IO_ADDR(PORTF))
      :"r18","r19", "r20", "r21"
    );
}*/

void loop()
{
  TXLED1;
  asm volatile(
    "loopstart: \n"
    "ldi   r18,0B11110010 \n"
    "ldi   r19,0B01110010 \n"
    "ldi   r20,0B11110010 \n"
    "ldi   r21,0B00110010 \n"
      "sbis   %[rPIND],   0 \n"
      "rjmp   __TH0 \n"
      "sbis   %[rPIND],   1 \n"
      "out    %[rPORTF],  r19 \n" //OUTPUT 1
      "rjmp   __TH1 \n"
      "__TH0: \n"
      "sbis   %[rPIND],   1 \n"
      "out    %[rPORTF],  r18 \n" //OUTPUT 0
      "out    %[rPORTF],  r20 \n" //OUTPUT 2
      "rjmp loopstart   \n"
      "__TH1: \n"
      "sbic   %[rPIND],   1 \n"
      "rjmp loopstart   \n"
      "out    %[rPORTF],  r21 \n" //OUTPUT 3
      "rjmp loopstart   \n"
      :
      :
        [rPIND]"I"(_SFR_IO_ADDR(PIND)),
        [rPORTF]"I"(_SFR_IO_ADDR(PORTF))
      :"r18","r19", "r20", "r21"
  );
  TXLED0;
  //0:0    ZYXR--T-
  //PIND = Z--YXR--
  //OUTPUT0 = ((PIND & B10000010) | ((PIND & B00011100) << 2)) | B00000010;
  //OUTPUTS[0] = B11110010;//((PIND & B10000010) | ((PIND & B00011100) << 2)) | B00000010;
  
  //0:1    UDLR--T-
  //PINB = ---UDLR-
  //OUTPUT1 = ((PINB & B00011110) << 3) | B00000010;
  //OUTPUTS[1] = B01110010;//((PINB & B00011110) << 3) | B00000010;
  
  //1:0    BCAS--T-
  //PINB = BCA-----
  //PINE = -S------
  //OUTPUT2 = ((PINB & B11100000) | ((PINE & B01000000) >> 2)) | B00000010;
  //OUTPUTS[2] = B11110010;//((PINB & B11100000) | ((PINE & B01000000) >> 2)) | B00000010;
  
  //1:1    001L--T-
  //PINC = -L------
  //For this one in particular we need to set 001L according to the documentation here (page 97):
  //https://cdn.preterhuman.net/texts/gaming_and_diversion/CONSOLES/sega/ST-169-R1-072694.pdf
  //OUTPUT3 = (((PINC & B01000000) >> 2) | B00100010);
  //OUTPUTS[3] = B00110010;//(((PINC & B01000000) >> 2) | B00100010);
}
