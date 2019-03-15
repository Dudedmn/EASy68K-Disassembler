*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here
    NEG $FFEE
    BRA SUBROUTINE_A
    ORG $1010
SUBROUTINE_A:
    BRA SUBROUTINE_B
    ORG $1000
SUBROUTINE_B:
    BRA SUBROUTINE_C
    ORG $1020
SUBROUTINE_C:
    BRA SUBROUTINE_E
    ORG $980
SUBROUTINE_E:
    BRA SUBROUTINE_F
    ORG $1030
SUBROUTINE_F:
    BRA SUBROUTINE_G
    ORG $970
SUBROUTINE_G:
    BRA SUBROUTINE_H
    ORG $1040
SUBROUTINE_H:
    BRA SUBROUTINE_I
    ORG $960
SUBROUTINE_I:
    BRA SUBROUTINE_J
    ORG $1040
SUBROUTINE_J:
    BRA SUBROUTINE_K
    ORG $050
SUBROUTINE_K:
    BRA SUBROUTINE_L
    ORG $5060
SUBROUTINE_L
    BRA SUBROUTINE_D
    ORG $4001
SUBROUTINE_M
    BRA FORCING_60FF_SUBROUTINE
    
    ORG $C002           ;If you change this line to $C003 for the BRA.L jump it will break
FORCING_60FF_SUBROUTINE
    BRA SUBROUTINE_N
    ORG $C001
SUBROUTINE_N:
    BRA SUBROUTINE_O
    ORG $C002
SUBROUTINE_O:
    ORG $C002
    BRA SUBROUTINE_D
SUBROUTINE_D:
    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source




*~Font name~Courier New~
*~Font size~15~
*~Tab type~1~
*~Tab size~4~
