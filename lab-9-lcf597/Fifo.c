// Fifo.c
// Runs on LM4F120/TM4C123
// Provide functions that implement the Software FiFo Buffer
// Created: 11/15/2017 
// Student names: change this to your names or look very silly
// Last modification date: change this to the last modification date or look very silly

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
// --UUU-- Declare state variables for Fifo
//        buffer, put and get indexes
#define SIZE 16
int32_t static PutInd;
int32_t static GetInd;
char static FIFO[SIZE];

// *********** Fifo_Init**********
// Initializes a software FIFO of a
// fixed size and sets up indexes for
// put and get operations
void Fifo_Init(){
// --UUU-- Complete this
	PutInd = 0;
	GetInd = 0;
}

// *********** Fifo_Put**********
// Adds an element to the FIFO
// Input: Character to be inserted
// Output: 1 for success and 0 for failure
//         failure is when the buffer is full
uint32_t Fifo_Put(char data){
// --UUU-- Complete this routine
	if((abs(PutInd-1))%SIZE == abs(GetInd)) {
		return 0;
	} else {
		FIFO[abs(PutInd)] = data;
		PutInd = (PutInd-1)%SIZE;
		return 1;
	}
   //Replace this
}

// *********** FiFo_Get**********
// Gets an element from the FIFO
// Input: Pointer to a character that will get the character read from the buffer
// Output: 1 for success and 0 for failure
//         failure is when the buffer is empty
uint32_t Fifo_Get(char *datapt){ 
//--UUU-- Complete this routine
	if (PutInd == GetInd) {
		return 0;
	} else {
		*datapt = FIFO[abs(GetInd)];
		GetInd = (GetInd-1)%SIZE;
		return 1;
	} // Replace this
}



