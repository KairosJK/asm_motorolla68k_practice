*-----------------------------------------------------------
* Title      : MINMAXAVERAGE_OFLIST
* Written by : Jonathan Kocevar
* Date       : 02/11/22
* Description: Reads a list of up to ten values, and gets the min, max and average
*-----------------------------------------------------------
            ORG     $1000
START:      PEA     LIST            ;Push list pointer onto stack
            BSR     GET_DATA        ;Call GET_DATA subroutine
            LEA     4(A7),A7        ;Reset stack pointer
            
            LEA     LISTLEN,A1      ;Load LISTLEN into reg A1
            MOVE.L  D0,(A1)         ;Assign LISTLEN with length from GET_DATA subroutine return
            
            MOVE.L  (A1),-(A7)      ;Push LISTLEN onto stack
            PEA     LIST            ;Push LIST onto stack
            PEA     STRUCT          ;Push STRUCT onto stack
            BSR     STATISTICS      ;Call STATISTICS subroutine
            LEA     12(A7),A7       ;Reset Stack pointer
            
            LEA     STRUCT,A1
            MOVE.L  (A1)+,-(A7)     ;Push max onto stack
            MOVE.L  (A1)+,-(A7)     ;Push min onto stack
            MOVE.W  (A1)+,-(A7)     ;Push quotient onto stack
            MOVE.W  (A1)+,-(A7)     ;Push remainder onto stack
            MOVE.L  LISTLEN, -(A7)
            BSR     DISPLAY
            LEA     16(A7),A7       ;Reset Stack pointer
            
            SIMHALT
    
    
****  Subroutine: INT GET_DATA(*LIST)   ****
*          ARG1: *LIST at 28(A7)           *
*   Returns length in data register D0     *
********************************************
    
GET_DATA    MOVEM.L D1-D4/A1/A2,-(A7)  ;Save working registers
            MOVEA.L 28(A7),A2          ;Save List to A2

            MOVE.L  #14,D0          ;Set task number for TRAP (Print to screen)
            LEA     MSG1,A1         ;Load message for TRAP
            TRAP    #15             ;Sys call
            BRA     LOOP            ;Jump into loop
        
LOOP_ERR    MOVE.L  #14,D0          ;Set task number for TRAP (Prints input err)
            LEA     ERRMSG1,A1       ;Load message for TRAP
            TRAP    #15             ;Sys call
        
LOOP        MOVE.L  #4,D0           ;Set task number for TRAP (Gets num input)
            TRAP    #15             ;Sys call
            CMPI    #10,D1          ;Compare if unsigned greater than 10
            BHI     LOOP_ERR        ;If true, print error and ask for new value
            CMPI    #0,D1           ;Check if number is equal to zero (Last case does not cover this)
            BEQ     LOOP_ERR        ;If true, print error and ask for new value
        
            MOVE.L  D1,D3           ;Set length to D3 register

LOOP2       SUB     #1,D3           ;Sub 1 from the count
            ADD     #1,D4           ;Add one to message
            MOVE.L  #14,D0          ;Set task number for TRAP (Print to screen)
            LEA     MSG2_1,A1       ;Load message for TRAP
            TRAP    #15             ;Sys call
            MOVE.L  D4,D1           ;Load message for TRAP
            MOVE.L  #3,D0           ;Set task number for TRAP (Print to screen)
            TRAP    #15             ;Sys call
            MOVE.L  #14,D0          ;Set task number for TRAP (Print to screen)
            LEA     MSG2_2,A1       ;Load message for TRAP
            TRAP    #15             ;Sys call
            MOVE.L  #4,D0           ;Set task number for TRAP (Gets num input)
            TRAP    #15             ;Sys call
            MOVE.L  D1,(A2)+        ;Add to list
            CMPI    #0,D3           ;Compare count to zero
            BNE     LOOP2           ;If they are not equal, loop again
            
            MOVE.L  D4,D0               ;Save length to return register
            MOVEM.L (A7)+,D1-D4/A1/A2   ;Restore working registers
            RTS                         ;Return
        
****  Subroutine: STATISTICS(int NUMBER, *LIST, *STRUCT)     ****
*                  ARG1: NUMBER at  32(A7)                      *
*                  ARG2: *LIST at   28(A7)                      *
*                  ARG3: *STRUCT at 24(A7)                      *
*            Returns length in data register D0                 *
*****************************************************************

STATISTICS  MOVEM.L D0-D3/A1/A2,-(A7) ;Save working registers
            MOVE.L  36(A7),D0       ;Get Length of array
            MOVEA.L 32(A7),A1       ;Get LIST pointer
            MOVEA.L 28(A7),A2       ;Get STRUCT pointer
            
            MOVE.L  (A1),D2         ;Gets first index from LIST
                  
LOOP3       CMP.L   D0,D1           ;Check loop condition i =/= length
            BEQ     EXITLOOP3       ;Exit loop if true
            MOVE.L  (A1)+,D3        ;Get next value in array
            CMP.L   D3,D2           ;Compare for larger
            BGE     SKIP1           ;If current largest is larger, skip reassignment
            MOVE.L  D3,D2           ;Gets new max
SKIP1       ADD     #1,D1
            BRA     LOOP3
            
EXITLOOP3   MOVE.L  D2,(A2)+        ;Adds max to struct

            * Reseting variables for minimum testing
            MOVEA.L 32(A7),A1       ;Get LIST pointer
            CLR.L   D1              ;Clear all three registers
            CLR.L   D2
            CLR.L   D3
            
            MOVE.L  (A1),D2         ;Gets first index from LIST

LOOP4       CMP.L   D0,D1           ;Check loop condition i =/= length
            BEQ     EXITLOOP4       ;Exit loop if true
            MOVE.L  (A1)+,D3        ;Get next value in array
            CMP.L   D3,D2           ;Compare for smaller
            BLE     SKIP2           ;If current smallest is smaller, skip reassignment
            MOVE.L  D3,D2           ;Gets new min
SKIP2       ADD     #1,D1           
            BRA     LOOP4
            
EXITLOOP4   MOVE.L  D2,(A2)+        ;Add min to struct

            *Reseting variables for average calc
            MOVEA.L 32(A7),A1       ;Get LIST pointer
            CLR.L   D1              ;Clear all three registers
            CLR.L   D2
            CLR.L   D3

LOOP5       CMP.L   D0,D1           ;Check loop condition i =/= length
            BEQ     EXITLOOP5       ;Exit loop if true
            ADD.L   (A1)+,D2        ;Add current index and then increment
            ADD     #1,D1           ;Add 1 to i
            BRA     LOOP5
            
EXITLOOP5   DIVS    D0,D2           ;Divide to get avg
            MOVE.W  D2,(A2)+        ;Add quotient to struct
            SWAP    D2              ;Move remainder to least significant word
            MOVE.W  D2,(A2)         ;Add remainder to struct

            MOVEM.L (A7)+,D0-D3/A1/A2   ;Restore working registers
            RTS    
            
****  Subroutine: DISPLAY(int MAX, int MIN, int QUOTIENT, int REMAINDER) ********
*                        ARG1: MAX at       28(A7)                              *
*                        ARG2: MIN at       24(A7)                              *
*                        ARG3: QUOTIENT at  22(A7)                              *
*                        ARG3: REMAINDER at 20(A7)                              *
*                        ARG3: LENGTH at    16(A7)                              *
*********************************************************************************

DISPLAY     MOVEM.L D0/D1/A1,-(A7) ;Save working registers
            
            *Print max and min
            MOVE.L  #14,D0
            LEA     DISPMSG1,A1 ;Get message
            TRAP    #15         ;Print
            
            MOVE.L  #3,D0
            MOVE.L  24(A7),D1   ;Get min
            TRAP    #15         ;Print
            
            MOVE.L  #6,D0       ;Display single char
            MOVE.L  #13,D1      ;Select carriage return ('CR')
            TRAP    #15         ;Print
            
            MOVE.L  #6,D0       ;Display single char
            MOVE.L  #10,D1      ;Select return (\n)
            TRAP    #15         ;Print
            
            MOVE.L  #14,D0
            LEA     DISPMSG2,A1 ;Get message
            TRAP    #15         ;Print
            
            MOVE.L  #3,D0
            MOVE.L  28(A7),D1   ;Get max
            TRAP    #15         ;Print
            
            MOVE.L  #6,D0       ;Display single char
            MOVE.L  #13,D1      ;Select carriage return ('CR')
            TRAP    #15         ;Print
            
            MOVE.L  #6,D0       ;Display single char
            MOVE.L  #10,D1      ;Select return (\n)
            TRAP    #15         ;Print
         
            *Print average
            MOVE.L  #14,D0
            LEA     DISPMSG3,A1 ;Get message
            TRAP    #15         ;Print
            
            MOVE.L  #3,D0
            MOVE.W  22(A7),D1   ;Get quotient
            EXT.L   D1
            TRAP    #15         ;Print
            
            MOVE.L  #6,D0       ;Display single char
            MOVE.L  #32,D1      ;Select space (' ')
            TRAP    #15         ;Print
            
            MOVE.L  #3,D0       
            MOVE.W  20(A7),D1   ;Get quotient
            EXT.L   D1
            TRAP    #15         ;Print
            
            MOVE.L  #6,D0       ;Display single char
            MOVE.L  #47,D1      ;Select division symbol ('/')
            TRAP    #15         ;Print
            
            MOVE.L  #3,D0       
            MOVE.L  16(A7),D1   ;Get divisor
            TRAP    #15         ;Print
         
            MOVEM.L (A7)+,D0/D1/A1   ;Restore working registers
            RTS
            

* Put variables and constants here
            ORG     $9000

LIST        DS.L    10
LISTLEN     DS.L    1

STRUCT      DS.L    2
            DS.W    2

MSG1        DC.B    'Enter the number of values in the list (1-10): ',0
ERRMSG1     DC.B    'Error: input must be within range 1-10, try again: ',0

DISPMSG1    DC.B    'Minimum = ',0
DISPMSG2    DC.B    'Maximum = ',0
DISPMSG3    DC.B    'Average = ',0

MSG2_1      DC.B    'Enter value ',0
MSG2_2      DC.B    ': ',0

        
        END    START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
