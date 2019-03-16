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
START:
    MOVE.W  #$6000, CUR_OP_CODE
    MOVE.B  #%1110, MNEMONIC
    MOVE.B  #%000, FIRST_3
    MOVE.B  #%110, SECOND_3
    MOVE.B  #%100, THIRD_3
    MOVE.B  #%001, FOURTH_3
    
    MOVE.W  #START_ADDRESS, D0
    ADDI.B  #2, D0
    MOVEA.L D0, A5
    *MOVEA.L #START_ADDRESS, A5
    
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
    CMPI.B  #$8, MNEMONIC
    BEQ     LOAD_1000
    CMPI.B  #$9, MNEMONIC
    BEQ     LOAD_1001
    CMPI.B  #$B, MNEMONIC
    BEQ     LOAD_1011
    CMPI.B  #$C, MNEMONIC
    BEQ     LOAD_1100
    CMPI.B  #$D, MNEMONIC
    BEQ     LOAD_1101
    CMPI.B  #$E, MNEMONIC
    BEQ     LOAD_1110
    
    JMP     INVALID
    
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
    CMPI.B  #%0100, MNEMONIC
    BEQ     LOAD_0100
    CMPI.B  #%0101, MNEMONIC
    BEQ     LOAD_0101
    CMPI.B  #%0110, MNEMONIC
    BEQ     LOAD_0110
    RTS

**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* LOAD_THIS FUNCTIONS (HIGHEST LEVEL) ************

* <EA>
**********************************************************************************
* Description: Once the mnemonic is 1110, it is either ASd, LSd, or ROd.
*
* Registers used: Whether if it is ASd, LSd, or ROd, they all share the same
*                 EA algorithm. D5 for calculation, A2 and A3 for returning from subbranches.
*
* Precondition: FIRST_3, SECOND_3, THIRD_3, FOURTH_3
*
* Postcondition: X
**********************************************************************************
LOAD_1110:
            MOVEA.L #0, A2
            MOVEA.L #0, A3
            CLR.L   D5
    
            MOVE.B  SECOND_3, D5
            ANDI.B  #%011, D5
    
            CMPI.B  #%11, D5
            BEQ     MYBE_ASd_1
            BNE     MYBE_ASd_2

***vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv***
***111111111 ASd <ea> 111111111***
MYBE_ASd_1  CMPI.B  #%000, FIRST_3
            BEQ     ASd_1
            CMPI.B  #%001, FIRST_3
            BEQ     ASd_1 * LSd
            CMPI.B  #%011, FIRST_3
            BEQ     ASd_1 * ROd
            JMP     INVALID

ASd_1       CMPI.B  #%111, THIRD_3
            BNE     INVALID
            
            CMPI.B  #%100, FOURTH_3
            BEQ     INVALID
            
            MOVEA.W #ASd_1_BACK, A3
            CMPI.B  #%000, FOURTH_3
            BEQ     SIZE_W
            CMPI.B  #%001, FOURTH_3
            BEQ     SIZE_L

ASd_1_BACK  MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS
***111111111 ASd <ea> 111111111***
***^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***

***vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv***
***111111111 ASd X, Y 11111111***
MYBE_ASd_2  CLR.L   D5

            MOVE.B  THIRD_3, D5
            ANDI.B  #%011, D5
            CMPI.B  #%10, D5
            BNE     ASd_2 * or LSd or ROd
            BEQ     INVALID
            
ASd_2       CLR.L   D5

            MOVE.B  THIRD_3, D5
            ANDI.B  #%100, D5
            CMPI.B  #%100, D5
            BEQ     ASd_2_REG
            BNE     ASd_2_IMD
            
***vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv***
***222222222 ASd #<data>, Dy 222222222***
ASd_2_IMD   MOVEA.W #ASd_2_IMD_B, A2
            CMPI.B  #%000, FIRST_3
            BEQ     LOAD_8
            BNE     LOAD_FIRST3
            
LOAD_8      MOVE.B  #8, D4
            JMP     LOAD_IMMDTE

LOAD_FIRST3 MOVE.B  FIRST_3, D4
            JMP     LOAD_IMMDTE

ASd_2_IMD_B JSR     LOAD_COMMA_SPACE

            MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS
***222222222 ASd #<data>, Dy 222222222***
***^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***

***vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv***
***222222222 ASd Dx, Dy 222222222***
ASd_2_REG   MOVE.B  #%000, D3
            MOVE.B  FIRST_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_COMMA_SPACE
            
            MOVE.B  #%000, D3
            MOVE.B  FOURTH_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS
***222222222 ASd Dx, Dy 222222222***
***^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***

***111111111 ASd X, Y 111111111***
***^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***


* <EA>
**********************************************************************************
* Description: Once the mnemonic is 0110, it is either BRA or Bcc.
*
* Registers used: Whether if it is BRA or Bcc, in terms of EA, both instructions
*                 share the same EA algorithm. D4 for the displacement, D5 for calculation,
*                 D6 for checking the current opcode, A2 and A3 for returning from subbranches.
*
* Precondition: FIRST_3, SECOND_3, THIRD_3, FOURTH_3
*
* Postcondition: X
**********************************************************************************
LOAD_0110:
            MOVEA.L #0, A2
            MOVEA.L #0, A3
            CLR.L   D5
            CLR.L   D6
            CLR.L   D4

            CMPI.B  #%000, FIRST_3
            BEQ     MYBE_BRA
            BNE     NOT_BRA
MYBE_BRA    CMPI.B  #%100, SECOND_3
            BLT     BRA
            BGE     NOT_BRA
            
NOT_BRA     MOVE.B  FIRST_3, D5
            ASL.B   #1, D5
            MOVE.B  SECOND_3, D6
            ASR.B   #2, D6
            ADD.B   D6, D5
            
            CMPI.B  #%0101, D5
            BEQ     BRA * CS
            CMPI.B  #%1000, D5
            BEQ     BRA * VC
            CMPI.B  #%1100, D5
            BEQ     BRA * GE
            CMPI.B  #%1101, D5
            BEQ     BRA * LT
            
            JMP     INVALID
            
            
BRA         CLR.L   D5
            CLR.L   D6

            MOVE.W  A5, D5 * D5 has $1002 (Starting + MNEMONICS)
            MOVE.W  CUR_OP_CODE, D6
            ANDI.W  #$00FF, D6 * D6 now has $E
            CMPI.B  #$00, D6
            BEQ     BRA_WORD * word. there is 4 hex trailing bits (word)

            CMPI.B  #$FF, D6
            BEQ     BRA_BYTE
            CMPI.B  #$FE, D6
            BEQ     BRA_BYTE

            JMP     INVALID
            
***vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv***
***111111111 BRA_BYTE 111111111***
BRA_BYTE    CMPI.B  #$FE, D6
            BEQ     DOWN_ZERO
            CMPI.B  #$FF, D6
            BEQ     DOWN_ONE
            
            JMP     INVALID
            
DOWN_ZERO   SUBI.B  #$2, D5 * D5 has $1000 (Starting)
            JMP     BRA_BYTE2
            
DOWN_ONE    SUBI.B  #$1, D5 * D5 has $1001 (Starting + 1)
            JMP     BRA_BYTE2
            
BRA_BYTE2   MOVE.W  #BRA_BYTE3, A2
            MOVE.W  D5, D4
            JMP     LOAD_ABS_SHORT
BRA_BYTE3   JSR     LOAD_NEW_LINE
            RTS
***111111111 BRA_BYTE 111111111***
***^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***

***vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv***
***111111111 BRA_WORD 111111111***
BRA_WORD    MOVE.W  (A5)+, D4 * D4 now has $000E

            CMPI.L  #$8000, D4
            BGE     NEG_WORD
            BLT     POS_WORD
            
***vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv***
***222222222 BRA_WORD_POSITIVE 222222222***
POS_WORD    MOVE.W  #BRA_WORD_BK, A2
            ADD.W   D5, D4 * D4 now has $100E
            JMP     LOAD_ABS_SHORT
BRA_WORD_BK JSR     LOAD_NEW_LINE
            RTS
***222222222 BRA_WORD_POSITIVE 222222222***
***^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***

***vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv***
***222222222 BRA_WORD_NEGATIVE 222222222***
NEG_WORD    MOVE.W  #BRA_WRD_BK2, A2
            NEG     D4
            
            CMP.L   D5, D4 * $4002 vs DISPLACEMENT
            BGT     INVALID
            
            SUB.W   D4, D5 * D5 now has $1000 - 2cmp'ed $000E
            MOVE.W  D5, D4
            JMP     LOAD_ABS_SHORT
BRA_WRD_BK2 JSR     LOAD_NEW_LINE
            RTS
***222222222 BRA_WORD_NEGATIVE 222222222***
***^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***

***111111111 BRA_WORD 111111111***
***^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^***


* <EA>
**********************************************************************************
* Description: Once the mnemonic is 1001, it is either ADD or ADDA.
*
* Registers used: If ADDA, D3 for SRC/DST mod, D2 for SRC/DST reg, A3 to get back from the subbranch.
*                 If ADD, basically recycling the algorithm for DIVS/OR
*
* Precondition: FIRST_3, SECOND_3, THIRD_3, FOURTH_3
*
* Postcondition: X
**********************************************************************************
LOAD_1101:
            CMPI.B  #%011, SECOND_3
            BEQ     ADDA
            CMPI.B  #%111, SECOND_3
            BEQ     ADDA
            
            JMP     LOAD_1000
            
ADDA        MOVEA.W #ADDA_BACK, A3
            CMPI.B  #%000, FOURTH_3
            BEQ     SIZE_W
            CMPI.B  #%001, FOURTH_3
            BEQ     SIZE_L
            
ADDA_BACK   MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2

            JSR     LOAD_EA
            JSR     LOAD_COMMA_SPACE
            
            MOVE.B  #%001, D3
            MOVE.B  FIRST_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS

* <EA>
**********************************************************************************
* Description: Once the mnemonic is 1001, it is MULS.
*
* Registers used: X. Basically recycling the algorithm for DIVS/OR
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
LOAD_1100:
    JMP     LOAD_1000
    
* <EA>
**********************************************************************************
* Description: Once the mnemonic is 1001, it is either EOR or CMP.
*
* Registers used: X. Basically recycling the algorithm for DIVS/OR
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
LOAD_1011:
    JMP     LOAD_1000


* <EA>
**********************************************************************************
* Description: Once the mnemonic is 1001, it is SUB.
*
* Registers used: X. Basically recycling the algorithm for DIVS/OR
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
LOAD_1001:
    JMP     LOAD_1000


* <EA>
**********************************************************************************
* Description: Once the mnemonic is 1000, it is either DIVS or OR.
*
* Registers used: D3 for SRC/DST mod, D2 for SRC/DST reg, A3 to get back from the subbranch.
*
* Precondition: FIRST_3, SECOND_3, THIRD_3, FOURTH_3
*
* Postcondition: X
**********************************************************************************
LOAD_1000:
            CLR.L   D3
            CLR.L   D2
            MOVEA.L #0, A3
            
            CMPI.B  #%111, SECOND_3
            BEQ     DIVS
            
            CMPI.B  #%011, SECOND_3
            BEQ     INVALID
            
***vvvvvvvvvvvvvvvvvvv***
            CMPI.B  #%100, SECOND_3
            BLT     DIR_0 * direction bit 0
            BGE     DIR_1 * direction bit 1
            
DIR_0       MOVEA.W #OR_BACK, A3
            CMPI.B  #%000, FOURTH_3
            BEQ     SIZE_W
            CMPI.B  #%001, FOURTH_3
            BEQ     SIZE_L
            
OR_BACK     MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2

            JSR     LOAD_EA
            JSR     LOAD_COMMA_SPACE
            
            MOVE.B  #%000, D3
            MOVE.B  FIRST_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS
            
DIR_1       MOVE.B  #%000, D3
            MOVE.B  FIRST_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_COMMA_SPACE
            
            MOVEA.W #OR_BACK2, A3
            CMPI.B  #%000, FOURTH_3
            BEQ     SIZE_W
            CMPI.B  #%001, FOURTH_3
            BEQ     SIZE_L
            
OR_BACK2    MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2

            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS    
***^^^^^^^^^^^^^^^^^^^***
            
***vvvvvvvvvvvvvvvvvvv***
DIVS        MOVE.B  #%000, D3
            MOVE.B  FIRST_3, D2

            JSR     LOAD_EA
            JSR     LOAD_COMMA_SPACE
            
            MOVEA.W #DIVS_BACK, A3
            CMPI.B  #%000, FOURTH_3
            BEQ     SIZE_W
            CMPI.B  #%001, FOURTH_3
            BEQ     SIZE_L
            
DIVS_BACK   MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS
***^^^^^^^^^^^^^^^^^^^***


* <EA>
**********************************************************************************
* Description: Once the mnemonic is 0101, it is SUBQ
*
* Registers used: D4 to load the data within the EA bits, and A2 to come back
*
* Precondition: FIRST_3, SECOND_3, THIRD_3, FOURTH_3
*
* Postcondition: X
**********************************************************************************
LOAD_0101:
            CLR.L   D3
            CLR.L   D2
            MOVEA.L #0, A3

            CMPI.B  #%111, FIRST_3
            BLE     MYBE_SUBQ1
            JMP     INVALID
            
MYBE_SUBQ1  CMPI.B  #%011, SECOND_3
            BGT     MYBE_SUBQ2
            JMP     INVALID

MYBE_SUBQ2  CMPI.B  #%111, SECOND_3
            BLT     SUBQ
            JMP     INVALID

SUBQ        ADDI.B  #%1, FIRST_3
            MOVE.B  FIRST_3, D4
            
            MOVEA.W #SUBQ_SAVED, A2
            JMP     LOAD_IMMDTE
            
SUBQ_SAVED  JSR     LOAD_COMMA_SPACE

            MOVEA.W #SUBQ_BACK, A3
            CMPI.B  #%100, SECOND_3
            BEQ     SIZE_B
            CMPI.B  #%101, SECOND_3
            BEQ     SIZE_W
            CMPI.B  #%110, SECOND_3
            BEQ     SIZE_L
            
SUBQ_BACK   MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2

            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS

* <EA>
**********************************************************************************
* Description: Once the mnemonic is 0100, it is either NEG, RTS, JSR, MOVEM, or LEA.
*
* Registers used: D3 for SRC/DST mod, D2 for SRC/DST reg, A3 to get back from the subbranch,
*                 D5, D4 for BCLR, D6 for recognizing MOVEM
*
* Precondition: FIRST_3, SECOND_3, THIRD_3, FOURTH_3
*
* Postcondition: X
**********************************************************************************
LOAD_0100:
            CLR.L   D3
            CLR.L   D2
            MOVEA.L #0, A3

            CMPI.B  #%010, FIRST_3
            BEQ     MYBE_NEG
            BNE     NOT_NEG
MYBE_NEG    CMPI.B  #%011, SECOND_3
            BLT     NEG

NOT_NEG     CMPI.B  #%111, FIRST_3
            BEQ     MYBE_RTS1
            BNE     NOT_RTS
MYBE_RTS1   CMPI.B  #%001, SECOND_3
            BEQ     MYBE_RTS2
            BNE     NOT_RTS
MYBE_RTS2   CMPI.B  #%110, THIRD_3
            BEQ     MYBE_RTS3
            BNE     NOT_RTS
MYBE_RTS3   CMPI.B  #%101, FOURTH_3
            BEQ     RTS
            
NOT_RTS     CMPI.B  #%111, FIRST_3
            BEQ     MYBE_JSR
            BNE     NOT_JSR
MYBE_JSR    CMPI.B  #%010, SECOND_3
            BEQ     JSR

NOT_JSR     CLR.L   D6
            MOVE.B  FIRST_3, D6
            ANDI.B  #%101, D6 * Making %1X0 -> %100
            CMPI.B  #%100, D6
            BEQ     MYBE_MOVEM
            BNE     NOT_MOVEM
            
MYBE_MOVEM  MOVE.B  SECOND_3, D6
            ANDI.B  #%110, D6
            CMPI.B  #%010, D6
            BEQ     MOVEM
            
NOT_MOVEM   CMPI.B  #%111, SECOND_3
            BEQ     LEA
            
            JMP     INVALID

NEG:
            MOVEA.W #NEG_BACK, A3
            CMPI.B  #%000, SECOND_3
            BEQ     SIZE_B
            CMPI.B  #%001, SECOND_3
            BEQ     SIZE_W
            CMPI.B  #%010, SECOND_3
            BEQ     SIZE_L
            
NEG_BACK    MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2

            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS
            
RTS:
            JSR     LOAD_NEW_LINE
            RTS

JSR:
            MOVEA.W #JSR_BACK, A3
            CMPI.B  #%000, FOURTH_3
            BEQ     SIZE_W
            CMPI.B  #%001, FOURTH_3
            BEQ     SIZE_L
            
JSR_BACK    MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS

MOVEM:
            JMP     INVALID
    
LEA:
            MOVEA.W #LEA_BACK, A3
            CMPI.B  #%000, FOURTH_3
            BEQ     SIZE_W
            CMPI.B  #%001, FOURTH_3
            BEQ     SIZE_L
            
LEA_BACK    MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_COMMA_SPACE
            
            MOVE.B  #%001, D3
            MOVE.B  FIRST_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            RTS

* <EA>
**********************************************************************************
* Description: Once the mnemonic is 0000, it is either BCLR, CMPI, ORI, or Dynamic BCLR.
*
* Registers used: D3 for SRC/DST mod, D2 for SRC/DST reg, A3 to get back from the subbranch,
*                 D5, D4 for BCLR
*
* Precondition: FIRST_3, SECOND_3, THIRD_3, FOURTH_3
*
* Postcondition: X
**********************************************************************************
LOAD_0000:
            CLR.L   D3
            CLR.L   D2
            MOVEA.L #0, A3

            CMPI.B  #%000, FIRST_3
            BEQ     MYBE_ORI
            BNE     NOT_ORI
MYBE_ORI    CMPI.B  #%011, SECOND_3
            BLT     ORI_CMPI            

NOT_ORI     CMPI.B  #%110, FIRST_3
            BEQ     MYBE_CMPI
            BNE     NOT_CMPI
MYBE_CMPI   CMPI.B  #%011, SECOND_3
            BLT     ORI_CMPI
            
NOT_CMPI    CMPI.B  #%100, FIRST_3
            BEQ     MYBE_BCLR
            BNE     NOT_BCLR
MYBE_BCLR   CMPI.B  #%010, SECOND_3
            BEQ     BCLR

NOT_BCLR    CMPI.B  #%110, SECOND_3
            BEQ     DYNMC_BCLR
            
            JMP     INVALID
            
***vvvvvvvvvvvvvvvvvvv***
ORI_CMPI    MOVEA.W #BACK, A3
            CMPI.B  #%000, SECOND_3
            BEQ     SIZE_B
            CMPI.B  #%001, SECOND_3
            BEQ     SIZE_W
            CMPI.B  #%010, SECOND_3
            BEQ     SIZE_L

BACK        MOVE.B  #%111, D3
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
BCLR        CLR.L   D5
            CLR.L   D4
            MOVEA.L #0, A2

            MOVE.W  #END_ADDRESS, D5
            SUB.W   A5, D5
            CMPI.W  #$2, D5
            BLT     INVALID

            MOVE.W  (A5)+, D4
            CLR.L   D4
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
            
BACK5       MOVE.B  THIRD_3, D3
            MOVE.B  FOURTH_3, D2
            
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
            
            RTS
***^^^^^^^^^^^^^^^^^^^***

* <EA>
**********************************************************************************
* Description: Once the mnemonic is 00XX, it is either MOVE or MOVEA. Checks the 3-bit bundles and
*              the size of immediate/address values if necessary.
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
    
    JMP     INVALID
    
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
    
            JMP     INVALID
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
*              than 9 (A~F), then adds $37. Then moves the hex value from D0 to EA_BUFFER in ASCII
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

* <EA>
**********************************************************************************
* Description: Execution goes here if even one of the EA bit is invalid. Flags the invalid-bit and
*              entirely exits the EA process.
*
* Registers used: X
*
* Precondition: X
*
* Postcondition: X
**********************************************************************************
INVALID:
            MOVE.B  #%0, IS_VALID
            JMP     EXT
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    END    START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
