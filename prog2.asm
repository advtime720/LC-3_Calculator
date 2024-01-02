; After reading a character through the terminal, it is instantly echoed to the screen, then the program checks the character in the following order: 
; '=' --> 'EMPTY SPACE' --> '0'~'9' --> '+' --> '-' --> '*' --> '/' --> '^' --> Invalid input. 
; Once the program recognizes a valid operator, it checks to see if the stack has at least two items in it. If it does, it will pop 
; the top two values in the stack. The first pop goes into R3, and the second pop goes into R4. Once R3, R4 are loaded, they are used
; as the inputs for each operator subroutine (ADD, MIN, ...), and the output goes into R0. This is then pushed back into the stack. 
; When the program recognizes the equal sign '=', it will compare the stack_top with stack_start to see if the stack contains exactly 1 item. 
; If this is true, it will pop this 1 item and print it to the console as a hexadecimal, and store the hex value into R5. Otherwise, the program
; will print "Invalid Expression" to the console.


.ORIG x3000

	
READ    GETC ; Read input into R0 
        OUT ; Echo to console 
        LD R1, EQ ; Load '=' into R1
        JSR INPUT_CHECKER ; 
        BRz STCH ; If yes, go to STCH

EQ      .FILL x003D ; ASCII '='

	;;; Checking if input is an empty space. If it is, ignore and go to READ. 
C_SP    LD R1, SP ; Load ' ' into R1
        JSR INPUT_CHECKER ; 
        BRz READ ; If yes, go to READ
        
	;;; Checking if input is between 0 ~ 9 
C_NO    LD R1, NINE ; Load '9' into R1 R0 = 0
        JSR INPUT_CHECKER ; 
        BRp OP_PLUS ; Input is greater than '9'

        LD R1, ZERO ; Load '0' into R1
        JSR INPUT_CHECKER ; 
        BRn OP_PLUS ; Input is less than '0'
        ; Subtract '0' already happened in INPUT_CHECKER subroutine
        ADD R0, R2, #0 ; Move R2 value into R0
        JSR PUSH
        BR READ ; Read next input

SP          .FILL x0020 ; ASCII ' '
ZERO        .FILL x0030 ; ASCII '0'
NINE        .FILL x0039 ; ASCII '9'

        ;;; Checking if input is an operator 

OP_PLUS ; Is it (+) ? 
        LD R1, C_PLUS ; 
        JSR INPUT_CHECKER ; 
        BRnp OP_MINUS ; If no, go to OP_MINUS

        ;;; Checking if stack has at least 2 items 
        ST R2, OP_CHECKR2 ; 
        ST R6, OP_CHECKR6 ; 

        LD R2, STACK_TOP ; 
        LD R6, STACK_START ; 
        ADD R6, R6, #-2 ; 
        NOT R6, R6 ; 
        ADD R6, R6, #1 ; 
        ADD R6, R6, R2 ;  
        BRp INVAL ; There are less than 2 items in the stack. If not, Invalid input subroutine. 
        LD R2, OP_CHECKR2 ; 
        LD R6, OP_CHECKR6 ; 

	;;; There are at least 2 items in the stack. 
	;;; POP top two values in stack. 
        JSR POP ; R4 has updated STACK_TOP address 
        AND R3, R3, #0 ; 
        ADD R3, R3, R0 ; Load contents of stack top into R3 
        JSR POP ; 
        AND R4, R4, #0 ; 
        ADD R4, R4, R0 ; R3 and R4 are loaded with inputs and ready to perform operation 
        
        JSR PLUS 
        JSR PUSH 
        BR READ ; 

OP_MINUS ; Is it (-) ? 
        LD R1, C_MINUS ; 
        JSR INPUT_CHECKER ; 
        BRnp OP_MULT ; If not, go to OP_MULT

        ST R2, OP_CHECKR2 ; 
        ST R6, OP_CHECKR6 ; 

        LD R2, STACK_TOP ; 
        LD R6, STACK_START ; 
        ADD R6, R6, #-2 ; 
        NOT R6, R6 ; 
        ADD R6, R6, #1 ; 
        ADD R6, R6, R2 ;  
        BRp INVAL ; 
        LD R2, OP_CHECKR2 ; 
        LD R6, OP_CHECKR6 ; 
;;; There are at least 2 items in the stack 

        JSR POP ; R4 has updated STACK_TOP address 
        AND R3, R3, #0 ; 
        ADD R3, R3, R0 ; Load contents of stack top into R3 
        JSR POP ; 
        AND R4, R4, #0 ; 
        ADD R4, R4, R0 ; R3 and R4 are loaded with inputs and ready to perform operation 
        
        JSR MIN ; 
        JSR PUSH 
        BR READ ; 
        
OP_MULT ; Is it (*) ? 
        LD R1, C_MULT ; 
        JSR INPUT_CHECKER ; 
        BRnp OP_DIV ; If not, go to OP_DIV
        
        ST R2, OP_CHECKR2 ; 
        ST R6, OP_CHECKR6 ; 

        LD R2, STACK_TOP ; 
        LD R6, STACK_START ; 
        ADD R6, R6, #-2 ; 
        NOT R6, R6 ; 
        ADD R6, R6, #1 ; 
        ADD R6, R6, R2 ;  
        BRp INVAL ; 
        LD R2, OP_CHECKR2 ; 
        LD R6, OP_CHECKR6 ; 
;;; There are at least 2 items in the stack 

        JSR POP ; R4 has updated STACK_TOP address 
        AND R3, R3, #0 ; 
        ADD R3, R3, R0 ; Load contents of stack top into R3 
        JSR POP ; 
        AND R4, R4, #0 ; 
        ADD R4, R4, R0 ; R3 and R4 are loaded with inputs and ready to perform operation 
        
        JSR MUL 
        JSR PUSH 
        BR READ ; 

OP_DIV ; Is it (/) ? 
        LD R1, C_DIV ; 
        JSR INPUT_CHECKER ; 
        BRnp OP_EXP ; If not, go to OP_EXP

        ST R2, OP_CHECKR2 ; 
        ST R6, OP_CHECKR6 ; 
        
        LD R2, STACK_TOP ; 
        LD R6, STACK_START ; 
        ADD R6, R6, #-2 ; 
        NOT R6, R6 ; 
        ADD R6, R6, #1 ; 
        ADD R6, R6, R2 ;  
        BRp INVAL ; 
        LD R2, OP_CHECKR2 ; 
        LD R6, OP_CHECKR6 ; 
;;; There are at least 2 items in the stack 

        JSR POP ; R4 has updated STACK_TOP address 
        AND R3, R3, #0 ; 
        ADD R3, R3, R0 ; Load contents of stack top into R3 
        JSR POP ; 
        AND R4, R4, #0 ; 
        ADD R4, R4, R0 ; R3 and R4 are loaded with inputs and ready to perform operation 
        
        JSR DIV
        JSR PUSH 
        BR READ ; 

OP_EXP ; Is it (^) ? 
        LD R1, C_EXP ; 
        JSR INPUT_CHECKER ; 
        BRnp INVAL ; If not, Invalid input subroutine 

        ST R2, OP_CHECKR2 ; 
        ST R6, OP_CHECKR6 ; 
        
        LD R2, STACK_TOP ; 
        LD R6, STACK_START ; 
        ADD R6, R6, #-2 ; 
        NOT R6, R6 ; 
        ADD R6, R6, #1 ; 
        ADD R6, R6, R2 ;  
        BRp INVAL ; 
        LD R2, OP_CHECKR2 ; 
        LD R6, OP_CHECKR6 ; 
;;; There are at least 2 items in the stack 

        JSR POP ; R4 has updated STACK_TOP address 
        AND R3, R3, #0 ; 
        ADD R3, R3, R0 ; Load contents of stack top into R3 
        JSR POP ; 
        AND R4, R4, #0 ; 
        ADD R4, R4, R0 ; R3 and R4 are loaded with inputs and ready to perform operation 
        
        JSR EXP
        JSR PUSH 
        BR READ ; 

INPUT_CHECKER ; Check if R0 holds the same value loaded into R1 
	;;; R1 is loaded before calling INPUT_CHECKER
        ST R1, C_SAVER1 ;
        ST R2, C_SAVER2 ;
        NOT R1, R1 ;
        ADD R1, R1, #1 ;
        ADD R2, R1, R0 ; 
        RET

STCH ; Check if there is exactly 1 item in the stack 

        ST R2, OP_CHECKR2 ; 
        ST R6, OP_CHECKR6 ; 

        LD R2, STACK_TOP ; 
        LD R6, STACK_START ; 
        ADD R6, R6, #-1 ; 
        NOT R6, R6 ; 
        ADD R6, R6, #1 ; 
        ADD R6, R6, R2 ;  
        BRnp INVAL ; If not, Invalid input subroutine
        LD R2, OP_CHECKR2 ; 
        LD R6, OP_CHECKR6 ; 
        JSR POP ; R0 holds result in hex
        ST R0, F_RESULT ; Store the result in F_RESULT. 

;;; Printing the result in hexadecimal. 

; R3: value to print in hexadecimal
PRINT_HEX

    AND R3, R3, #0 ; Clear R3
    ADD R3, R3, R0 ; R3 holds result in hex 
    AND R5, R5, #0 ; Clear digit counter

L0  ADD R0, R5, #-4 ; Checking if less than 4 digits have been printed
    BRn L1 ; If yes, then go to L1
    BR EVALUATE ; If no, the hex value is done printing. Go to EVALUATE. 

L1  AND R4, R4, #0 ; Initialize bit counter to 0
    AND R6, R6, #0 ; Initialize Digit to 0

L2  ADD R0, R4, #-4 ; Subtract 4 from bit counter (and set cc). I don't want to change the R4 value so the result is thrown into R0
    BRn M1 ; If result < 0 go to M1
    
M2  ADD R0, R6, #-9 ; Is Digit <= 9?
    BRnz M5 ; If yes, go to M5. 
    
    LD R1, AM ; Put ('A'-10) into R1
    ADD R6, R6, R1 ; Add ('A'-10) then go to M6
    BR  M6

M5  LD R1, ZR ; Put ASCII '0' into R1
    ADD R6, R6, R1 ; Add ASCII '0' to Digit then
    BR M6 ; go to M6


M1  ADD R6, R6, R6 ; Shift Digit left 
    ADD R3, R3, #0 ; Check if R3 is negative or positive 
    BRn M3 ; If R3 is negative, go to M3 

    ADD R6, R6, #0 ; Add 0 to digit
    BR M4

M3  ADD R6, R6, #1 ; Add 1 to digit
    BR M4

M4  ADD R3, R3, R3 ; Shift R3 left
    ADD R4, R4, #1 ; Increment bit counter
    BR L2

M6  AND R0, R0, #0 ; Initialize R0 to remove previous throwaway values 
    ADD R0, R0, R6 ; Put Digit into R0 
    OUT ; OUT trap ; Writes R0[7:0] to the console 
    ADD R5, R5, #1 ; Increment digit counter
    BR L0 ; Back to L0


ZR  .FILL x0030 ; = Decimal 48 = ASCII '0'
AM  .FILL x0037 ; = Decimal 55 = ASCII 'A' - 10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R0 - character input from keyboard
;R6 - current numerical output
;
;
EVALUATE
        LD R5, F_RESULT ; Put the result hexadecimal value into R5. 
        HALT ; End the program. 

STACK_END	.FILL x3FF0	;
STACK_START	.FILL x4000	;
STACK_TOP	.FILL x4000	;
C_PLUS      .FILL x002B ; ASCII '+'
C_MINUS     .FILL x002D ; ASCII '-'
C_MULT      .FILL x002A ; ASCII '*'
C_DIV       .FILL x002F ; ASCII '/'
C_EXP       .FILL x005E ; ASCII '^'
OP_CHECKR2  .BLKW #1    ;
OP_CHECKR6  .BLKW #1    ;
POP_SaveR3	.BLKW #1	;
POP_SaveR4	.BLKW #1	;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;R0 - character input from keyboard
;R6 - current numerical output
;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; These are the operator subroutines
;input R3, R4
;out R0
PLUS	
	ADD R0, R3, R4 ; 
        RET ; 
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;input R3, R4
;out R0
MIN	
	NOT R3, R3 ; 
        ADD R3, R3, #1 ; 
        ADD R0, R3, R4 ; 
        RET ; 
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Format: (R4)(R3)* because the first pop goes into R3 and the second goes into R4. 
;input R3, R4
;out R0
MUL	
	AND R0, R0, #0 ; Clear R0. It will contain the final result. 
MUL_L   ADD R0, R0, R3 ; Add R3 into R0. 
	ADD R4, R4, #0 ; Set cc for R4. 
	BRn N_MUL ; If R4 < 0, go to N_MUL. 
	BRz Z_MUL ; If R4 = 0, go to Z_MUL. 
	BR P_MUL ; If R4 > 0, go to P_MUL. 
N_MUL	ADD R4, R4, #1 ; Increment R4 by 1. 
	BRn MUL_L ; If R4 < 0, go back to MUL_L. 
	NOT R0, R0 ; Once the calculation is done,
	ADD R0, R0, #1 ; negate the result. 
	BR E_MUL ; Operation is finished. 
Z_MUL	AND R0, R0, #0 ; The result is zero. 
	BR E_MUL ; Operation is finished. 
P_MUL   ADD R4, R4, #-1 ; Decrement R4 by 1. 
        BRp MUL_L ; If R4 > 0, go back to MUL_L. 
	BR E_MUL ; Operation is finished. 
E_MUL
        RET ; Return. 
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Format: (R4)(R3)/ because the first pop goes into R3 and the second goes into R4. 
;input R3, R4
;out R0
DIV	
	AND R0, R0, #0 ; Clear R0. It will contain the final result. 
	ADD R3, R3, #0 ; set cc for R3 
	BRn N_DIV ; If divisor < 0 go to N_DIV 
	BRp P_DIV ; If divisor > 0 go to P_DIV 
	BRz INVAL ; If divisor = 0 go to invalid input subroutine. 

N_DIV	ADD R4, R4, #0 ; Set cc for R4. 
	BRn NEGATE ; If dividend is negative, go to NEGATE. 
	BRp PASS ; If dividend is positive go to PASS. 
NEGATE	NOT R4, R4 ; This part is for when both the dividend and divisor are negative. 
	ADD R4, R4, #1 ; Negate R4. 
PLS	ADD R4, R4, R3 ; R3 - R4. 
	BRn DIV_END ; End operation if negative. 
	ADD R0, R0, #1 ; Increment R0 by 1. 
	BRp PLS ; Loop back to PLS

PASS	ADD R4, R4, R3 ; Ths part is for when the dividend is positive and the divisor is negative. 
	BRn DIV_END ; End operation if negative. 
	ADD R0, R0, #-1 ; Decrement R0 by 1. 
	BRn N_DIV ; Loop back to N_DIV

P_DIV 	ADD R4, R4, #0 ; set cc for R4 
	BRn NEG_DIVIDEND ; If dividend is negative, go to NEG_DIVIDEND. 
	BRp POS_DIVIDEND ; If dividend is positive, go to POS_DIVIDEND. 
NEG_DIVIDEND ; Dividend is negative, and divisor is positive. 
	ADD R4, R4, R3 ; Add R3 to R4
	BRp DIV_END ; If result is positive end operation. 
	ADD R0, R0, #-1 ; Decrement R0 by 1. 
	BR NEG_DIVIDEND ; Loop back to NEG_DIVIDEND. 
POS_DIVIDEND ; Dividend is positive, and divisor is positive. 
	NOT R3, R3 ; 
        ADD R3, R3, #1 ; Negate R3. 
MIN_L	ADD R4, R4, R3 ; 
	BRn DIV_END
	ADD R0, R0, #1 ; 
        BRp MIN_L ; 
DIV_END        
        RET ; 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Format: (R4)(R3)^ because the first pop goes into R3. 
;input R3, R4
;out R0
EXP
	ST R3, EXP_SAVER3 ; R3 = 0
        ST R4, EXP_SAVER4 ; R4 = 2
        ST R7, EXP_SAVER7 ; Save R7 for nested JSR 
	ADD R3, R3, #0 ; Set cc for R3 (exponent)
	BRnp EXP_NZ ; If the exponent is 0, the result is 1. Otherwise, go to EXP_NZ (not zero)
	AND R0, R0, #0 ; 
	ADD R0, R0, #1 ; 
	BR Q_EXP ; 
EXP_NZ  AND R3, R3, #0 ; Clear R3 
	ADD R3, R3, #1 ; Make R3 = 1 
        BR EXP_M ; 
EXP_L   ADD R3, R0, #0 ; Result in R0 has to go into R3 

EXP_M   JSR MUL ; Nested multiplication subroutine which also uses R3, R4 as inputs, so when the PC returns, the original values will be loaded back. 
	LD R4, EXP_SAVER4 ; Load original R4 input value back into R4 
        LD R3, EXP_SAVER3 ; Load the exponent into R3 
        ADD R3, R3, #-1 ; Decrement it by 1 
        ST R3, EXP_SAVER3 ; Store it back to EXP_SAVER3
        
        BRp EXP_L ; Loop back to EXP_L if R3 is positive 

        LD R3, EXP_SAVER3 ; 
        LD R4, EXP_SAVER4 ; 
        LD R7, EXP_SAVER7 ; Callee save. 
Q_EXP   RET ; 

INVAL ; Print "Invalid Expression" to the console. 
	LEA R0, ERR_M ; Load R0 with the address of ERR_M. 
	PUTS ; Write a string of ASCII characters to the console, starting with the address in R0. 
	
        HALT ; End the program. 

ERR_M	.STRINGZ "Invalid Expression" ; Error Message 

;IN:R0, OUT:R5 (0-success, 1-fail/overflow)
;R3: STACK_END R4: STACK_TOP
;
PUSH	
	ST R3, PUSH_SaveR3	;save R3
	ST R4, PUSH_SaveR4	;save R4
	AND R5, R5, #0		;
	LD R3, STACK_END	;
	LD R4, STACk_TOP	;
	ADD R3, R3, #-1		;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz OVERFLOW		;stack is full
	STR R0, R4, #0		;no overflow, store value in the stack
	ADD R4, R4, #-1		;move top of the stack
	ST R4, STACK_TOP	;store top of stack pointer
	BRnzp DONE_PUSH		;
OVERFLOW
	ADD R5, R5, #1		;
DONE_PUSH
	LD R3, PUSH_SaveR3	;
	LD R4, PUSH_SaveR4	;
	RET


PUSH_SaveR3	.BLKW #1	;
PUSH_SaveR4	.BLKW #1	;


;OUT: R0, OUT R5 (0-success, 1-fail/underflow)
;R3 STACK_START R4 STACK_TOP
;
POP	
	ST R3, POP_SaveR3	;save R3
	ST R4, POP_SaveR4	;save R3
	AND R5, R5, #0		;clear R5
	LD R3, STACK_START	;
	LD R4, STACK_TOP	;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz UNDERFLOW		;
	ADD R4, R4, #1		;
	LDR R0, R4, #0		;
	ST R4, STACK_TOP	;
	BRnzp DONE_POP		;
UNDERFLOW
	ADD R5, R5, #1		;
DONE_POP
	LD R3, POP_SaveR3	;
	LD R4, POP_SaveR4	;
	RET

C_SAVER1    .BLKW #1 ;
C_SAVER2    .BLKW #1 ;
EXP_SAVER3  .BLKW #1 ; 
EXP_SAVER4  .BLKW #1 ; 
EXP_SAVER7  .BLKW #1 ; 


PLUS_SAVER3 .BLKW #1 ; 
PLUS_SAVER4 .BLKW #1 ; 

F_RESULT    .BLKW #1 ; Final Result 

.END
