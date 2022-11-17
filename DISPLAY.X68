*-----------------------------------------------------------
* Title      : Recursive Display
* Written by : Jonathan Kocevar
* Date       : n/a
* Description: Displays digits of sequentially
*-----------------------------------------------------------


        ORG     $8000
        
        * Load variable in stack
main    MOVE.W  n,-(A7)
        *Call function DISPLAY()
        BSR     DISPLAY
        LEA     2(A7),A7    ; Remove n from stack upon exit from recursive call

        SIMHALT
        
*
* DISPLAY(int n)
*  - parameter n is at 8(A6)
*  - Local variable quotient is at -2(A6)
*  - Local variable remainder is at -4(A6)
*

DISPLAY     LINK    A6, #-4        ; Create stack frame for 8 bytes (2 Words)
            MOVEM.L D0/D1,-(A7)    ; Save working registers

            * [Base Case] ---------------------------------------------------------------

            * if (!n)
            CMPI    #0,8(A6)      
            BNE     RECURSE        ; Jump into recursion              
   
            * return
            BRA     EXIT           ; Jumps to exit if (!n == true), or (n == 0)
            
            * [Recursive case] ----------------------------------------------------------
            
            * Clear D0 register from last call and load n
RECURSE     CLR.L   D0
            MOVE.W  8(A6),D0

            * Divide n by ten and push the quotient to the stack frame
            DIVS    #10,D0
            MOVE.W  D0,-2(A6)
            
            * Swap to grab remainder from most significant word, then push to stack frame
            SWAP    D0
            MOVE.W  D0,-4(A6)
            
            * Peek quotient from stack frame and push to user stack, and call DISPLAY() [Recurse]
            MOVE.W  -2(A6),-(A7)
            BSR     DISPLAY
            LEA     2(A7),A7 ; Remove quotient from stack upon exit from recursive call
            
            * Print remainder from stack frame to screen
            CLR.L   D1
            MOVE.W  -4(A6),D1
            MOVE.L  #3,D0
            TRAP    #15

EXIT        * Restore working registers and unlink stack frame, then return
            MOVEM.L (A7)+,D0/D1
            UNLK    A6
            RTS
            
        ORG $9000
        
n       DC.W    11235 ; Specify number here

        END     main

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
