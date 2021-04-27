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
  //Setup controller pins Up, Left, Down, Right, A, B, C
  //         -CBARDLU;
  DDRB  &= ~B01111111; //Set them up as inputs
  PORTB |=  B01111111; //Enable internal pull-ups
  
  //Setup controller pin L
  //         -L------;
  DDRC  &= ~B01000000; //Set it up as input
  PORTC |=  B01000000; //Enable internal pull-ups
  
  //Setup controller pins Z Y X and R as inputs
  //         R---XYZ-
  DDRD  &= ~B10001110; //Set them up as inputs
  PORTD |=  B10001110; //Enable internal pull-ups
  
  //Setup controller pin Start
  //         -S------;
  DDRE  &= ~B01000000; //Set it up as input
  PORTE |=  B01000000; //Enable internal pull-ups
  
  //Setup Saturn select pins S0 and S1
  //         ---1---0
  DDRD  &= ~B00010001; //Set them up as inputs
  PORTD |=  B00010001; //Enable internal pull-ups
  
  //Setup Saturn data pins D0, D1, D2, D3, and TL ACK
  //         0123--T-
  DDRF  |=  B11110010; //Set them up as outputs
  PORTF &= ~B11110010; //Set them LOW by default
  
  
  delay(1500);// Wait for the Saturn to start up.
}

void loop()
{
  //Setting bits LOW is what triggers a button press for the Sega Saturn
  switch (PIND & B00010001)
  {
    case B00000000:
      //0:0 Z Y X R
      //         ZYXR--T-
      PORTF &= ~B10110010;
      break;
    case B00010001:
      //1:1 - - - L
      //         ---L--T-
      PORTF &= ~B00010000;
      break;
    case B00000001:
      //1:0 B C A Start
      //        BCAS--T-
      PORTF |= B11110010;
      break;
    case B00010000:
      //0:1 Up Down Left Right
      //         UDLR--T-
      PORTF &= ~B10000000;
      break;
  }
}
