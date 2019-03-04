*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program
     MOVE.L #$A2C2B327, D0  ;Loading address and testing 1a
     ASL.B #2, D0
     
     MOVE.L #$A2C2B327, D0 ;Loading address and testing 1b
     ASR.L #7,D0
     
     MOVE.L #$A2C2B327, D0 ;Loading address and testing 1c
     LSL.B #3,D0
     
     MOVE.L #$A2C2B327, D0 ;Loading address and testing 1d
     ROL.W #1,D0
     
     MOVE.L #$A2C2B327, D0 ;Loading address and testing 1e
     ROR.L #5,D0 ; This seems to move the entire grouped 5 bits as a rotation
     
* Put program code here

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~15~
*~Tab type~1~
*~Tab size~4~
