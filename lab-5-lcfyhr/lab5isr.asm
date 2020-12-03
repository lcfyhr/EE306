.ORIG x1700			; ISR

		
	LD R0, ISR_R0		; Store registers
		
	LDI R0, KBDR		; Load the data of the KBDR into R0
		
	STI R0, KBSTR		; Store said data in x8000
		
	ST R0, ISR_R0		; Restore registers	
			
		
	RTI			; return to main program

		
		
	; Data fields
		

KBDR	.FILL xFE02

KBSTR	.FILL x8000
ISR_R0	.BLKW	1


.END


