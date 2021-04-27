# Arduino-Saturn-Controller
Emulates a Sega Saturn controller using an Arduino Pro Micro. This uses all available pins on the Arduino Pro Micro, as well as two that aren't on the breakout. Those will require you to solder direct to the ATmega32U4 pins. Those pins are 12 and 40. (Refer to page 3 of [this datasheet](https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-7766-8-bit-AVR-ATmega16U4-32U4_Datasheet.pdf))

Wire up the Sega Saturn Controller cable according the chart below, using [this reference](https://gamesx.com/controldata/saturn.htm) where +5v (Inp) is TL ACK.

This is still an untested work in progress. Don't use this as a reference.


| Controller | PORT |
|------------|------|
| Up         | PB1  |
| Left       | PB2  |
| Down       | PB3  |
| Right      | PB4  |
| A          | PB5  |
| B          | PB6  |
| C          | PD7  |
| Z          | PD1  |
| Y          | PD2  |
| X          | PD3  |
| R          | PD7  |
| L          | PC6  |
| START      | PE6  |

|PORTB| Arduino          | Usage                |
|-----|------------------|----------------------|
| PB0 | Pin 8  D17       | (Not Used)           |
| PB1 | Arduino 15       | **Controller Up**    |
| PB2 | Arduino 16       | **Controller Left**  |
| PB3 | Arduino 14       | **Controller Down**  |
| PB4 | Arduino 8        | **Controller Right** |
| PB5 | Arduino 9        | **Controller A**     |
| PB6 | Arduino 16       | **Controller B**     |
| PB7 | Pin 12 D11       | **Controller C**     |

|PORTC| Arduino          | Usage                |
|-----|------------------|----------------------|
| PC0 | Not on pin-out   | (Unusable)           |
| PC1 | Not on pin-out   | (Unusable)           |
| PC2 | Not on pin-out   | (Unusable)           |
| PC3 | Not on pin-out   | (Unusable)           |
| PC4 | Not on pin-out   | (Unusable)           |
| PC5 | Not on pin-out   | (Unusable)           |
| PC6 | Arduino 5        | **Controller  L**    |
| PC7 | Pin 32 D13       | (Not Used)           |

|PORTD| Arduino          | Usage                |
|-----|------------------|----------------------|
| PD0 | Arduino 3        | **Saturn SEL0**      |
| PD1 | Arduino 2        | **Controller Z**     |
| PD2 | Arduino RXI      | **Controller Y**     |
| PD3 | Arduino TXO      | **Controller X**     |
| PD4 | Arduino 4        | **Saturn SEL1**      |
| PD5 | TXLED            | (Unusable)           |
| PD6 | Pin 26 on Chip   | (Not Used)           |
| PD7 | Arduino 6        | **Controller R**     |
 
|PORTE| Arduino          | Usage                |
|-----|------------------|----------------------|
| PE0 | Not on pin-out   | (Unusable)           |
| PE1 | Not on pin-out   | (Unusable)           |
| PE2 | Pin 33 (Grounded)| (Unusable)           |
| PE3 | Not on pin-out   | (Unusable)           |
| PE4 | Not on pin-out   | (Unusable)           |
| PE5 | Not on pin-out   | (Unusable)           |
| PE6 | Arduino 7        | **Controller Start** |
| PE7 | Not on pin-out   | (Unusable)           |
 
|PORTF| Arduino          | Usage                |
|-----|------------------|----------------------|
| PF0 | Pin 41 A5        | (Not Used)           |
| PF1 | Pin 40 A4        | **Saturn TL ACK**    |
| PF2 | Not on pin-out   | (Unusable)           |
| PF3 | Not on pin-out   | (Unusable)           |
| PF4 | Arduino A3       | **Saturn D3**        |
| PF5 | Arduino A2       | **Saturn D2**        |
| PF6 | Arduino A1       | **Saturn D1**        |
| PF7 | Arduino A0       | **Saturn D0**        |


Credits to [MickGyver](https://github.com/MickGyver) for the inspiration with his [DaemonBite-Arcade-Encoder](https://github.com/MickGyver/DaemonBite-Arcade-Encoder)
