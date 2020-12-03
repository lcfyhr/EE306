// Sound.c
// This module contains the SysTick ISR that plays sound
// Runs on LM4F120 or TM4C123
// Program written by: Lars Christian Fyhr (lcf597)
// Date Created: 3/6/17 
// Last Modified: 10/21/19 
// Lab number: 6
// Hardware connections
// PE0-3: Input Switches for Piano Keys
// PB0-3: Output Ports to DAC (R-2R DAC: R = 5 Kohms)

// Code files contain the actual implementation for public functions
// this file also contains an private functions and private data
#include <stdint.h>
#include "dac.h"
#include "../inc/tm4c123gh6pm.h"

// initialize SineWave approximation array and the index

uint32_t SineWave[32] = {7,9,11,12,13,14,14,15,15,15,15,14,14,13,12,11,9,7,5,4,3,2,2,1,1,1,1,2,2,3,4,5};
int indx;
//int heart;							// only to see heartbeat on board
  

// **************Sound_Init*********************
// Initialize digital outputs and SysTick timer
// Called once, with sound/interrupts initially off
// Input: none
// Output: none
void Sound_Init() {
	DAC_Init();
	indx = 0;
	NVIC_ST_CTRL_R = 0;
	NVIC_ST_RELOAD_R = 0x000000FF;
	NVIC_ST_CURRENT_R = 0;
	NVIC_SYS_PRI3_R = (NVIC_SYS_PRI3_R & 0x00FFFFFF) | 0x20000000;
	NVIC_ST_CTRL_R = 0x0007;
}

// **************Heartbeat_Init*********************
// Initialize digital on-board output for flashing heartbeat
// Called once, with interrupts off
// Input: none
// Output: none
void Heartbeat_Init(void) {
	volatile int delay;
  SYSCTL_RCGCGPIO_R |= 0x20;   // enable Port F Clock
  delay = 0;
  GPIO_PORTF_DIR_R |= 0x08;     // output on PF3
  GPIO_PORTF_DEN_R |= 0x08;     // enable digital on PF3
}

// **************SysTick_Handler*********************
// Toggles heartbeat, sends information to DAC_Out
// Use crossed out lines to visually see heartbeat on board
// Called everytime Count flag runs down, when interrupts on
// Input: none
// Output: none
void SysTick_Handler(void) {
//		if (heart%1000 == 1) {
		GPIO_PORTF_DATA_R ^= 0x08;
//		}
		indx = (indx + 1)%32;				
		DAC_Out(SineWave[indx]);		// outputs one DAC output per handle for a whole cycle (then repeats)
//		heart++;
}

// **************Sound_Play*********************
// Start sound output, and set Systick interrupt period 
// Sound continues until Sound_Play called again
// This function returns right away and sound is produced using a periodic interrupt
// Input: interrupt period
//           Units of period to be determined by YOU
//           Maximum period to be determined by YOU
//           Minimum period to be determined by YOU
//         if period equals zero, disable sound output
// Output: none

	
void Sound_Play(uint32_t period){
		NVIC_ST_RELOAD_R = period - 1;
}


