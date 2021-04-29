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
  
  //Setup Saturn select pins S0 and S1
  //         ------10
  DDRD  &= ~B00000011; //Set them up as inputs
  PORTD |=  B00000011; //Enable internal pull-ups
  
  //Setup Saturn data pins D0, D1, D2, D3, and TL ACK
  //         0123--T-
  DDRF  |=  B11110010; //Set them up as outputs
  PORTF |=  B11110010; //Set them HIGH by default

  // Interrupt 0 for clock (PD0, pin 3)
  EICRA &= ~(bit(ISC00) | bit (ISC01)); // Clear existing flags of interrupt 0 
  EICRA |= bit (ISC00);                 // Set interrupt on rising and falling
  
  // Interrupt 1 for clock (PD1, pin 2)
  EICRA &= ~(bit(ISC10) | bit (ISC11)); // Clear existing flags of interrupt 1 
  EICRA |= bit (ISC10);                 // Set interrupt on rising and falling
  
  // Enable both interrupts
  EIMSK |= bit(INT0)  | bit(INT1);
  
  delay(1500);// Wait for the Saturn to start up.
}

//Interrupt when Saturn S0 pin changes
ISR (INT0_vect)
{
  CheckAndSetValues();
}

//Interrupt when Saturn S1 pin changes
ISR (INT1_vect)
{
  CheckAndSetValues();
}

void loop()
{
  //CheckAndSetValues();
}

void CheckAndSetValues()
{
  uint8_t control_bits = B00000000;
  //PORTF = 0123--T-
  switch (PIND & B00000011)
  {
    case B00000000:
      //0:0    ZYXR--T-
      //PIND = Z--YXR--
      control_bits = (PIND & B10000010) | ((PIND & B00011100) << 2);
      break;
    case B00000011:
      //1:1    ---L--T-
      //PINC = -L------
      control_bits = (PINC & B01000000) >> 2;
      break;
    case B00000010:
      //1:0    BCAS--T-
      //PINB = BCA-----
      //PINE = -S------
      control_bits = (PINB & B11100000) | ((PINE & B01000000) >> 2);
      break;
    case B00000001:
      //0:1    UDLR--T-
      //PINB = ---UDLR-
      control_bits = (PINB & B00011110) << 3;
      break;
  }

  //Setting bits LOW is what triggers a button press for the Sega Saturn
  control_bits = ~control_bits;
  //Always set T (TL ACK) High
  control_bits |= B00000010;
  
  PORTF = control_bits;
}
