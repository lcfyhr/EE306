	.ORIG x3000;

	JSR Clear_Field 	; Sub-routine call to clear/Initialize the mine field
	JSR Plant_Mines		; Plant the actual mines
reprint	JSR Print_Field		; print out the playing field of mines
	JSR Check_End		; check to see if an ending condition met
	JSR Prompt_User		; ask the user for an input
	JSR Eval_Move		; evaluate the user's input
	BR reprint		; reprint the minefield
	
end	HALT

;_____________________________________________________________________________

Clear_Field

	LD	R0, MATRIXSTART
	LD	R1, MATRIXEND
	LD	R2, CLEARCODE
CF_Loop
	STR	R2, R0, #0
	ADD	R0, R0, #1
	ADD	R3, R0, R1
	BRn	CF_Loop

	RET

MATRIXSTART	.FILL	x4000
MATRIXEND	.FILL	x-4040
CLEARCODE	.FILL	x-1


;_____________________________________________________________________________

Plant_Mines
	ST	R7, PM_S7

	LD	R1, NEG_ENTER
	ADD	R1, R1, R1
	AND	R3, R3, #0		; running sum
	LD	R4, PM_MASK
	LD	R5, MATRIXSTART
	LD	R6, MINE_CODE

	LEA	R0, PM_Prompt
	PUTS
	LD	R0, ENTER
	OUT
PM_Loop
	GETC				; read a character and echo it
	OUT
	ADD	R2, R0, R1		; check for enter
	BRnz	PM_Done
	ADD	R3, R3, R0		; add new value to sum
	AND	R3, R3, R4		; mask it
	ADD	R2, R3, R5		; calculate address
	STR	R6, R2, #0		; store -1
	BR	PM_Loop

PM_Done
	LD	R7, PM_S7
	RET

MINE_CODE	.FILL	-2
ENTER		.FILL	xA
NEG_ENTER	.FILL	x-A
PM_MASK	.FILL	x003F
PM_Prompt	.STRINGZ	"Type some characters"

PM_S7	.BLKW	1

;_______________________________________________________________________

Print_Field
	ST	R7, PF_S7
	LD R1, MATRIXSTART		; load x4000 to R1
	AND R4, R4, #0			; line counter
	ADD R2, R1, #0			; copy R1 to R2
	LD R0, ASCII_SPACE
	OUT
prntspt	LDR R0, R2, #0			; load the char
	ADD R6, R0, #3			; check if found mine
	BRz prntX			;
	LDR R0, R2, #0		
	BRn prnt_			; spot hasn't been guessed, print empty
	BRzp prntval			; print value of mines touching spot

prnt_	LD R0, ASCII_UNKNOWN		; print _
	OUT
	BR prntgap

prntval LD R6, ASCII_OFFSET
	ADD R0, R0, R6			; ASCII Offset to print number
	OUT
	BR prntgap

prntX	LD R0, ASCII_MINE
	OUT
	BR prntgap

prntgap	LD R0, ASCII_SPACE
	OUT
	BR nextspot

nextspot
	ADD R2, R2, #8			; move to spot at right
	LD R5, MATRIXEND		
	ADD R3, R2, R5			; test to see if outside matrix 		
	BRzp nxtline			; move to next line 
	BR prntspt

nxtline LD R0, ASCII_SPACE
	OUT				; print out another space
	LD R5, ASCII_OFFSET						
	ADD R0, R4, R5			; ASCII Offset
	OUT				; print out row number
	ADD R4, R4, #1			; increment row
	LEA R0, SKIPLINE		;
	PUTS
	LD R0, ASCII_SPACE
	OUT
	ADD R3, R4, #-8			; if row 8, stop and go to bottom line
	BRzp endprnt				
	ADD R2, R1, R4			; next row start
	BR prntspt			; back to print row

endprnt	LEA R0, SKIPLINE
	PUTS
	LEA R0, BOTLINE
	PUTS
	LEA R0, SKIPLINE
	PUTS
	
	LD R7, PF_S7
	RET

PF_S7	.BLKW	1
ASCII_OFFSET	.FILL x0030
ASCII_MINE	.STRINGZ	"X"
ASCII_SPACE	.STRINGZ	" "	
ASCII_UNKNOWN	.STRINGZ	"_"
SKIPLINE	.STRINGZ	"\n"
BOTLINE		.STRINGZ	" A B C D E F G H"

;____________________________________________________________________________________

Check_End
	ST R7, CE_S7
	LD R1, MATRIXSTART
	LD R2, MATRIXEND
	AND R6, R6, #0

nxttest	LDR R3, R1, #0
	ADD R3, R3, #3			; check for -3 (mine hit)
	BRz endgame			; game over
	LDR R3, R1, #0
	ADD R3, R3, #1
	BRnp notopen			; spot is not a -1 (open)
	ADD R6, R6, #1			; check for any open spots
notopen ADD R1, R1, #1
	ADD R4, R1, R2
	BRz tstdone			; no values returned -3
	BR nxttest			; test to see if any values are -3 (mine hit)
	
endgame LEA R0, ENDOUT
	PUTS
	BR end

tstdone	ADD R6, R6, #0			; no more open spots
	BRz winner
	LD R7, CE_S7
	RET

winner	LEA R0, WINOUT
	PUTS
	BR end

CE_S7		.BLKW 		1
ENDOUT		.STRINGZ 	"\nGame Over! You Hit a Mine!\n"
WINOUT		.STRINGZ	"\nYou Won!\n"

;____________________________________________________________________________________

Prompt_User
	ST	R7, PU_S7
	
	LEA	R0, PU_PROMPT		; print out prompt
	PUTS
	
	GETC				; read 2 chars
	OUT
	ST	R0, PU_CHAR1
	GETC
	OUT
	ST	R0, PU_CHAR2

	LEA	R0, PU_FILL_SCREEN	; print some blank lines
	PUTS	
	LEA	R0, PU_CHAR1		; R0 returns pointer to inputs

	LD	R7, PU_S7
	RET

PU_PROMPT	.FILL	xA
		.STRINGZ	">>> "
PU_CHAR1	.BLKW	1	0
PU_CHAR2	.BLKW	2	0
PU_FILL_SCREEN	.BLKW	4 	10
	.FILL	0

PU_S7	.BLKW	1
EM_S7	.BLKW 	1
NEG_ASCII_A	.FILL	x-41
EIGHT	.FILL 	#8

;________________________________________________________________________________

Eval_Move
	ST R7, EM_S7

	LDR R1, R0, #0			; load first char of move
	LD R6, NEG_ASCII_A
	ADD R1, R1, R6			; checking offset
	BRn Invalid
	ADD R2, R1, #-7			; if offset > 7, invalid
	BRp Invalid
	LD R2, EIGHT			; R2 -> 8
	AND R3, R3, #0			; clear for sum

Mult	ADD R3, R3, R1			; multiply by 8
	ADD R2, R2, #-1			; decrement counter
	BRp Mult			; keep going until done multiplying

	LDR R2, R0, #1			; load second char of move
	LD R6, NEG_ASCII_0		
	ADD R2, R2, R6			; ASCII number offset
	BRn Invalid
	ADD R1, R2, #-7			; if offset > 7 invalid
	BRp Invalid
	ADD R3, R3, R2			; add both offsets to find location #	
	
	LD R4, MATRIX_START		
	ADD R5, R4, R3			; pointer to location selected
	LDR R6, R5, #0			; load contents of location
	BRzp Known			; location is already known
	AND R2, R2, #0			;
	ADD R7, R6, #2			; check if its a mine
	BRz MineFound			; user selected a mine
	BRnp MinesTouching		; move on to mines touching

MineFound
	AND R1, R1, 0
	ADD R1, R1, #-3
	STR R1, R5, #0			; store -3 to signify mine hit
	LD R7, EM_S7
	RET
	
Invalid	LEA R0, INVOUT			 
	PUTS
	LD R6, prompt			; ouput that the move was invalid
	JMP R6				; go back to get new move

Known 	LEA R0, KNOWNOUT		
	PUTS	
	LD R6, prompt			; output that the move is already known
	JMP R6				; go back to get new move

MinesTouching
	LD R6, MATRIX_BOUND1
	ADD R3, R5, R6			; check if top-left corner
	BRz topleft
	LD R6, MATRIX_BOUND2
	ADD R3, R5, R6			; check if bot-left corner
	BRz botleft
	LD R6, MATRIX_BOUND3
	ADD R3, R5, R6			; check if top-right corner
	BRz toprght	
	LD R6, MATRIX_BOUND4		
	ADD R3, R5, R6			; check if bot-right corner
	BRz botrght
	LD R6, MATRIX_BOUND2
	ADD R3, R5, R6			; check if left side
	BRn left	
	LD R6, MATRIX_BOUND3	
	ADD R3, R5, R6			; check if right side
	BRp right	
	AND R6, R5, x000F		; Mask the location with 000F
	BRz top				; if last number 0, its top
	ADD R3, R6, #-8			; if last number 8, its top
	BRz top
	ADD R3, R6, #-7			; if last number 7, its bottom
	BRz bottom
	ADD R3, R6, x-F			; if last number F (15), its bottom		
	BRz bottom
	BR all				; if none of the parameters met, check all

topleft	JSR checkMR
	JSR checkBM
	JSR checkBR
	BR reveal

botleft JSR checkMR
	JSR checkTM
	JSR checkTR
	BR reveal

toprght	JSR checkML
	JSR checkBM
	JSR checkBL
	BR reveal

botrght	JSR checkML
	JSR checkTM
	JSR checkTL
	BR reveal

left	JSR checkTM
	JSR checkBM
	JSR checkTR
	JSR checkMR
	JSR checkBR
	BR reveal

right	JSR checkTM
	JSR checkBM
	JSR checkTL
	JSR checkML
	JSR checkBL
	BR reveal

top	JSR checkML
	JSR checkBL
	JSR checkBM
	JSR checkBR
	JSR checkMR
	BR reveal

bottom	JSR checkML
	JSR checkTL
	JSR checkTM
	JSR checkTR
	JSR checkMR
	BR reveal

all	JSR checkTL
	JSR checkML
	JSR checkBL
	JSR checkTM
	JSR checkBM
	JSR checkTR
	JSR checkMR
	JSR checkBR
	BR reveal

	
checkTL	ST R7, temp_S7
	ADD R4, R5, #-9			; move to check top-left adjacent spot
	BR checkit

checkML	ST R7, temp_S7
	ADD R4, R5, #-8			; move to check mid-left adjacent spot
	BR checkit

checkBL	ST R7, temp_S7
	ADD R4, R5, #-7			; move to check bot-left adjacent spot
	BR checkit

checkTM	ST R7, temp_S7
	ADD R4, R5, #-1			; move to check top-mid adjacent spot
	BR checkit

checkBM	ST R7, temp_S7
	ADD R4, R5, #1			; move to check bot-mid adjacent spot
	BR checkit

checkTR	ST R7, temp_S7
	ADD R4, R5, #7			; move to check top-right adjacent spot
	BR checkit

checkMR	ST R7, temp_S7
	ADD R4, R5, #8			; move to check mid-right adjacent spot
	BR checkit

checkBR	ST R7, temp_S7
	ADD R4, R5, #9			; move to check bot-right adjacent spot
	BR checkit

checkit	LDR R3, R4, #0			; load contents of spot and check for mine
	ADD R3, R3, #2			; if 0 ouput, mine adjacent
	BRnp notmine			; branch to skip increment
	ADD R2, R2, #1			; add a mine touching
notmine	LD R7, temp_S7
	RET				; return back to checking

reveal
	STR R2, R5, #0			; store mine touching value at location
	LD R7, EM_S7
	RET	

prompt		.FILL x3004
temp_S7		.BLKW 	1
INVOUT		.STRINGZ 	"Incorrect Address"
KNOWNOUT	.STRINGZ 	"Already Known"
MINEHIT		.BLKW	1
MATRIX_SIZE	.FILL	#-63	
MATRIX_BOUND1	.FILL	x-4000
MATRIX_BOUND2	.FILL	x-4007
MATRIX_BOUND3	.FILL	x-4038
MATRIX_BOUND4	.FILL	x-403F

;_______________________________________________________________

NEG_ASCII_0	.FILL	x-30
MATRIX_START	.FILL	x4000
MATRIX_END	.FILL	x-4040

.END
