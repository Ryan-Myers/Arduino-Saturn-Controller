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

uint8_t OUTPUTS[4];

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
  //EICRA &= ~(bit(ISC00) | bit (ISC01)); // Clear existing flags of interrupt 0 
  //EICRA |= bit (ISC00);                 // Set interrupt on rising and falling
  
  // Interrupt 1 for clock (PD1, pin 2) (TR S1 on Saturn)
  //EICRA &= ~(bit(ISC10) | bit (ISC11)); // Clear existing flags of interrupt 1 
  //EICRA |= bit (ISC10);                 // Set interrupt on rising and falling
  
  // Enable both interrupts
  //EIMSK |= bit(INT0)  | bit(INT1);

  //Default outputs
  OUTPUTS[0] = B11110010; //ZYXR
  OUTPUTS[1] = B01110010; //UDLR
  OUTPUTS[2] = B11110010; //BCAS
  OUTPUTS[3] = B00110010; //L

  //1st and second data defaults
  PORTF = B10000010;
  
  //delay(1500);// Wait for the Saturn to start up.
}

void loop()
{
  while ((PIND & B00000011) != B00000011) {}
  
  //1st and 2nd data defaults
  PORTF = B10000010;
  
  //0:0    ZYXR--T-
  //PIND = Z--YXR--
  //OUTPUTS[0] = ((PIND & B10000010) | ((PIND & B00011100) << 2)) & ~B00000010;
  
  //0:1    UDLR--T-
  //PINB = ---UDLR-
  //OUTPUTS[1] = ((PINB & B00011110) << 3) & ~B00000010;
  
  //1:0    BCAS--T-
  //PINB = BCA-----
  //PINE = -S------
  //OUTPUTS[2] = ((PINB & B11100000) | ((PINE & B01000000) >> 2)) | B00000010;
  
  //1:1    001L--T-
  //PINC = -L------
  //For this one in particular we need to set 001L according to the documentation here (page 97):
  //https://cdn.preterhuman.net/texts/gaming_and_diversion/CONSOLES/sega/ST-169-R1-072694.pdf
  //OUTPUTS[3] = (((PINC & B01000000) >> 2) | B11100010);

  //Wait for TH AND TR to go low
  while ((PIND & B00000011) != B00000000) {}
  
  //3rd Data
  //SET TL Low AND ID = 0 for digital.
  PORTF = B00000000;

  //Wait for TR High
  while ((PIND & B00000010) != B00000010) {}

  //4th data
  //SET  0010 for 2 bytes of data and set TL High
  PORTF = B01000010;
  
  //Wait for TR Low
  while ((PIND & B00000010) != B00000000) {}

  //5th data
  //Set Up Down Left Right and TL Low
  PORTF = B01110000;//OUTPUTS[1];
  
  //Wait for TR High
  while ((PIND & B00000010) != B00000010) {}

  //6th data
  //Set B C A Start and TL High
  PORTF = B11110010;//OUTPUTS[2];
  
  //Wait for TR Low
  while ((PIND & B00000010) != B00000000) {}

  //7th data
  //Set Z Y X R and TL Low;
  PORTF = B11110000;//OUTPUTS[0];
  
  //Wait for TR High
  while ((PIND & B00000010) != B00000010) {}

  //8th data
  //SET L and TL High
  PORTF = B11110010;//OUTPUTS[3];
  
  //Wait for TR Low
  while ((PIND & B00000010) != B00000000) {}

  //9th data
  //SET ALL Zeroes for data end and TL LOW
  PORTF = B00000000;
  
  //Wait for TR High
  while ((PIND & B00000010) != B00000010) {}

  //10th data
  //SET the last data bit and TL HIGH
  PORTF = B10000010;
  
  //Wait for TH AND TR High
  //while ((PIND & B00000011) != B00000011) {}
}
