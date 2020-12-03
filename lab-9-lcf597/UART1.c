// Uart1.c
// Runs on LM4F120/TM4C123
// Use UART1 to implement bidirectional data transfer to and from 
// another microcontroller in Lab 9.  This time, interrupts and FIFOs
// are used.
// Daniel Valvano
// September 2, 2019
// Modified by EE345L students Charlie Gough && Matt Hawk
// Modified by EE345M students Agustinus Darmawan && Mingjie Qiu

/* Lab solution, Do not post
 http://users.ece.utexas.edu/~valvano/
*/

// This U0Rx PC4 (in) is connected to other LaunchPad PC5 (out)
// This U0Tx PC5 (out) is connected to other LaunchPad PC4 (in)
// This ground is connected to other LaunchPad ground

#include <stdint.h>
#include "Fifo.h"
#include "PLL.h"
#include "UART1.h"
#include "../inc/tm4c123gh6pm.h"
#include "ST7735.h"

#define PF1       (*((volatile uint32_t *)0x40025008))
#define PF2       (*((volatile uint32_t *)0x40025010))
#define PF3       (*((volatile uint32_t *)0x40025020))

uint32_t DataLost; 
// Initialize UART1
// Baud rate is 115200 bits/sec
// Make sure to turn ON UART1 Receiver Interrupt (Interrupt 6 in NVIC)
// Write UART1_Handler
void UART1_Init(void){
	SYSCTL_RCGCUART_R |= 0x02;  // activate UART1
  SYSCTL_RCGCGPIO_R |= 0x04;  // activate port C
	
	while ((SYSCTL_PRGPIO_R & 0x04) == 0) {}

  UART1_CTL_R &= ~0x00000001;;    // disable UART
	
	UART1_IBRD_R = 43;
	UART1_FBRD_R = 26;
	
	UART1_LCRH_R |= 0x00000070;
	
	UART1_CTL_R |= 0x301;
	
	GPIO_PORTC_AFSEL_R |= 0x30;
	GPIO_PORTC_DEN_R |= 0x30;

	GPIO_PORTC_PCTL_R = (GPIO_PORTC_PCTL_R&0xFF00FFFF)+0x00220000;
	GPIO_PORTC_AMSEL_R &= ~0x30;
		
	UART1_IM_R |= 0x10;
	UART1_IFLS_R = (UART1_IFLS_R &~0x38) +0x10;		
	
	NVIC_PRI1_R = (NVIC_PRI1_R&0xFFFF00FF)|0x00800000;
	NVIC_EN0_R |= 0x00000040;							// interrupt 6
   // --UUU-- complete with your code
}

// input ASCII character from UART
// spin if RxFifo is empty
// Receiver is interrupt driven
char UART1_InChar(void){
	while((UART1_FR_R&0x0010) != 0){}
	//wait until RXFE is 0
  return ((uint8_t)(UART1_DR_R&0xFF)); 
}

//------------UART1_InMessage------------
// Accepts ASCII characters from the serial port
//    and adds them to a string until ETX is typed
//    or until max length of the string is reached.
// Input: pointer to empty buffer of 8 characters
// Output: Null terminated string
// THIS FUNCTION IS OPTIONAL
void UART1_InMessage(char *bufPt){
}

//------------UART1_OutChar------------
// Output 8-bit to serial port
// Input: letter is an 8-bit ASCII character to be transferred
// Output: none
// Transmitter is busywait
void UART1_OutChar(char data){
  // --UUU-- complete with your code
	while ((UART1_FR_R&0x0020) != 0){}
	//wait until TXFF is 0
	UART1_DR_R = data;
}

// hardware RX FIFO goes from 7 to 8 or more items
// UART receiver Interrupt is triggered; This is the ISR
int RxCounter = 0;
void UART1_Handler(void){
  // --UUU-- complete with your code
	GPIO_PORTF_DATA_R ^= 0x02;
	GPIO_PORTF_DATA_R ^= 0x04;
	while((UART1_FR_R&0x0010) == 0){ //wait until RXFE is 0
		uint32_t data = UART1_InChar();
		Fifo_Put(data);
	}
	RxCounter++;
	UART1_ICR_R = 0x10; //Clear flag
	GPIO_PORTF_DATA_R ^= 0x08;
}
