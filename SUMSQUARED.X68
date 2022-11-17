*-----------------------------------------------------------
* Title      : SUMSSQUARED
* Written by : Jonathan Kocevar
* Date       : n/a
* Description: Computes (a+b)^2 and stores in label c
*-----------------------------------------------------------


        ORG     $8000
main    
        * Load variable in stack
        MOVE.W  a,-(A7)
        MOVE.W  b,-(A7)
        PEA     c
        *Call function SUMSQUARED()
        BSR     SUMSQUARED
        LEA     8(A7),A7

        SIMHALT
        
*
* SUMSQUARED(int a, int b, int *c)
*  - parameter a is at 14(A6)
*  - parameter b is at 12(A6)
*  - parameter c is at 8(A6)
*  - local variable x is at -4(A6)
*  - local variable y is at -8(A6)
*  - local variable z is at -12(A6)
*  - value of SUMSQUARED(n) returned in c by reference

SUMSQUARED  LINK    A6, #-12    ; Create stack frame for 12 bytes
            MOVEM.L D0/A0,-(A7) ; Save working registers
            
            * (a*a)-> x
            CLR.L   D0
            MOVE.W  14(A6),D0
            MULS    D0,D0
            MOVE.L  D0,-4(A6)
            
            * (b*b) -> y
            CLR.L   D0
            MOVE.W  12(A6),D0
            MULS    D0,D0
            MOVE.L  D0,-8(A6)
            
            * (2*a*b) -> z
            CLR.L   D0
            MOVE.W  14(A6),D0
            MULS    12(A6),D0
            MULS    #2,D0
            MOVE.L  D0,-12(A6)
            
            * (x+y+z) -> c*
            CLR.L   D0
            MOVE.L  -4(A6),D0
            ADD.L   -8(A6),D0
            ADD.L   -12(A6),D0
            MOVEA.L 8(A6),A0
            MOVE.L  (A0),D2
            MOVE.L  D0,(A0)
            
            * Restore working registers and unlink stack frame, then return
            MOVEM.L (A7)+,D0/A0
            UNLK    A6
            RTS
            
        ORG $9000
        
a       DC.W    -50
b       DC.W    20
c       DS.L    1

        END     main

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
