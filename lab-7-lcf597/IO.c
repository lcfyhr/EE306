// IO.c
// This software configures the switch and LED
// You are allowed to use any switch and any LED, 
// although the Lab suggests the SW1 switch PF4 and Red LED PF1
// Runs on LM4F120 or TM4C123
// Program written by: Lars Christian Fyhr (lcf597)
// Date Created: March 30, 2018
// Last Modified: 10/29/2019
// Lab number: 7


#include "../inc/tm4c123gh6pm.h"
#include <stdint.h>

//------------IO_Init------------
// Initialize GPIO Port for a switch and an LED
// Input: none
// Output: none
void IO_Init(void) {
 // --UUU-- Code to initialize PF4 and PF2
	volatile int delay = 42;
	SYSCTL_RCGCGPIO_R |= 0x20;
	delay = 43;
	GPIO_PORTF_DIR_R |= 0x04;
	GPIO_PORTF_DIR_R &= (~0x10);
	GPIO_PORTF_DEN_R |= 0x14;
	GPIO_PORTF_PUR_R |= 0x10;
}

//------------IO_HeartBeat------------
// Toggle the output state of the  LED.
// Input: none
// Output: none
void IO_HeartBeat(void) {
 // --UUU-- PF2 is heartbeat
	GPIO_PORTF_DATA_R ^= 0x04;
}


//------------IO_Touch------------
// wait for release and press of the switch
// Delay to debounce the switch
// Input: none
// Output: none
void IO_Touch(void) {
 // --UUU-- wait for release; delay for 20ms; and then wait for press
	while((GPIO_PORTF_DATA_R & 0x10) != 0) {}
		int i = 0;
		while(i < 1600000) {
			i++;
		}
		while((GPIO_PORTF_DATA_R & 0x10) == 0) {}
}  

