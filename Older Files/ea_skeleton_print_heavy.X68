    ORG    $1000
START:

**************************************************
*   [NOTICE]
*   Data Register for Mode = D3
*   Data Register for Register# = D2
*   Address Register for Trailing Bits = A3
*   D0 is used for string printing
*   D1 is used for number printing
**************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* EXECUTION **************************************
    * 0011 001 001 111 100
    MOVEA.W #%0001, A6
    MOVE.B  #%001, D7
    MOVE.B  #%001, D6
    MOVE.B  #%111, D5
    MOVE.B  #%100, D4
    MOVEA.W #$000E, A3

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
* PRINT_THIS FUNCTIONS (HIGHEST LEVEL) ***********
PRINT_00XX:
    MOVE.B  D5, D3
    MOVE.B  D4, D2
    
    JSR     PRINT_EA
    JSR     PRINT_COMMA_SPACE
    
    MOVE.B  D6, D3
    MOVE.B  D7, D2
    
    JSR     PRINT_EA
    JSR     PRINT_NEW_LINE
    
    RTS
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* PRINT_THIS FUNCTIONS (HIGH LEVEL) **************
PRINT_EA:
        MOVEA.  #SAVED, A2 * remember to come back!

        CMPI    #%111, D3
        BLT     PRINT_LT_111
        BGE     PRINT_GE_111
    
SAVED   RTS

PRINT_LT_111:
    CMPI    #%000, D3 * e.g. D3
    BEQ     PRINT_DATA_REGISTER
    CMPI    #%001, D3 * e.g. A3
    BEQ     PRINT_ADDR_REGISTER
    CMPI    #%010, D3 * e.g. (A3)
    BEQ     PRINT_ADDRESS
    CMPI    #%011, D3 * e.g. (A3)+
    BEQ     PRINT_ADDRESS_W_POST_INC
    CMPI    #%100, D3 * e.g. -(A3)
    BEQ     PRINT_ADDRESS_W_PRE_DEC
        
PRINT_GE_111:
    CMPI    #%000, D2
    BEQ     PRINT_ABS_SHORT
    CMPI    #%001, D2
    BEQ     PRINT_ABS_LONG
    CMPI    #%100, D2
    BEQ     PRINT_IMMDTE
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* PRINT_THIS FUNCTIONS (INTERMEDIATE LEVEL) ******
PRINT_DATA_REGISTER:
    * e.g. D3
    JSR     PRINT_D
    MOVE.L  D2, D1 * Loading D2(=Dreg to D1 for number printing)
    JSR     PRINT_NUM
    JMP     (A2)

PRINT_ADDR_REGISTER:
    * e.g. A3
    JSR     PRINT_A
    MOVE.L  D2, D1
    JSR     PRINT_NUM
    JMP     (A2)

PRINT_ADDRESS:
    * e.g. (A3)
    JSR     PRINT_PTHSIS_OPEN
    JSR     PRINT_ADDR_REGISTER
    JSR     PRINT_PTHSIS_CLSD
    JMP     (A2)

PRINT_ADDRESS_W_POST_INC:
    * e.g. (A3)+
    JSR     PRINT_ADDRESS
    JSR     PRINT_PLUS_SIGN
    JMP     (A2)

PRINT_ADDRESS_W_PRE_DEC:
    * e.g. -(A3)
    JSR     PRINT_MINUS_SIGN
    JSR     PRINT_ADDRESS
    JMP     (A2)

PRINT_ABS_SHORT:
    JSR     PRINT_HEX_SIGN
    MOVE.W  A3, D1
    JSR     PRINT_NUM
    JMP     (A2)

PRINT_ABS_LONG:
    JSR     PRINT_HEX_SIGN
    MOVE.L  A3, D1
    JSR     PRINT_NUM
    JMP     (A2)
    
PRINT_IMMDTE:
    JSR     PRINT_IMMDTE_VALU
    JMP     PRINT_ABS_LONG

**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* PRINT_THIS FUNCTIONS (LOW LEVEL) ***************
PRINT_NEW_LINE:
    LEA     NEW_LINE, A1
    JSR     PRINT_THIS_SHIT
    RTS

PRINT_COMMA_SPACE:
    LEA     COMMA_SPACE, A1
    JSR     PRINT_THIS_SHIT
    RTS
    
PRINT_D:
    LEA     DATA, A1
    JSR     PRINT_THIS_SHIT
    RTS
    
PRINT_A:
    LEA     ADDRESS, A1
    JSR     PRINT_THIS_SHIT
    RTS

PRINT_PTHSIS_OPEN:    
    LEA     PTHSIS_OPEN, A1
    JSR     PRINT_THIS_SHIT
    RTS
    
PRINT_PTHSIS_CLSD:
    LEA     PTHSIS_CLSD, A1
    JSR     PRINT_THIS_SHIT
    RTS
    
PRINT_HEX_SIGN:
    LEA     HEX_SIGN, A1
    JSR     PRINT_THIS_SHIT
    RTS

PRINT_IMMDTE_VALU:
    LEA     IMMDTE_VALU, A1
    JSR     PRINT_THIS_SHIT
    RTS

PRINT_PLUS_SIGN:
    LEA     PLUS_SIGN, A1
    JSR     PRINT_THIS_SHIT
    RTS
    
PRINT_MINUS_SIGN:
    LEA     MINUS_SIGN, A1
    JSR     PRINT_THIS_SHIT
    RTS
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* PRINT_THIS FUNCTIONS (LOWEST LEVEL) ************
PRINT_THIS_SHIT:
    MOVE.B  #14, D0
    TRAP    #15
    RTS

PRINT_NUM:
    MOVE.B  #3, D0
    TRAP    #15
    RTS
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* MESSAGE VARIABLES ******************************
ADDRESS         DC.B    'A',0
DATA            DC.B    'D',0

PTHSIS_OPEN     DC.B    '(',0
PTHSIS_CLSD     DC.B    ')',0
HEX_SIGN        DC.B    '$',0
IMMDTE_VALU     DC.B    '#',0
PLUS_SIGN       DC.B    '+',0
MINUS_SIGN      DC.B    '-',0

COMMA_SPACE     DC.B    ', ',0
NEW_LINE        DC.B    CR,LF,0
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* CONSTANTS **************************************
CR              EQU     $0D
LF              EQU     $0A
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    END    START


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
