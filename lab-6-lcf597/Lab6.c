// Lab6.c
// Runs on LM4F120 or TM4C123
// Use SysTick interrupts to implement a 4-key digital piano
// MOOC lab 13 or EE319K lab6 starter
// Program written by: Lars Christian Fyhr (lcf597)
// Date Created: 3/6/17 
// Last Modified: 10/21/19 
// Lab number: 6
// Hardware connections
// PE0-3: Input Switches for Piano Keys
// PB0-3: Output Ports to DAC (R= xxx Kohms)

#include <stdint.h>
#include "../inc/tm4c123gh6pm.h"
#include "Sound.h"
#include "Piano.h"
#include "TExaS.h"

#define A 5681/2;
#define G 6378/2;
#define E 7585/2;
#define C 9557/2;


// basic functions defined at end of startup.s
void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts


int main(void){      
	DisableInterrupts();
  TExaS_Init(SW_PIN_PE3210,DAC_PIN_PB3210,ScopeOn);    // bus clock at 80 MHz
  Piano_Init();
  Sound_Init();
	Heartbeat_Init();
	int Key;
	int frq;																						// initialize the piano key and its output frequency
  // other initialization
  while(1){ 
		Key = Piano_In();
		if (Key == 0x08) {
			frq = A;
		} 
		if (Key == 0x04) {
			frq = G;
		} 																								// set output frequency given inputted key
		if (Key == 0x02) {
			frq = E;
		} 
		if (Key == 0x01) {
			frq = C;
		} 
		if (Key != 0x00) {
			EnableInterrupts();															// when keys pressed, play given sound at frequency
			Sound_Play(frq);
		}
		if (Key == 0x00) {
			DisableInterrupts();														// when keys not pressed, stop sounds
		}
  }    
}


