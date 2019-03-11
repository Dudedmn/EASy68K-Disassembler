*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

    ;MOVEA.W $1005, A1
    ;MOVE.W 2(A1),D2 ; EA mode =(d, An, Xn) these are the same
    
    MOVE.B $14, D0 ;I will check the memory address at $14, and move that into D0
    MOVE.B #$14,D1 ;I will move the value $14 into D0
   
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~15~
*~Tab type~1~
*~Tab size~4~
