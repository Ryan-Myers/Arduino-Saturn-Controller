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

uint8_t JoystickValues[31];
uint8_t ZYXRValues[157];

void setup() 
{
  //Setup controller pins Up, Down, Left, Right, A, B, C
  //         CBARLDU-;
  DDRB  &= ~B11111110; //Set them up as inputs
  PORTB |=  B11111110; //Enable internal pull-ups
  
  //Setup controller pin L
  //         -L------;
  DDRC  &= ~B01000000; //Set it up as input
  PORTC |=  B01000000; //Enable internal pull-ups
  
  //Setup controller pins Z Y X and R as inputs
  //         R--XYZ--
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
  PORTF &= ~B11110010; //Set them LOW by default

  // Interrupt 0 for clock (PD0, pin 3)
  EICRA &= ~(bit(ISC00) | bit (ISC01)); // Clear existing flags of interrupt 0 
  EICRA |= bit (ISC00);                 // Set interrupt on rising and falling
  
  // Interrupt 1 for clock (PD1, pin 2)
  EICRA &= ~(bit(ISC10) | bit (ISC11)); // Clear existing flags of interrupt 1 
  EICRA |= bit (ISC10);                 // Set interrupt on rising and falling
  
  // Enable both interrupts
  EIMSK |= bit(INT0)  | bit(INT1);

  //Define the PORTF outputs for all possible joystick values, always set TL high.
  //(PORTB & B00011110) gives the array value 0-30
  //                    UDLR--T-
  JoystickValues[0]  = B00000010; //Nothing
  JoystickValues[2]  = B10000010; //Up
  JoystickValues[4]  = B01000010; //Down
  JoystickValues[6]  = B00100010; //Up-Down
  JoystickValues[8]  = B00010010; //Left
  JoystickValues[10] = B10100010; //Up-Left
  JoystickValues[12] = B01100010; //Down-Left
  JoystickValues[14] = B11100010; //Up-Down-Left
  JoystickValues[16] = B00010010; //Right
  JoystickValues[18] = B10010010; //Up-Right
  JoystickValues[20] = B01010010; //Down-Right
  JoystickValues[22] = B11010010; //Up-Down-Right
  JoystickValues[24] = B00110010; //Left-Right
  JoystickValues[26] = B10110010; //Up-Left-Right
  JoystickValues[28] = B01110010; //Down-Left-Right
  JoystickValues[30] = B11110010; //Up-Down-Left-Right

  //Define the PORTF outputs for all possible Z Y X R values, always set TL high.
  //(PIND & B10011100) gives the array value 0-156
  //                    ZYXR--T-
  ZYXRValues[0]      = B00000010; //Nothing
  ZYXRValues[4]      = B10000010; //Z---
  ZYXRValues[8]      = B01000010; //-Y--
  ZYXRValues[12]     = B11000010; //ZY--
  ZYXRValues[16]     = B00100010; //--X-
  ZYXRValues[20]     = B10100010; //Z-X--
  ZYXRValues[24]     = B01100010; //-YX-
  ZYXRValues[28]     = B11100010; //ZYX-
  ZYXRValues[128]    = B00010010; //---R
  ZYXRValues[132]    = B10010010; //Z--R
  ZYXRValues[136]    = B01010010; //-Y-R
  ZYXRValues[140]    = B11010010; //ZY-R
  ZYXRValues[144]    = B00110010; //--XR
  ZYXRValues[148]    = B10110010; //Z-XR
  ZYXRValues[152]    = B01110010; //-YXR
  ZYXRValues[156]    = B11110010; //ZYXR
  
  delay(1500);// Wait for the Saturn to start up.
}

//Interrupt when Saturn S0 pin changes
ISR (INT0_vect)
{
}

//Interrupt when Saturn S1 pin changes
ISR (INT1_vect)
{
}

void loop()
{
  //Setting bits LOW is what triggers a button press for the Sega Saturn
  switch (PIND & B00000011)
  {
    case B00000000:
      //0:0 Z Y X R
      //         ZYXR--T-
      PORTF &= ~B10110010;
      break;
    case B00000011:
      //1:1 - - - L
      //         ---L--T-
      PORTF &= ~B00010000;
      break;
    case B00000001:
      //1:0 B C A Start
      //        BCAS--T-
      PORTF |= B11110010;
      break;
    case B00000010:
      //0:1 Up Down Left Right
      //         UDLR--T-
      PORTF &= ~B10000000;
      break;
  }
}
