// dac.c
// This software configures DAC output
// Lab 6 requires a minimum of 4 bits for the DAC, but you could have 5 or 6 bits
// Runs on LM4F120 or TM4C123
// Program written by: Lars Christian Fyhr (lcf597)
// Date Created: 3/6/17 
// Last Modified: 10/21/18 
// Lab number: 6
// Hardware connections
// PB0-3: Output Ports to DAC (R2-R DAC: R = 5 Kohms)

#include <stdint.h>
#include "../inc/tm4c123gh6pm.h"
// Code files contain the actual implemenation for public functions
// this file also contains an private functions and private data

// **************DAC_Init*********************
// Initialize 4-bit DAC, called once 
// Input: none
// Output: none
void DAC_Init(void){
	volatile int delay;
  SYSCTL_RCGCGPIO_R |= 0x02;   // enable Port B clock
  delay = 0;
  GPIO_PORTB_DIR_R |= 0x0F;     // output on PB0-3
  GPIO_PORTB_DEN_R |= 0x0F;     // enable digital on PB0-3
}

// **************DAC_Out*********************
// output to DAC
// Input: 4-bit data, 0 to 15 
// Input=n is converted to n*3.3V/15
// Output: none
void DAC_Out(uint32_t data){
	GPIO_PORTB_DATA_R = data;			// outputs DAC value given from SineWave array
}
