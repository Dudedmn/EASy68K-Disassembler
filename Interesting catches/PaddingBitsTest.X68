*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    *MOVE.W #$0000AAAA, D0
    ;MOVE.B D1,D5
    MOVE.l $8000, D0 ; Why is this code 2039, instead of 2039 like the rest?
    MOVE.L #8000, D1 ; Listing file pads both of the modes with extra 0's
    MOVE.L $8, D0
    MOVE.L #8, D1
    
    MOVE.B $1234,D0
    MOVE.W $1234,D0
    MOVE.L $1234,D0
    
    MOVE.B $1000,D0
    MOVE.W $1000,D0
    MOVE.L $1000,D0
    
    MOVE.B $0001,D0
    MOVE.W $0001,D0
    MOVE.L $0001,D0
    
    MOVE.B $1000,D0
    MOVE.W #$1000,D0
    MOVE.L $1000,D0
    
    MOVE.B $0001,D0
    MOVE.W #$0001,D0
    MOVE.L $0001,D0
    
    ;0011 000 000 111 000 -> $3038 
    ;0010 000 000 111 001 -> $2039
    ;0010 000 000 111 000 -> $2038
    
    
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~15~
*~Tab type~1~
*~Tab size~4~
