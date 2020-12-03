; Print.s
; Student names: Lars Christian Fyhr (lcf597)
; Last modification date: 10/29/2019
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 

    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix

    AREA    |.text|, CODE, READONLY, ALIGN=2
		PRESERVE8
    THUMB

  

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
; Lab 7 requirement is for at least one local variable on the stack with symbolic binding
LCD_OutDec

	MOV R1, R0
	MOV R0, #0
	CMP R1, #10   ; check to see if its < 10
	BLO small
	
loop

	MOV R3, #10
	UDIV R2, R1, R3
	CMP R2, #0
	BEQ over			; went too far in division
	MUL R2, R2, R3
	SUBS R3, R1, R2		
	PUSH {R3}
	ADD R0, R0, #1
	MOV R3, #10
	UDIV R1, R1, R3
	B loop
	
over
	
	PUSH {R1}
	ADD R0, R0, #1		; adjust to get last digit
	MOV R3, R0

loop2
	
	CMP R3, #0
	BEQ fin
	POP {R0}
	ADD R0, R0, #48
	PUSH {R1, R2, R3,LR}
	BL ST7735_OutChar		; if not done, output the character and proceed to next
	POP {R1, R2, R3,LR}
	SUB R3, R3, #1
	B loop2
	
small

	ADD R1, R1, #48
	PUSH {R1, R2, R3,LR}
	MOV R0, R1
	BL ST7735_OutChar		; output the direct corresponding ASCII digit (if < 10)
	POP {R1,R2,R3,LR}
	B fin
	
fin

      BX  LR
	  		
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.01, range 0.00 to 9.99
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.00 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.89 "
;       R0=123,  then output "1.23 "
;       R0=999,  then output "9.99 "
;       R0>999,  then output "*.** "
; Invariables: This function must not permanently modify registers R4 to R11
; Lab 7 requirement is for at least one local variable on the stack with symbolic binding
LCD_OutFix

	MOV R1, #100
	UDIV R2, R0, R1			
	CMP R2, #10
	BHS toobig
	B onesPlace
	
toobig

	MOV R0, #42
	PUSH {R0,R1,R2,R3,LR}
	BL ST7735_OutChar
	POP {R0,R1,R2,R3,LR}
	MOV R0, #46
	PUSH {R0,R1,R2,R3,LR}
	BL ST7735_OutChar
	POP {R0,R1,R2,R3,LR}
	MOV R0, #42
	PUSH {R0,R1,R2,R3,LR}
	BL ST7735_OutChar
	POP {R0,R1,R2,R3,LR}
	PUSH {R0,R1,R2,R3,LR}
	BL ST7735_OutChar
	POP {R0,R1,R2,R3,LR}
	B dones

onesPlace
	
	MUL R2, R2, R1			
	SUB R0, R0, R2			
	UDIV R2, R2, R1			
	ADD R2, R2, #48			
	MOV R3, R0				
	MOV R0, R2
	PUSH {R0,R1,R2,R3,LR}
	BL ST7735_OutChar
	POP {R0,R1,R2,R3,LR}
	MOV R0, #46
	PUSH {R0,R1,R2,R3,LR}	
	BL ST7735_OutChar
	POP {R0,R1,R2,R3,LR}
	B tensPlace
	
tensPlace

	MOV R1, #10
	UDIV R2, R3, R1			
	ADD R2, R2, #48			
	MOV R0, R2
	PUSH {R0,R1,R2,R3,LR}
	BL ST7735_OutChar
	POP {R0,R1,R2,R3,LR}
	SUB R2, R2, #48			
	MUL R2, R2, R1			
	SUB R3, R3, R2			
	B hundredsPlace
	
hundredsPlace
	
	MOV R1, #1
	UDIV R2, R3, R1			
	ADD R2, R2, #48			
	MOV R0, R2
	PUSH {R0,R1,R2,R3,LR}
	BL ST7735_OutChar
	POP {R0,R1,R2,R3,LR}
	SUB R2, R2, #48			
	MUL R2, R2, R1			
	SUB R3, R3, R2		
	B dones

dones 

     BX   LR
 
     ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

     ALIGN          ; make sure the end of this section is aligned
     END            ; end of file
