*-----------------------------------------------------------
* Title      : Auto-Vector Interrupt 24 Hour Clock
* Written by : Jonathan Kocevar
* Date       : n/a
* Description: Digital clock which counts time using auto-vectors
*-----------------------------------------------------------

* vars used (in form of registers)
* D6 interrupt counter
* D5 hh
* D4 mm
* D3 ss
* D0-D2 working registers

                ORG     $8000

* level 6 interrupt
isr6            SUBQ    #1,D6           ; sub 1 from counter
                TST.L   D6              ; see if counter has reached zero
                BGT     isr6_skip       ; if so, skip interrupt
                
                ADDQ    #1,D3           ; add 1 to seconds
                BSR     reset_counter   ; reset counter to 60
                
                CMP.L   const_time,D3   ; see if seconds has reached 60
                BNE     isr6_skip       ; if so, skip interrupt
                BSR     overflow_ss     ; branch to subroutine holding second overflow function
                
                CMP.L   const_time,D4   ; see if minutes has reached 60
                BNE     isr6_skip       ; if so, skip interrupt
                BSR     overflow_mm     ; branch to subroutine holding minute overflow function

                CMP.L   const_time_hour,D5  ; see if hours has reached 24
                BNE     isr6_skip           ; if so, skip interrupt
                BSR     overflow_hh         ; branch to subroutine holding hour overflow function

isr6_skip       RTE ; exit interrupt

* level 7 interrupt
isr7            BSR reset_clock     ; call clock reset subroutine for interrupt 7
                BSR reset_counter   ; call counter reset subroutine for interrupt 7
                RTE

* small subroutine that resets counter register to 60
reset_counter   MOVE.L  counter_preset,D6  ; clear counter
                RTS

* small subroutine that clears working "arithmetic" registers for clock
reset_ari_reg   CLR.L   D0
                CLR.L   D1
                CLR.L   D2
                RTS

** small subroutine that accounts for second overflow
overflow_ss     CLR.L   D3      ; clear sec var
                ADDQ    #1,D4   ; add 1 to min
                RTS

* small subroutine that accounts for minute overflow
overflow_mm     CLR.L   D4      ; clear min var
                ADDQ    #1,D5   ; add 1 to hour
                RTS

* small subroutine that accounts for hour overflow
overflow_hh     BSR reset_clock ; reset clock at hour 24
                RTS
                
* small testing subroutine that prints time variable registers to output window
* format: [ss:mm:hh]
print_console   MOVE.L  D3,D1   ; ss
                MOVE.B  #3,D0
                TRAP    #15
                
                MOVE.L  colon,D1    ; :
                MOVE.B  #6,D0
                TRAP    #15
                
                MOVE.L  D4,D1   ; mm
                MOVE.B  #3,D0
                TRAP    #15
                
                MOVE.L  colon,D1    ; :
                MOVE.B  #6,D0
                TRAP    #15
                
                MOVE.L  D5,D1   ; hh
                MOVE.B  #3,D0
                TRAP    #15
                
                MOVE.L  newline,D1  ; \n  
                MOVE.B  #6,D0
                TRAP    #15
                
                MOVE.L  carriage_return,D1 ; \cr
                MOVE.B  #6,D0
                TRAP    #15
                RTS

* small testing subroutine that prints time variable registers to seven segment display
* format: [hh-mm-ss]
* assumes:
*   hh, mm, and ss variables are held in D3, D4, and D5
*   the seven segment display patterns are held in register A2
*   
print_seven_seg BSR reset_ari_reg

                * add seconds to display
                MOVE.L  D3,D1               ; get seconds
                DIVS    #10,D1
                MOVE.B  (A1,D1),12(A2)      ; print most significant digit
                SWAP    D1
                MOVE.B  (A1,D1),14(A2)      ; print leastmost significant digit
                
                MOVE.B  display_line,10(A2) ; add display line symbol
                
                * add minutes to display
                MOVE.L  D4,D1               ; get minutes
                DIVS    #10,D1
                MOVE.B  (A1,D1),6(A2)       ; print most significant digit
                SWAP    D1
                MOVE.B  (A1,D1),8(A2)       ; print leastmost significant digit
                
                MOVE.B  display_line,4(A2)  ; add display line symbol
                
                * add hours to display
                MOVE.L  D5,D1               ; get hours
                DIVS    #10,D1
                MOVE.B  (A1,D1),0(A2)       ; print most significant digit
                SWAP    D1
                MOVE.B  (A1,D1),2(A2)       ; print leastmost significant digit
                
                RTS               

* small subroutine that clears storage registers for clock
reset_clock     CLR.L   D5              ; clear hour var
                CLR.L   D4              ; clear min var
                CLR.L   D3              ; clear second var  
                RTS
            
* main, including small polling program
main            MOVE.L  #isr6,$78           ; load interrupt 6 into vector table
                MOVE.L  #isr7,$7C           ; load interrupt 7 into vector table
                BSR     reset_clock         ; reset clock on setup
                BSR     reset_counter       ; reset counter on setup
                LEA     display_pattern,A1  ; load display patterns for seven segment address into A1
                LEA     seven_seg_addr,A2   ; load address of seven segment display into A2
                
poll            ;BSR     print_console  ; uncomment to view console output
                BSR     print_seven_seg ; prints current time variables to seven segment display
                BRA     poll            ; repoll
                
                SIMHALT
        
colon           DC.L    $3A             ; holds value for colon ascii
newline         DC.L    $A              ; holds value for newline ascii
carriage_return DC.L    $0D             ; holds value for carriage return ascii

const_time      DC.L    60              ; time const
const_time_hour DC.L    24              ; hour const
counter_preset  DC.L    34              ; 60 preset only counted 1:42 in 3:00, this is the new recalculated counter preset (60 * 0.56... = ~34)
                                        ; change at own needs based on own computers performance

seven_seg_addr  EQU     $E00000         ;base address of 7-segment display

* 7-segment display patterns for digits 0-9
display_pattern DC.B    $3F, $06, $5B, $4F, $66, $6D, $7D, $07, $7F, $6F 

* seven segment display pattern for dash
display_line    DC.B    %1000000

                END     main



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
