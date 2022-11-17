*-----------------------------------------------------------
* Title      : Recursive Word Factorial
* Written by : Jonathan Kocevar
* Date       : n/a
* Description: Computes n! recursively up to integer 10, 
*              because of word restrictions
*-----------------------------------------------------------

nOffset     EQU      8              ;displacement from frame pointer
factOffset  EQU     -2              ;displacement from frame pointer

* Prologue: Prompt user to enter n, then compute n! 
        ORG     $8000
main    LEA     MSG,A1              ;initalize pointer to string
        MOVE    #14,D0              ;print string is task 14
        TRAP    #15                 ;system call
        MOVE    #4,D0               ;read integer from keyboard is task 4
        TRAP    #15                 ;get value of n 

call_factorial        
        MOVE.W  D1,-(A7)            ;push n onto stack         
        BSR     factorial           ;call subroutine
        LEA     2(A7),A7            ;remove parameter from stack

        LEA     MSG2,A1             ;initilaize pointer to string
        MOVE    #14,D0              ;print string is task 14
        TRAP    #15                 ;system call
        MOVE    #3,D0               ;display integer is task 3
        TRAP    #15                 ;system call
        
        SIMHALT

* Factorial (n)
*  - parameter n is at 8(A6)
*  - local variable fact is at -2(A6)
*  - value of factorial(n) returned in D1

factorial    
        LINK    A6,#-2              ;allocate storage fact
        MOVE.L  D0,-(A7)            ;save working register
        
*       if (n == 1)
        CMPI    #0,nOffset(A6)      ;is n=0?
        BNE     L1                  ;no
        
*       return 1
        MOVE    #1,D1               ;factorial(0) = 1
        BRA     L2                  ;return

*       fact = n x factorial(n-1)
L1      MOVE.W  nOffset(A6),D0      ;get n
        MOVE.W  D0,factOffset(A6)   ;fact = n
        SUB.W   #1,D0               ;compute n-1
        MOVE.W  D0,-(A7)            ;push n-1
        BSR     factorial           ;calculate factorial(n-1)
        MULU    factOffset(A6),D1   ;compute n x factorial(n-1)
        LEA     2(A7),A7            ;remove n-1
        
L2      MOVE.L  (A7)+,D0            ;restore working register               
        UNLK    A6                  ;deallocate stack frame
        RTS                         ;return value of factorial(n) in D1

        ORG $9000
MSG     DC.B 'Enter n: ',0
MSG2    DC.B 'Factorial: ',0

        END     main

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
