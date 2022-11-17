*-----------------------------------------------------------
* Title      : Supervisor Bit Flip Exception
* Written by : Jonathan Kocevar
* Date       : n/a
* Description: Uses TRAP #0 to flip the supervisor bit
*-----------------------------------------------------------

* S bitflip exception function directive setup
TRAPZERO    EQU     $80          ; trap 0 addr (Vector 32 + 0 = 0x80)
            ORG     TRAPZERO     ; at 0x80 
            DC.L    FLIPSSBIT    ; assign value of exception addr

* S bitflip exception function
FLIPSSBIT   ORG     $400        ; Load exception function at 0x0400
            EORI    #$2000,(A7) ; Get SR on stack, exclusive or bits to flip S bit
            RTE                 ; Return from stack
            
* simple running program (flips bit back and forth)
        ORG     $8000
main    TRAP    #0
        TRAP    #0
        TRAP    #0
        TRAP    #0
        
        SIMHALT

        END     main


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
