	.ORIG x3000
	LEA R0, askEID		; load address of prompt
	PUTS			; output prompt to console
	LEA R1, usrEID		; set store location for input EID
inEID	GETC			; get next character of input EID
	ADD R2, R0, #-10	; check to see if user hit Enter
	BRz nextsection		; enter is pressed so move on
	STR R0, R1, #0		; store character of input EID
	ADD R1, R1, #1		; increment store location by 1
	OUT			; output last character entered to console
	BRnzp inEID		; loop back until Enter is pressed
nextsection			; move to comparison part

	LEA R0, newline		; load in address of newline
	PUTS			; move to new console line for final output

	AND R7, R7, #0		; clear R7 for marker on how to output	
	LDI R1, ptrL1		; load the starting address of the first node in LL1
	ADD R7, R7, #-1		; increment R7 to state on LL1
ldaddr				; load addresses of matching and entered EID strings
	LDR R2, R1, #1		; load the address of start of ASCII EID
	LEA R4, usrEID		; load the address of the entered EID

ldchar	LDR R3, R2, #0		; load the next character of matching EID
	LDR R5, R4, #0		; load the next character of entered EID
	BRz outputs		; if gets to null, they matched (R7 = -1 : LL1, R7 = 0 : LL2, R7 = 1 : nomatch)
	NOT R5, R5		; 
	ADD R5, R5, #1		; flip the ASCII code of R5 to negative
	ADD R6, R5, R3		; compare to see if the same ASCII code
	BRz nxtchar		; if same, compare next character
	BRnzp nxtnode		; if different, go to next node
nxtchar	ADD R2, R2, #1		; move address of matching EID down
	ADD R4, R4, #1		; move address of entered EID down
	BRnzp ldchar		; go back and load the next characters for comparison
nxtnode ADD R0, R1, #0		; save last node pointer into R0
	LDR R1, R1, #0		; load in next node address from previous node
	BRz nxtlist		; if zero, the linked list is over
	BRnzp ldaddr		; if not, send back to load the starting addresses of the EIDs
nxtlist LDI R1, ptrL2		; load the starting address of the first node in LL2
	ADD R7, R7, #1		; increment R7 to 0 or 1 to show now on LL2 or no match found in either
	BRp outputs		; if R7 is positive, no match found, go to outputs
	LD R0, ptrL2		; make last node pointer the pointer to LL2 (only happens once)
	BRnzp ldaddr		; loop back to load the address of new nodes

outputs				; blah blah blah now test outputs
	ADD R7, R7, #0		; nzp of R7
	BRn already		; R7 = -, go to already enrolled
	BRz added		; R7 = 0, go to added
	BRp nomatch		; R7 = +, go to not a match
already	LEA R0, usrEID		; load address of user's EID
	PUTS			; output EID
	LEA R0, out1		; load address of first out prompt (already enrolled)
	PUTS			; output the first out prompt
	BRnzp end
added				; perform pointer swap and output of added
	LDI R2, ptrL1		; load the starting node ptr to LL1
	STI R1, ptrL1		; store the swapping node pointer to front of L1
	LDR R3, R1, #0		; load next ptr address into R3
	STR R2, R1, #0		; store address of LL1 first ptr into current ptr address
	STR R3, R0, #0		; store next ptr address at last pointer address (skips swapped node)
	
	LEA R0, usrEID		; load address of user's EID
	PUTS			; output EID
	LEA R0, out2		; load address of second out prompt (added)
	PUTS			; output the second out prompt
	BRnzp end
nomatch LEA R0, out3		; load address of third out prompt (no match)
	PUTS			; output the third out prompt
	BRnzp end
end	HALT
usrEID	.BLKW 6			; leave 6 spots for user EID
ptrL1	.FILL x4000		; pointer to Linked List 1
ptrL2	.FILL x4001		; pointer to Linked List 2
askEID	.STRINGZ "Type EID and press Enter:"
newline	.STRINGZ "\n"		; give a new line
out1	.STRINGZ " already enrolled in EE 306\n"
out2	.STRINGZ " added to EE 306\n"
out3	.STRINGZ "the EID does not match\n"
	.END
