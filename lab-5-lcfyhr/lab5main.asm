

.ORIG x3000	; mainline

		
	LD R6, SADDR		; Setting up ISR
		
	LD R1, KBISR
		
	LD R2, KBISV
		
	STR R1, R2, #0
		
	LD R1, INT_EN
		
	LD R2, KBSR
		
	STR R1, R2, #0
	
	BR WAIT


SADDR	.FILL x2FFF
KBISR	.FILL x1700
KBISV	.FILL x0180
INT_EN	.FILL x4000
KBSR	.FILL xFE00

WAIT
		
	LEA R0, KB_INT		; Printing header
		
	PUTS
		
	LEA R0, NEWLINE		
	PUTS
	BR CHECK_CHAR
		
CONT	ADD R0, R0, #0	
	BRz WAIT		; check to see if no characters yet
	LD R3, NUM	
		
	ADD R2, R0, R3	
		
	BRn SPECIAL
		
	ADD R2, R2, #-10	; check to see if in range of numbers
		
	BRn NUMBER	
		
	LD R3, A		
		
	ADD R2, R0, R3		; check to see if in next set of Special Chars
		
	BRn SPECIAL
		
	LD R3, Z
		
	ADD R2, R0, R3		; check to see if in range of Uppercase
		
	BRnz UPPERCASE		
		
	LD R3, a			
		
	ADD R2, R0, R3		; check to see if in next set of Special Chars
		
	BRn SPECIAL			
		
	LD R3, z			
		
	ADD R2, R0, R3		; check to see if in range of lowercase
		
	BRnz LOWERCASE
		
	BR SPECIAL		; rest of range are Special Chars
		

	
	

A	.FILL x-0041	; start of Uppercase

Z	.FILL x-005A 	; end of Uppercase

a	.FILL x-0061 	; start of lowercase

z	.FILL x-007A	; end of lowercase
NUM	.FILL x-0030	; conver number to number
	


CHECK_CHAR		
	AND R2, R2, #0		; Clear R2
LOOP
	LDI R0, CHAR		; Poll x8000 for a new character
					
			
	ADD R2, R2, #1		
		
	LD R3, COUNTER		; load counter
		
	ADD R4, R2, R3		; see if incremented to counter yet
		
	BRzp FOUND			
		
	BRn LOOP


FOUND 	AND R1, R1, #0
	STI R1, CHAR
	BR CONT

COUNTER	.FILL x-8000


SPECIAL
		
	LEA R0, KB_SPC
		
	PUTS
		
	BR PRLINE
	
	

NUMBER
		
	LEA R0, KB_NUM
		
	PUTS
		
	BR PRLINE



UPPERCASE
		
	LEA R0, KB_UPP
		
	PUTS
		
	BR PRLINE



LOWERCASE

	LEA R0, KB_LOW
		
	PUTS
		
	BR PRLINE
		

PRLINE
	LEA R0, NEWLINE
	PUTS
	BR CHECK_CHAR

CHAR	.FILL x8000	; location of char after ISR
NEWLINE	.STRINGZ "\n"

KB_INT	.STRINGZ "WAITING FOR INTERRUPT..."

KB_UPP	.STRINGZ "KEYBOARD INT UPPERCASE"

KB_LOW	.STRINGZ "KEYBOARD INT LOWERCASE"

KB_NUM	.STRINGZ "KEYBOARD INT NUMBER"

KB_SPC	.STRINGZ "KEYBOARD INT SPECIAL CHARACTER"


	.END