// Lab9.c
// Runs on LM4F120 or TM4C123
// Student names: Hunter Pischke and Max Withrow
// Last modification date: 4/25/19
// Last Modified: 11/14/2018

// Analog Input connected to PE2=ADC1
// displays on Sitronox ST7735
// PF3, PF2, PF1 are heartbeats
// This U0Rx PC4 (in) is connected to other LaunchPad PC5 (out)
// This U0Tx PC5 (out) is connected to other LaunchPad PC4 (in)
// This ground is connected to other LaunchPad ground
// * Start with where you left off in Lab8. 
// * Get Lab8 code working in this project.
// * Understand what parts of your main have to move into the UART1_Handler ISR
// * Rewrite the SysTickHandler
// * Implement the s/w Fifo on the receiver end 
//    (we suggest implementing and testing this first)

#include <stdint.h>

#include "ST7735.h"
#include "PLL.h"
#include "ADC.h"
#include "print.h"
#include "../inc/tm4c123gh6pm.h"
#include "UART1.h"
#include "FiFo.h"

//*****the first three main programs are for debugging *****
// main1 tests just the ADC and slide pot, use debugger to see data
// main2 adds the LCD to the ADC and slide pot, ADC data is on Nokia
// main3 adds your convert function, position data is no Nokia

void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts

#define PF1       (*((volatile uint32_t *)0x40025008))
#define PF2       (*((volatile uint32_t *)0x40025010))
#define PF3       (*((volatile uint32_t *)0x40025020))
uint32_t Data;      // 12-bit ADC
uint32_t Position;  // 32-bit fixed-point 0.001 cm
int first;
int second;
int third;
int total;

// Initialize Port F so PF1, PF2 and PF3 are heartbeats
void PortF_Init(void){
// Intialize PortF for hearbeat
	volatile int dummy;
	SYSCTL_RCGCGPIO_R |= 0x20;	//Clock in front of PORT F
	dummy = 7;
	GPIO_PORTF_DEN_R |= 0xE;
	GPIO_PORTF_DIR_R |= 0xE;
}


uint32_t Status[20];             // entries 0,7,12,19 should be false, others true
char GetData[10];  // entries 1 2 3 4 5 6 7 8 should be 1 2 3 4 5 6 7 8
int main1(void){ // Make this main to test FiFo
  Fifo_Init();   // Assuming a buffer of size 6
  for(;;){
    Status[0]  = Fifo_Get(&GetData[0]);  // should fail,    empty
    Status[1]  = Fifo_Put(1);            // should succeed, 1 
    Status[2]  = Fifo_Put(2);            // should succeed, 1 2
    Status[3]  = Fifo_Put(3);            // should succeed, 1 2 3
    Status[4]  = Fifo_Put(4);            // should succeed, 1 2 3 4
    Status[5]  = Fifo_Put(5);            // should succeed, 1 2 3 4 5
    Status[6]  = Fifo_Put(6);            // should succeed, 1 2 3 4 5 6
    Status[7]  = Fifo_Put(7);            // should fail,    1 2 3 4 5 6 
    Status[8]  = Fifo_Get(&GetData[1]);  // should succeed, 2 3 4 5 6
    Status[9]  = Fifo_Get(&GetData[2]);  // should succeed, 3 4 5 6
    Status[10] = Fifo_Put(7);            // should succeed, 3 4 5 6 7
    Status[11] = Fifo_Put(8);            // should succeed, 3 4 5 6 7 8
    Status[12] = Fifo_Put(9);            // should fail,    3 4 5 6 7 8 
    Status[13] = Fifo_Get(&GetData[3]);  // should succeed, 4 5 6 7 8
    Status[14] = Fifo_Get(&GetData[4]);  // should succeed, 5 6 7 8
    Status[15] = Fifo_Get(&GetData[5]);  // should succeed, 6 7 8
    Status[16] = Fifo_Get(&GetData[6]);  // should succeed, 7 8
    Status[17] = Fifo_Get(&GetData[7]);  // should succeed, 8
    Status[18] = Fifo_Get(&GetData[8]);  // should succeed, empty
    Status[19] = Fifo_Get(&GetData[9]);  // should fail,    empty
  }
}

// Get fit from excel and code the convert routine with the constants
// from the curve-fit
uint32_t Convert(uint32_t input){
	uint32_t output;
	if (input <= 374) {
	output = (input/21) + 15;
	} else if (input > 374 & input < 3075){
	output = (input/39) + 23;
	}	else if (input >= 3075) {
	output = (input/46) + 35;
	}
  return output; // replace this line with your Lab 8 solution
}

void SysTick_Init(){
	NVIC_ST_CTRL_R = 0;
	NVIC_ST_RELOAD_R = 1333333-1;
	NVIC_ST_CURRENT_R = 0;
	NVIC_ST_CTRL_R = 0x00000007;
}

// final main program for bidirectional communication
// Sender sends using SysTick Interrupt
// Receiver receives using RX
char arr[8];
int main(void){ 
  PLL_Init(Bus80MHz);     // Bus clock is 80 MHz 
  ST7735_InitR(INITR_REDTAB);
  ADC_Init();    // initialize to sample ADC
  PortF_Init();
	Fifo_Init();
  UART1_Init();       // initialize UART
//Enable SysTick Interrupt by calling SysTick_Init()
	SysTick_Init();
	ST7735_OutString("Empty");
	ST7735_OutString("     ");
  EnableInterrupts();
  while(1){
    //--UUU--Complete this  - see lab manual
		int val = Fifo_Get(&arr[0]);
		ST7735_SetCursor(0,0);
		if(val == 1){
			total = 0;
			for(int i = 1; i < 8; i++){
				Fifo_Get(&arr[i]);
			}
			if (arr[0] == 0x02) {
				DisableInterrupts();
				total += (arr[1] - 0x30) * 100;
				total += (arr[3] - 0x30) * 10;
				total += (arr[4] - 0x30);
				LCD_OutFix(total);
				EnableInterrupts();
			}
			ST7735_SetCursor(4,0);
			ST7735_OutString(" cm");
		}
  }
}

/* SysTick ISR
*/
int TxCounter = 0;
void SysTick_Handler(void){
 //Sample ADC, convert to distance, create 8-byte message, send message out UART1
	GPIO_PORTF_DATA_R ^= 0x08;
	uint32_t sample = ADC_In();
	GPIO_PORTF_DATA_R ^= 0x04;
	uint32_t distance = Convert(sample);
	UART1_OutChar(0x02);
	first = (distance/100)+0x30;
	second = ((distance%100)/10)+0x30;
	third = (distance%10)+0x30;
	UART1_OutChar(first);
	UART1_OutChar(0x2E);
	UART1_OutChar(second);
	UART1_OutChar(third);
	UART1_OutChar(0x0D);
	UART1_OutChar(0x03);
	TxCounter++;
	GPIO_PORTF_DATA_R ^= 0x02;
}

