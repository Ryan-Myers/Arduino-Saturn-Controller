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
  EICRA &= ~(bit(ISC10) | bit (ISC11)); // Clear existing flags of interrupt 1 
  EICRA |= bit (ISC10);                 // Set interrupt on rising and falling
  
  // Enable both interrupts
  EIMSK |= bit(INT0) | bit(INT1);

  //Default outputs to high which means unpressed.
  OUTPUTS[0] = B11110010; //ZYXR
  OUTPUTS[1] = B11110010; //UDLR
  OUTPUTS[2] = B11110010; //BCAS
  OUTPUTS[3] = B00110010; //L
}

//Interrupt when Saturn S0 (TH) pin changes
ISR (INT0_vect, ISR_NAKED)
{
  //Ideally this is all I would be able to do, but it's too slow
  //PORTF = OUTPUTS[PIND & 0B00000011];

  //This is *very* close to good enough
  asm volatile (
    "sbis   %[rPIND],   0 \n"
    "rjmp   __TH0 \n"
    "sbis   %[rPIND],   1 \n"
    "out    %[rPORTF],  %[OUTPUT1] \n" //OUTPUT 1
    "rjmp   __TH1 \n"
    "__TH0: \n"
    "sbis   %[rPIND],   1 \n"
    "out    %[rPORTF],  %[OUTPUT0] \n" //OUTPUT 0
    "sbic   %[rPIND],   1 \n"
    "out    %[rPORTF],  %[OUTPUT2] \n" //OUTPUT 2
    "reti   \n"
    "__TH1: \n"
    "sbis   %[rPIND],   1 \n"
    "reti   \n"
    "out    %[rPORTF],  %[OUTPUT3] \n" //OUTPUT 3
    "reti   \n"
    :
    :
      [OUTPUT0]"r"(OUTPUTS[0]),
      [OUTPUT1]"r"(OUTPUTS[1]),
      [OUTPUT2]"r"(OUTPUTS[2]),
      [OUTPUT3]"r"(OUTPUTS[3]),
      [rPIND]"I"(_SFR_IO_ADDR(PIND)),
      [rPORTF]"I"(_SFR_IO_ADDR(PORTF))
    :
  );
}
/**
 * Interrupt when Saturn S1 (TR) pin changes 
 * This code is identical to the above with just different label names.
 * I purposefully only used ASM that doesn't affect SREG so we didn't need to 
 * do any PUSH and POPS on any registers.
 * This is *just* not fast enough because the OUTPUTS first get loaded into registers
 * and that uses 8 cycles.
 */
ISR (INT1_vect, ISR_NAKED)
{
  //Ideally this is all I would be able to do, but it's too slow
  //PORTF = OUTPUTS[PIND & 0B00000011];

  //This is *very* close to good enough
  asm volatile (
    "sbis   %[rPIND],   0 \n"
    "rjmp   __TH0v2 \n"
    "sbis   %[rPIND],   1 \n"
    "out    %[rPORTF],  %[OUTPUT1] \n"
    "rjmp   __TH1v2 \n"
    "__TH0v2: \n"
    "sbis   %[rPIND],   1 \n"
    "out    %[rPORTF],  %[OUTPUT0] \n"
    "sbic   %[rPIND],   1 \n"
    "out    %[rPORTF],  %[OUTPUT2] \n"
    "reti   \n"
    "__TH1v2: \n"
    "sbis   %[rPIND],   1 \n"
    "reti   \n"
    "out    %[rPORTF],  %[OUTPUT3] \n"
    "reti   \n"
    :
    :
      [OUTPUT0]"r"(OUTPUTS[0]),
      [OUTPUT1]"r"(OUTPUTS[1]),
      [OUTPUT2]"r"(OUTPUTS[2]),
      [OUTPUT3]"r"(OUTPUTS[3]),
      [rPIND]"I"(_SFR_IO_ADDR(PIND)),
      [rPORTF]"I"(_SFR_IO_ADDR(PORTF))
    :
  );
}

/**
 * During the main loop, just continuosly update the values of the outputs so they're ready when the interrupts fire.
 */
void loop()
{
  //0:0    ZYXR--T-
  //PIND = Z--YXR--
  OUTPUTS[0] = ((PIND & B10000010) | ((PIND & B00011100) << 2)) | B00000010;
  
  //0:1    UDLR--T-
  //PINB = ---UDLR-
  OUTPUTS[1] = ((PINB & B00011110) << 3) | B00000010;
  
  //1:0    BCAS--T-
  //PINB = BCA-----
  //PINE = -S------
  OUTPUTS[2] = ((PINB & B11100000) | ((PINE & B01000000) >> 2)) | B00000010;
  
  //1:1    001L--T-
  //PINC = -L------
  //For this one in particular we need to set 001L according to the documentation here (page 97):
  //https://cdn.preterhuman.net/texts/gaming_and_diversion/CONSOLES/sega/ST-169-R1-072694.pdf
  OUTPUTS[3] = (((PINC & B01000000) >> 2) | B00100010);
}
