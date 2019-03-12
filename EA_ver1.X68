
    ORG    $1000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* MESSAGE VARIABLES ******************************

* ASCII values for respective characters

ADDRESS         DC.B    $41
DATA            DC.B    $44

PTHSIS_OPEN     DC.B    $28
PTHSIS_CLSD     DC.B    $29
HEX_SIGN        DC.B    $24
IMMDTE_VALU     DC.B    $23
PLUS_SIGN       DC.B    $2B
MINUS_SIGN      DC.B    $2D

COMMA           DC.B    $2C
SPACE           DC.B    $20

CR              DC.B    $D
LF              DC.B    $A
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* GLOBAL BUFFER **********************************
MNEMONIC        DS.B    1 * First four BITS of any instruction
 
TRAILING_SIZE   DS.W    1 * Size of any immediate or
                          * address values. Immediate or address
                          * value of a BYTE is still processed as
                          * WORD because the trailing bytes
                          * are represented as a word regardless.
                          * $1 = BYTE, $2 = WORD, $4 = LONG

FIRST_3         DS.B    1 * First, second, third, and fourth bundles of three bits each
SECOND_3        DS.B    1
THIRD_3         DS.B    1
FOURTH_3        DS.B    1

CUR_OP_CODE     DS.W    1 * Used for Daniel's code

START_ADDRESS   EQU     $4000 * Used to parse through the entire instruction
END_ADDRESS     EQU     $5000

EA_BUFFER       DS.B    80 * Used to load ASCII-converted EA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IS_VALID        DS.B    1 * EA-bit validity flag
                          * $0 = invalid, $1 = valid
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* EXECUTION **************************************
START: * TEST FOR MOVE.L
    MOVE.B  #%0000, MNEMONIC
    MOVE.B  #%000, FIRST_3
    MOVE.B  #%110, SECOND_3
    MOVE.B  #%111, THIRD_3
    MOVE.B  #%001, FOURTH_3
    MOVEA.L #START_ADDRESS, A5
    LEA     EA_BUFFER, A4

    JSR     CHECK_XXXX
EXT SIMHALT * This EXT alias is critical for NOT loading error
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* CHECK_MNEMONIC FUNCTIONS ***************

* <EA>
**********************************************************************************
* Description: Checks the mnemonic starting from XXXX
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
CHECK_XXXX:
    CMPI.B  #$8, MNEMONIC
    BLT     CHECK_0XXX
    JMP     CHECK_1XXX

* <EA>
**********************************************************************************
* Description: Checks the mnemonic starting from 0XXX
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
CHECK_0XXX:
    CMPI.B  #$4, MNEMONIC
    BLT     CHECK_00XX
    JMP     CHECK_01XX

* <EA>
**********************************************************************************
* Description: Checks the mnemonic starting from 1XXX
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
CHECK_1XXX:
    RTS

* <EA>
**********************************************************************************
* Description: Checks the mnemonic starting from 00XX
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
CHECK_00XX:
    CMPI.B  #$1, MNEMONIC
    BLT     LOAD_0000
    BGE     LOAD_00XX

* <EA>
**********************************************************************************
* Description: Checks the mnemonic starting from 01XX
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
CHECK_01XX:
    RTS

* <EA>
**********************************************************************************
* Description: Checks the mnemonic 0011
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
CHECK_0011:
    RTS
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* LOAD_THIS FUNCTIONS (HIGHEST LEVEL) ************

* <EA>
**********************************************************************************
* Description: Once the mnemonic is 0000, it is either BCLR, CMPI, ORI, or Dynamic BCLR.
*
* Registers used: D3 for SRC/DST mod, D2 for SRC/DST reg, A3 to get back from the subbranch,
*                                   D5, D4 for BCLR
*
* Precondition: FIRST_3, SECOND_3, THIRD_3, FOURTH_3
*
* Postcondition: X
**********************************************************************************
LOAD_0000:  * BCLR/CMPI/ORI/Dynamic BCLR
            CLR.L   D3
            CLR.L   D2
            MOVEA.L #0, A3

            CMPI.B  #%000, FIRST_3
            BNE     LATER
            CMPI.B  #%110, SECOND_3
            BNE     ORI_CMPI
LATER       CMPI.B  #%110, FIRST_3
            BEQ     ORI_CMPI
            CMPI.B  #%010, SECOND_3
            BEQ     BCLR
            CMPI.B  #%110, SECOND_3
            BEQ     DYNMC_BCLR
            
            JMP     INVALID
            
***vvvvvvvvvvvvvvvvvvv***
ORI_CMPI         MOVEA.W #BACK, A3
                        CMPI.B     #%000, SECOND_3
            BEQ     SIZE_B
            CMPI.B  #%001, SECOND_3
            BEQ     SIZE_W
            CMPI.B  #%010, SECOND_3
            BEQ     SIZE_L

BACK               MOVE.B   #%111, D3
                        MOVE.B  #%100, D2
            
            JSR     LOAD_EA
            JSR     LOAD_COMMA_SPACE
            
            MOVEA.W #BACK2, A3   
            CMPI.B  #%000, FOURTH_3
            BEQ     SIZE_W
            CMPI.B  #%001, FOURTH_3
            BEQ     SIZE_L

BACK2       MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2
        
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS
***^^^^^^^^^^^^^^^^^^^***

***vvvvvvvvvvvvvvvvvvv***
BCLR               CLR.L   D5
            CLR.L   D4
            MOVEA.L #0, A2

            MOVE.W  #END_ADDRESS, D5
            SUB.W   A5, D5
            CMPI.W   #$2, D5
            BLT     INVALID

            MOVE.W  (A5)+, D4
            ANDI.W  #$00FF, D4
            MOVEA.L #BACK4, A2
            JMP     LOAD_IMMDTE
            
BACK4       JSR     LOAD_COMMA_SPACE
            
            MOVEA.W #BACK3, A3
            CMPI.B  #%000, FOURTH_3
            BEQ     SIZE_W
            CMPI.B  #%001, FOURTH_3
            BEQ     SIZE_L

BACK3       MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2

            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE

            RTS
***^^^^^^^^^^^^^^^^^^^***

***vvvvvvvvvvvvvvvvvvv***
DYNMC_BCLR  MOVE.B  #%000, D3
            MOVE.B  FIRST_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_COMMA_SPACE

            MOVEA.W #BACK5, A3
            CMPI.B  #%000, FOURTH_3
            BEQ     SIZE_W
            CMPI.B  #%001, FOURTH_3
            BEQ     SIZE_L
            
BACK5              MOVE.B   THIRD_3, D3
            MOVE.B  FOURTH_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            
            RTS
***^^^^^^^^^^^^^^^^^^^***

* <EA>
**********************************************************************************
* Description: Once the mnemonic is 00XX, it is either MOVE or MOVEA. Checks the 3-bit bundles and
*                            the size of immediate/address values if necessary.
*
* Registers used: D3 for SRC/DST mod, D2 for SRC/DST reg, A3 to get back from the subbranch
*
* Precondition: FIRST_3, SECOND_3, THIRD_3, FOURTH_3
*
* Postcondition: X
**********************************************************************************
LOAD_00XX:
        CLR.L   D3
        CLR.L   D2
        MOVEA.L #0, A3
        
        MOVEA.W #GOO, A3
        CMPI.B  #%0011, MNEMONIC
        BEQ     SIZE_W
        CMPI.B  #%0010, MNEMONIC
        BEQ     SIZE_L

GOO     MOVE.B  THIRD_3, D3
        MOVE.B  FOURTH_3, D2
    
        JSR     LOAD_EA
        JSR     LOAD_COMMA_SPACE
    
        MOVEA.W #GOO2, A3
        CMPI.B  #%000, FIRST_3
        BEQ     SIZE_W
        CMPI.B  #%001, FIRST_3
        BEQ     SIZE_L
    
GOO2    MOVE.B  SECOND_3, D3
        MOVE.B  FIRST_3, D2
            
        JSR     LOAD_EA
        JSR     LOAD_NEW_LINE
    
        RTS
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* LOAD_THIS FUNCTIONS (HIGH LEVEL) ***************

* <EA>
**********************************************************************************
* Description: Checks the SRC/DST mod
*
* Registers used: A2 for branching back from subbranches
*
* Precondition: D3 for SRC/DST mod
*
* Postcondition: X
**********************************************************************************
LOAD_EA:
        MOVEA.W #SAVED, A2 * remember to come back!

        CMPI    #%111, D3
        BLT     LOAD_LT_111
        BGE     LOAD_GE_111
    
SAVED   RTS

* <EA>
**********************************************************************************
* Description: Checks the SRC/DST mod where it is not immediate/address value
*
* Registers used: X
*
* Precondition: D3 for SRC/DST mod
*
* Postcondition: X
**********************************************************************************
LOAD_LT_111:
    CMPI    #%000, D3 * e.g. D3
    BEQ     LOAD_DATA_REGISTER
    CMPI    #%001, D3 * e.g. A3
    BEQ     LOAD_ADDR_REGISTER
    CMPI    #%010, D3 * e.g. (A3)
    BEQ     LOAD_ADDRESS
    CMPI    #%011, D3 * e.g. (A3)+
    BEQ     LOAD_ADDRESS_W_POST_INC
    CMPI    #%100, D3 * e.g. -(A3)
    BEQ     LOAD_ADDRESS_W_PRE_DEC
    
    JMP     EXT

* <EA>
**********************************************************************************
* Description: Checks the SRC/DST mod where it is immediate/address value
*
* Registers used: D5 for SUB.W, D4 for immediate/address value extraction
*
* Precondition: A5 for START_ADDRESS iteration, TRAILING_SIZE for size of the immediate/address value
*
* Postcondition: IS_INVALID flag set if EA bit not valid
**********************************************************************************
LOAD_GE_111:
            CLR.L   D5
            CLR.L   D4

            MOVE.W  #END_ADDRESS, D5
            SUB.W   A5, D5
            CMP.W   TRAILING_SIZE, D5
            BLT     INVALID

            CMPI.W  #$1, TRAILING_SIZE
            BEQ     CHUMP_BYTE
            CMPI.W  #$2, TRAILING_SIZE
            BEQ     CHUMP_WORD
            CMPI.W  #$4, TRAILING_SIZE
            BEQ     CHUMP_LONG

CHUMP_BYTE  MOVE.W  (A5)+, D4 * Minimum 4 hex (e.g. MOVE.B #1, $2 = XXXX 0001 0002)
            JMP     GO

CHUMP_WORD  MOVE.W  (A5)+, D4
            JMP     GO
            
CHUMP_LONG  MOVE.L  (A5)+, D4
            JMP     GO

GO          CMPI    #%000, D2
            BEQ     LOAD_ABS_SHORT
            CMPI    #%001, D2
            BEQ     LOAD_ABS_LONG
            CMPI    #%100, D2
            BEQ     LOAD_IMMDTE
    
INVALID     MOVE.B  #%0, IS_VALID
            JMP     EXT

* <EA>
**********************************************************************************
* Description: Puts in the proper value in TRAILING_SIZE based on the immediate/address value size
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: Set up TRAILING_SIZE
**********************************************************************************
TRAILING_HELPER:            
SIZE_B  MOVE.W  #$2, TRAILING_SIZE
        JMP     (A3)

SIZE_W  MOVE.W  #$2, TRAILING_SIZE
        JMP     (A3)
        
SIZE_L  MOVE.W  #$4, TRAILING_SIZE
        JMP     (A3)
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* LOAD_THIS FUNCTIONS (INTERMEDIATE LEVEL) *******

* <EA>
**********************************************************************************
* Description: Loads ASCII for e.g. D3 in EA_BUFFER
*
* Registers used: D0 for actually loading
*
* Precondition: D2 for SRC/DST reg
*
* Postcondition: X
**********************************************************************************
LOAD_DATA_REGISTER:
    CLR.L   D0
    
    JSR     LOAD_D
    MOVE.B  D2, D0
    JSR     LOAD_NUM
    JMP     (A2)

* <EA>
**********************************************************************************
* Description: Loads ASCII for e.g. A3 in EA_BUFFER
*
* Registers used: D0 for actually loading
*
* Precondition: D2 for SRC/DST reg
*
* Postcondition: X
**********************************************************************************
LOAD_ADDR_REGISTER:
    CLR.L   D0

    JSR     LOAD_A
    MOVE.B  D2, D0
    JSR     LOAD_NUM
    JMP     (A2)

* <EA>
**********************************************************************************
* Description: Loads ASCII for e.g. (A3) in EA_BUFFER
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
LOAD_ADDRESS:
    JSR     LOAD_PTHSIS_OPEN
    JSR     LOAD_ADDR_REGISTER
    JSR     LOAD_PTHSIS_CLSD
    JMP     (A2)

* <EA>
**********************************************************************************
* Description: Loads ASCII for e.g. (A3)+ in EA_BUFFER
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
LOAD_ADDRESS_W_POST_INC:
    JSR     LOAD_ADDRESS
    JSR     LOAD_PLUS_SIGN
    JMP     (A2)

* <EA>
**********************************************************************************
* Description: Loads ASCII for e.g. -(A3) in EA_BUFFER
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
LOAD_ADDRESS_W_PRE_DEC:
    JSR     LOAD_MINUS_SIGN
    JSR     LOAD_ADDRESS
    JMP     (A2)

* <EA>
**********************************************************************************
* Description: Loads ASCII for e.g. $1234 in EA_BUFFER
*
* Registers used: D0 for actually loading
*
* Precondition: D4 for immediate/address value  
*
* Postcondition: X
**********************************************************************************
LOAD_ABS_SHORT:
    CLR.L   D0

    JSR     LOAD_HEX_SIGN
    MOVE.W  D4, D0
    JSR     LOAD_BYTES
    JMP     (A2)

* <EA>
**********************************************************************************
* Description: Loads ASCII for e.g. $12345678 in EA_BUFFER
*
* Registers used: D0 for actually loading
*
* Precondition: D4 for immediate/address value  
*
* Postcondition: X
**********************************************************************************
LOAD_ABS_LONG:
    CLR.L   D0

    JSR     LOAD_HEX_SIGN
    MOVE.L  D4, D0
    JSR     LOAD_BYTES
    JMP     (A2)

* <EA>
**********************************************************************************
* Description: Loads ASCII for e.g. #$1234 in EA_BUFFER
*
* Registers used: X
*
* Precondition: X 
*
* Postcondition: X
**********************************************************************************
LOAD_IMMDTE:
    JSR     LOAD_IMMDTE_VALU
    JMP     LOAD_ABS_LONG

**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* LOAD_THIS FUNCTIONS (LOW LEVEL) ****************

* <EA>
**********************************************************************************
* Description: Shifts the hex to the left and loads from the left-most hex to EA_BUFFER in ASCII
*
* Registers used: D5 for the loop counter, D1 for loop assist
*
* Precondition: D0 for the immediate/address value  
*
* Postcondition: X
**********************************************************************************
LOAD_BYTES:
        CLR.L   D5
        CLR.L   D1

        MOVE.L  D0, D1
        MOVE.B  #8, D5
LOOP    CMPI    #0, D5
        BGT     ROTATE
        RTS
    
ROTATE  ROL.L   #$04, D1
        MOVE.B  D1, D0
        ANDI.L  #$0000000F, D0
        JSR     LOAD_NUM
        SUBI    #1, D5
        JMP     LOOP        

* <EA>
**********************************************************************************
* Description: Loads ASCII for CR, LF 
*
* Registers used: D0 for actually loading
*
* Precondition: CR, LF 
*
* Postcondition: X
**********************************************************************************
LOAD_NEW_LINE:
    CLR.L   D0

    MOVE.B  CR, D0
    JSR     LOAD_THIS_SHIT
    MOVE.B  LF, D0
    JSR     LOAD_THIS_SHIT
    RTS

* <EA>
**********************************************************************************
* Description: Loads ASCII for ', ' 
*
* Registers used: D0 for actually loading
*
* Precondition: COMMA, SPACE
*
* Postcondition: X
**********************************************************************************
LOAD_COMMA_SPACE:
    CLR.L   D0

    MOVE.B  COMMA, D0
    JSR     LOAD_THIS_SHIT
    MOVE.B  SPACE, D0
    JSR     LOAD_THIS_SHIT
    
    RTS

* <EA>
**********************************************************************************
* Description: Loads ASCII for D 
*
* Registers used: D0 for actually loading
*
* Precondition: DATA
*
* Postcondition: X
**********************************************************************************
LOAD_D:
    CLR.L   D0

    MOVE.B  DATA, D0
    JSR     LOAD_THIS_SHIT
    RTS

* <EA>
**********************************************************************************
* Description: Loads ASCII for A
*
* Registers used: D0 for actually loading
*
* Precondition: ADDRESS
*
* Postcondition: X
**********************************************************************************
LOAD_A:
    CLR.L   D0

    MOVE.B  ADDRESS, D0
    JSR     LOAD_THIS_SHIT
    RTS

* <EA>
**********************************************************************************
* Description: Loads ASCII for (
*
* Registers used: D0 for actually loading
*
* Precondition: PTHSIS_OPEN
*
* Postcondition: X
**********************************************************************************
LOAD_PTHSIS_OPEN:
    CLR.L   D0

    MOVE.B  PTHSIS_OPEN, D0
    JSR     LOAD_THIS_SHIT
    RTS

* <EA>
**********************************************************************************
* Description: Loads ASCII for )
*
* Registers used: D0 for actually loading
*
* Precondition: PTHSIS_CLSD
*
* Postcondition: X
**********************************************************************************
LOAD_PTHSIS_CLSD:
    CLR.L   D0

    MOVE.B  PTHSIS_CLSD, D0
    JSR     LOAD_THIS_SHIT
    RTS

* <EA>
**********************************************************************************
* Description: Loads ASCII for $
*
* Registers used: D0 for actually loading
*
* Precondition: HEX_SIGN
*
* Postcondition: X
**********************************************************************************
LOAD_HEX_SIGN:
    CLR.L   D0

    MOVE.B  HEX_SIGN, D0
    JSR     LOAD_THIS_SHIT
    RTS

* <EA>
**********************************************************************************
* Description: Loads ASCII for #
*
* Registers used: D0 for actually loading
*
* Precondition: IMMDTE_VALU
*
* Postcondition: X
**********************************************************************************
LOAD_IMMDTE_VALU:
    CLR.L   D0

    MOVE.B  IMMDTE_VALU, D0
    JSR     LOAD_THIS_SHIT
    RTS

* <EA>
**********************************************************************************
* Description: Loads ASCII for +
*
* Registers used: D0 for actually loading
*
* Precondition: PLUS_SIGN
*
* Postcondition: X
**********************************************************************************
LOAD_PLUS_SIGN:
    CLR.L   D0

    MOVE.B  PLUS_SIGN, D0
    JSR     LOAD_THIS_SHIT
    RTS

* <EA>
**********************************************************************************
* Description: Loads ASCII for -
*
* Registers used: D0 for actually loading
*
* Precondition: MINUS_SIGN
*
* Postcondition: X
**********************************************************************************
LOAD_MINUS_SIGN:
    CLR.L   D0

    MOVE.B  MINUS_SIGN, D0
    JSR     LOAD_THIS_SHIT
    RTS
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* LOAD_THIS FUNCTIONS (LOWEST LEVEL) *************
* <EA>
**********************************************************************************
* Description: Loads the hex value from D0 to EA_BUFFER in ASCII
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
LOAD_THIS_SHIT:
    MOVE.B  D0, (A4)+
    RTS

* <EA>
**********************************************************************************
* Description: Adds $30 to a number in D0 to make it a hex. If the number is greater
*                            than 9 (A~F), then adds $37. Then moves the hex value from D0 to EA_BUFFER in ASCII
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
LOAD_NUM:
    CMPI.B  #$9, D0
    BGT     GT
    BLE     LE
    
GT  ADDI.B  #$37, D0 * A~F
    JMP     END
LE  ADDI.B  #$30, D0 * 0~9
    JMP     END

END MOVE.B  D0, (A4)+
    RTS
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    END    START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
