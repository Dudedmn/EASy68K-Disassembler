
    ORG    $1000
**************************************************
*   [NOTICE]
*   Data Register for Mode => D3
*   Data Register for Register# => D2
*   Address Register for Trailing Bits => A3
**************************************************
  
 
	MOVE.W #%0010011001001101,(A6) ;MOVEA.L A5,A3
MOVE_AND_MOVEA_PARSE_EA:       ;Move the 3 bit dynamic register bits to proper register
   ; MOVEM.L D0-D7/A6, -(SP)  ;Save all changed registers
    MOVE.W (A6),D0           ;Move current OP code into D0
    MOVE.W  #10,D1           ;Prepare 10 bit shift to D1
    LSL.W   D1,D0            ;Truncate to find the last 6 bits
    LSR.W   D1,D0            ;Shift back to get the proper 6 bits
    MOVE.W  D0,D7            ;Move last 6 bits into D7, SRC REG MODE
    MOVE.W  #3,D1            ;Prepare 3 bit shift into D1
    LSR.W   D1,D7            ;Shift 3 bits off D7 to obtain EA Mode
    MOVE.W  D7,D5            ;Move the 'upper' 3 bits into D6
    MOVE.W  #13,D1           ;Prepare 13 bit shift into D1
    LSL.W   D1,D0            ;Shift D0 left 13 bits to reposition current 3 bits
    LSR.W   D1,D0            ;Shift D0 right 13 bits to reposition current 3 bits
    MOVE.W  D0,D4            ;Move the 'lower' 3 bits into D7
    **************MOVING SOURCE*********** TO BE DONE LATER
    ; MOVE.W #%0011 011 001 001 101,(A6)              ;MOVEA.W A5,A3
    ; MOVE.W #%0010 011 001 001 101,D0                ;MOVEA.L A5,A3
     ;Expected values:
    ;D7, DST REG:   011
    ;D6, DST MODE:  001
    ;D5, SRC MODE:  001
    ;D4, SRC REG:   101
    ;00011001
    MOVE.W (A6),D0     ;Move current OP code into D0     
    MOVE.W  #4,D1             ;Prepare 4 bit shift to D1
    LSL.W   D1,D0             ;Truncate to find bits 11-6
    LSR.W   D1,D0             ;Reposition bits
    MOVE.W  #6,D1             ;Prepare 6 bit shift to D1
    LSR.W   D1,D0             ;Truncate the SRC Reg/Mode bits
    MOVE.W  #3,D1             ;Prepare a 3 bit shift to D1 for DST Reg/Mode
    MOVE.W  D0,D6             ;Copy over the current 6 bits to D6
    LSR.W   D1,D0             ;Truncate DST Mode  
    MOVE.W  D0,D7             ;Move DST Reg to D7
    MOVE.W  #13,D1             
    LSL.W   D1,D6             ;Truncate 13 bits in D6
    LSR.W   D1,D6             ;Reposition D6
    MOVE.W #$2,A6                           ;D6 now contains the DST Reg
   ; MOVEM.L (SP)+,D0-D7/A6   ;Restore registers
***


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* EXECUTION **************************************
START:
    MOVEA.W #%0000, A6
    MOVE.B  #%000, D7
    MOVE.B  #%000, D6
    MOVE.B  #%001, D5
    MOVE.B  #%001, D4
    MOVEA.L #$0E, A3
    LEA     G_BUFFER, A4

    JSR     CHECK_XXXX
EXT SIMHALT * This EXT alias is critical for NOT loading error
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
    BLT     LOAD_0000
    CMPA    #$2, A6
    BGT     CHECK_0011
    
    * IT IS 00XX(=MOVE(A))
    JMP     LOAD_00XX

CHECK_01XX:
    RTS
    
CHECK_0011:
    RTS
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* LOAD_THIS FUNCTIONS (HIGHEST LEVEL) ************
LOAD_0000:

;            CMPI.B  #%110, D4
;            BEQ     DBCLR
;            BNE     NOT_DBCLR

;DBCLR       MOVE.B  #%000, D3 * D in Dx to Mod
;            MOVE.B  D5, D2 * x in Dx to Reg
;            JMP     LOAD_SRC

;NOT_DBCLR   MOVE.B  #%111, D3
;            MOVE.B  #%100, D2 * IMMDTE to Mod
;            JMP     LOAD_SRC

;LOAD_SRC    JSR     LOAD_EA
;            JSR     LOAD_COMMA_SPACE
            * SRC part done

;            MOVE.B  D6, D3
;            MOVE.B  D7, D2
;            JSR     LOAD_EA
;            JSR     LOAD_NEW_LINE
            * DST part done

            * Logistics: 1. Assume it's Dynamic BCLR
            *            2. Check and if not then ORI/CMPI/Static BCLR
            MOVE.B  #%000, D3 * Assuming its DBCLR
            
            CMPI.B  #%110, D4 * Checking to see
            BEQ     DYNMC_BCLR * It is DBCLR 
            MOVE.B  #%111, D3 * It is not DBCLR

DYNMC_BCLR  MOVE.B  D5, D2 * D2 is for register #

            JSR     LOAD_EA
            JSR     LOAD_COMMA_SPACE

            MOVE.B  D7, D3 * D3 is for mode
            MOVE.B  D6, D2 * D2 is for register #
    
            JSR     LOAD_EA
            JSR     LOAD_NEW_LINE
    
            RTS
    
LOAD_00XX:
    MOVE.B  D5, D3
    MOVE.B  D4, D2
    
    JSR     LOAD_EA
    JSR     LOAD_COMMA_SPACE
    
    MOVE.B  D6, D3
    MOVE.B  D7, D2
    
    JSR     LOAD_EA
    JSR     LOAD_NEW_LINE
    
    RTS
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* LOAD_THIS FUNCTIONS (HIGH LEVEL) ***************
LOAD_EA:
        MOVEA.  #SAVED, A2 * remember to come back!

        CMPI    #%111, D3
        BLT     LOAD_LT_111
        BGE     LOAD_GE_111
    
SAVED   RTS

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
    
LOAD_GE_111:
    CMPI    #%000, D2
    BEQ     LOAD_ABS_SHORT
    CMPI    #%001, D2
    BEQ     LOAD_ABS_LONG
    CMPI    #%100, D2
    BEQ     LOAD_IMMDTE
    
    JMP     EXT
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* LOAD_THIS FUNCTIONS (INTERMEDIATE LEVEL) *******
LOAD_DATA_REGISTER:
    * e.g. D3
    JSR     LOAD_D
    MOVE.L  D2, D0 * Loading D2(=Dreg to D0)
    JSR     LOAD_NUM
    JMP     (A2)

LOAD_ADDR_REGISTER:
    * e.g. A3
    JSR     LOAD_A
    MOVE.L  D2, D0
    JSR     LOAD_NUM
    JMP     (A2)

LOAD_ADDRESS:
    * e.g. (A3)
    JSR     LOAD_PTHSIS_OPEN
    JSR     LOAD_ADDR_REGISTER
    JSR     LOAD_PTHSIS_CLSD
    JMP     (A2)

LOAD_ADDRESS_W_POST_INC:
    * e.g. (A3)+
    JSR     LOAD_ADDRESS
    JSR     LOAD_PLUS_SIGN
    JMP     (A2)

LOAD_ADDRESS_W_PRE_DEC:
    * e.g. -(A3)
    JSR     LOAD_MINUS_SIGN
    JSR     LOAD_ADDRESS
    JMP     (A2)

LOAD_ABS_SHORT:
    JSR     LOAD_HEX_SIGN
    MOVE.W  A3, D0
    JSR     LOAD_BYTES
    JMP     (A2)

LOAD_ABS_LONG:
    JSR     LOAD_HEX_SIGN
    MOVE.L  A3, D0
    JSR     LOAD_BYTES
    JMP     (A2)
    
LOAD_IMMDTE:
    JSR     LOAD_IMMDTE_VALU
    JMP     LOAD_ABS_LONG

**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* LOAD_THIS FUNCTIONS (LOW LEVEL) ****************
* Shifts the bits to the left and prints the
* left-most bit
LOAD_BYTES:
        MOVE.L  D0, D1
        MOVEA.W #8, A5
LOOP    CMPA    #0, A5
        BGT     ROTATE
        RTS
    
ROTATE  ROL.L   #$04, D1
        MOVE.B  D1, D0
        ANDI.L  #$0000000F, D0
        JSR     LOAD_NUM
        SUBA    #1, A5
        JMP     LOOP        

LOAD_NEW_LINE:
    MOVE.B  CR, D0
    JSR     LOAD_THIS_SHIT
    MOVE.B  LF, D0
    JSR     LOAD_THIS_SHIT
    RTS

LOAD_COMMA_SPACE:
    MOVE.B  COMMA, D0
    JSR     LOAD_THIS_SHIT
    MOVE.B  SPACE, D0
    JSR     LOAD_THIS_SHIT
    
    RTS
    
LOAD_D:
    MOVE.B  DATA, D0
    JSR     LOAD_THIS_SHIT
    RTS
    
LOAD_A:
    MOVE.B  ADDRESS, D0
    JSR     LOAD_THIS_SHIT
    RTS

LOAD_PTHSIS_OPEN:    
    MOVE.B  PTHSIS_OPEN, D0
    JSR     LOAD_THIS_SHIT
    RTS
    
LOAD_PTHSIS_CLSD:
    MOVE.B  PTHSIS_CLSD, D0
    JSR     LOAD_THIS_SHIT
    RTS
    
LOAD_HEX_SIGN:
    MOVE.B  HEX_SIGN, D0
    JSR     LOAD_THIS_SHIT
    RTS

LOAD_IMMDTE_VALU:
    MOVE.B  IMMDTE_VALU, D0
    JSR     LOAD_THIS_SHIT
    RTS

LOAD_PLUS_SIGN:
    MOVE.B  PLUS_SIGN, D0
    JSR     LOAD_THIS_SHIT
    RTS
    
LOAD_MINUS_SIGN:
    MOVE.B  MINUS_SIGN, D0
    JSR     LOAD_THIS_SHIT
    RTS
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* LOAD_THIS FUNCTIONS (LOWEST LEVEL) *************

* Moves the hex value from D0 to G_BUFFER in A4
LOAD_THIS_SHIT:
    MOVE.B  D0, (A4)+
    RTS

* Adds $30 to a number in D0 to make it a hex
* If the number is greater than 9 (A~F), then adds $37
* Then moves the hex value from D0 to G_BUFFER in A4
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
* MESSAGE VARIABLES ******************************
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
G_BUFFER        DS.B    100
**************************************************
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


    END    START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
