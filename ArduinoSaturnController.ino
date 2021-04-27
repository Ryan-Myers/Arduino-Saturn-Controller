//Setting bits LOW is what triggers a button press for the Sega Saturn

/*
 * ---------------------
 * | Controller | PORT |
 * |------------|------|
 * | Up         | PB1  |
 * | Left       | PB2  |
 * | Down       | PB3  |
 * | Right      | PB4  |
 * | A          | PB5  |
 * | B          | PB6  |
 * | C          | PD7  |
 * | Z          | PD1  |
 * | Y          | PD2  |
 * | X          | PD3  |
 * | R          | PD7  |
 * | L          | PC6  |
 * | START      | PE6  |
 * ---------------------
 */
 /* 
  * --------------------------------------------
  * |PORTB| Arduino         | Usage            |
  * |-----------------------|------------------|
  * | PB0 | Pin 8  D17      | (Not Used)       |
  * | PB1 | Arduino 15      | Controller Up    |
  * | PB2 | Arduino 16      | Controller Left  |
  * | PB3 | Arduino 14      | Controller Down  |
  * | PB4 | Arduino 8       | Controller Right |
  * | PB5 | Arduino 9       | Controller A     |
  * | PB6 | Arduino 16      | Controller B     |
  * | PB7 | Pin 12 D11      | Controller C     |
  * --------------------------------------------
  */
 /* 
  * --------------------------------------------
  * |PORTC| Arduino         | Usage            |
  * |-----------------------|------------------|
  * | PC0 | Not on pin-out  | (Unusable)       |
  * | PC1 | Not on pin-out  | (Unusable)       |
  * | PC2 | Not on pin-out  | (Unusable)       |
  * | PC3 | Not on pin-out  | (Unusable)       |
  * | PC4 | Not on pin-out  | (Unusable)       |
  * | PC5 | Not on pin-out  | (Unusable)       |
  * | PC6 | Arduino 5       | Controller  L    |
  * | PC7 | Pin 32 D13      | (Not Used)       |
  * --------------------------------------------
  */
 /* 
  * --------------------------------------------
  * |PORTD| Arduino         | Usage            |
  * |-----------------------|------------------|
  * | PD0 | Arduino 3       | Saturn SEL0      |
  * | PD1 | Arduino 2       | Controller Z     |
  * | PD2 | Arduino RXI     | Controller Y     |
  * | PD3 | Arduino TXO     | Controller X     |
  * | PD4 | Arduino 4       | Saturn SEL1      |
  * | PD5 | TXLED           | (Unusable)       |
  * | PD6 | Pin 26 on Chip  | (Not Used)       |
  * | PD7 | Arduino 6       | Controller R     |
  * --------------------------------------------
  */
 /* 
  * --------------------------------------------
  * |PORTE| Arduino         | Usage            |
  * |-----------------------|------------------|
  * | PE0 | Not on pin-out  | (Unusable)       |
  * | PE1 | Not on pin-out  | (Unusable)       |
  * | PE2 | Pin 33(Grounded)| (Unusable)       |
  * | PE3 | Not on pin-out  | (Unusable)       |
  * | PE4 | Not on pin-out  | (Unusable)       |
  * | PE5 | Not on pin-out  | (Unusable)       |
  * | PE6 | Arduino 7       | Controller Start |
  * | PE7 | Not on pin-out  | (Unusable)       |
  * --------------------------------------------
  */
 /* 
  * --------------------------------------------
  * |PORTF| Arduino         | Usage            |
  * |-----------------------|------------------|
  * | PF0 | Pin 41 A5       | (Not Used)       |
  * | PF1 | Pin 40 A4       | Saturn TL ACK    |
  * | PF2 | Not on pin-out  | (Unusable)       |
  * | PF3 | Not on pin-out  | (Unusable)       |
  * | PF4 | Arduino A3      | Saturn D3        |
  * | PF5 | Arduino A2      | Saturn D2        |
  * | PF6 | Arduino A1      | Saturn D1        |
  * | PF7 | Arduino A0      | Saturn D0        |
  * --------------------------------------------
  */ 
//zyxr uplr bcas

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
  //S0 = 0 and S1 = 0
  //0:0 Z Y X R
  if ((PIND & B00010001) == B00000000)
  {
    
    //D0-D1-D2-D3-IG-IG-TL-IG
    //         ZYXR--T-
    PORTF &= ~B10110010;
  }
  //S0 = 1 and S1 = 1
  //1:1 - - - L
  else if ((PIND & B00010001) == B00010001)
  {
    //D0-D1-D2-D3-IG-IG-TL-IG
    //IG-IG-IG-L--IG-IG-TL-IG
    //         ---L--T-
    PORTF &= ~B00010000;
  }
  //S0 = 1 and S1 = 0
  //1:0 B C A Start
  else if (PIND & B00000001)
  {
    //D0-D1-D2-D3-IG-IG-TL-IG
    //B--C--A--St-IG-IG-TL-IG
    //        BCAS--T-
    PORTF |= B11110010;
  }
  //S0 = 0 and S1 = 1
  //0:1 Up Down Left Right
  else if (PIND & B00010000)
  {
    //D0-D1-D2-D3-IG-IG-TL-IG
    //Up-Dn-Lt-Rt-IG-IG-TL-IG
    //         UDLR--T-
    PORTF &= ~B10000000;
  }
}
