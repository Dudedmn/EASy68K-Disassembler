    ORG    $1000
START:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* EXECUTION **************************************
    MOVEA.W #%0001, A6
    MOVE.B  #%000, D5
    MOVE.B  #%011, D4

    JSR     CHECK_XXXX
    SIMHALT
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* CHECK_INSTRUCTION_BITS FUNCTIONS ***************
CHECK_XXXX:
    CMPA    #$8, A6
    BLT     CHECK_0XXX
    JMP     CHECK_1XXX
    
CHECK_0XXX:
    CMPA    #$4, A6
    BLT     CHECK_00XX
    JMP     CHECK_01XX

CHECK_1XXX:
    RTS

CHECK_00XX:
    CMPA    #$1, A6
    BLT     CHECK_0000
    CMPA    #$2, A6
    BGT     CHECK_0011
    
    * IT IS 00XX(=MOVE(A))
    JMP     PRINT_00XX

CHECK_01XX:
    RTS
    
CHECK_0000:
    RTS

CHECK_0011:
    RTS
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* PRINT_00XX FUNCTION ****************************
PRINT_00XX:
        * Print SRC Mod
        CMPI    #DataReg, D5
        BEQ     PRINT_SRC_D
        CMPI    #AddrReg, D5
        BEQ     PRINT_SRC_A

        * Print SRC Reg
SRC_R   MOVE.L  D4, D1
        JSR     PRINT_NUM
        
        * Print Comma and space
        JSR     PRINT_COMMA_SPACE
        
        * Print DST Mod
        CMPI    #DataReg, D6
        BEQ     PRINT_DST_D
        CMPI    #AddrReg, D6
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* PRINT_THIS FUNCTIONS ***************************
PRINT_COMMA_SPACE:
    LEA     COMMA_SPACE, A1
    JSR     PRINT_THIS_SHIT
    RTS
    
PRINT_SRC_D:
    LEA     DATA, A1
    JSR     PRINT_THIS_SHIT
    JMP     SRC_R
    
PRINT_SRC_A:
    LEA     ADDRESS, A1
    JSR     PRINT_THIS_SHIT

PRINT_DST_D:
    LEA     DATA, A1
    JSR     PRINT_THIS_SHIT
    JMP     DST_R
    
PRINT_DST_A:
    LEA     ADDRESS, A1
    JSR     PRINT_THIS_SHIT

PRINT_IS_00XX:
    LEA     IS_00XX_MSG, A1
    JMP     PRINT_THIS_SHIT
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* OTHER USEFUL FUNCTIONS**************************
PRINT_THIS_SHIT:
    MOVE.B  #14, D0
    TRAP    #15
    RTS

PRINT_NUM:
    MOVE.B  #3, D0
    TRAP    #15
    RTS

RTS:
    RTS
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* MESSAGE VARIABLES ******************************
IS_00XX_MSG     DC.B    'IS 00XX',0

ADDRESS         DC.B    'A',0
DATA            DC.B    'D',0

COMMA_SPACE     DC.B    ', ',0
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* M,Xn CONSTANTS *********************************
DataReg         EQU     %000 *M
AddrReg         EQU     %001 *M
Addr            EQU     %010 *M
AddrPostI       EQU     %011 *M
AddrPreD        EQU     %100 *M
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    END    START
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
